//
//  Rokt.swift
//  Rokt-Widget
//
//  Copyright 2020 Rokt Pte Ltd
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation
import UIKit
import AppTrackingTransparency

let kBundleName = "Rokt-Widget"
let kBundleExtension = "bundle"
let kStoryboardName = "Main"
let kRoktCIdentifier = "RoktController"
let kRoktWebViewIdentifier = "RoktWebView"
let defaultTimeout: Double = 9000
let defaultSessionExpiry: Double = 30 * 60 * 1000 // 30 mins in miliseconds
let defaultFontTimeout: Double = 30 // second
let defaultDelay: Double = 1000

/// Rokt class to initialize and siplay Rokt's widget
@objc public class Rokt: NSObject {
    static let shared = Rokt()

    private var stateBags: [String: ExecuteStateBag] = [:]
    private var displayController: UIViewController?
    internal var roktTagId: String?
    internal var executeSession: ExecuteSession?
    private var onLoad: (() -> Void)?
    private var onUnLoad: (() -> Void)?
    private var onShouldHideLoadingIndicator: (() -> Void)?
    private var onEmbeddedSizeChange: ((String, CGFloat) -> Void)?
    private var on2stepEvent: ((RoktEventType, RoktEventHandler) -> Void)?
    private var clientTimeoutMilliseconds: Double = defaultTimeout
    private var defaultLaunchDelayMilliseconds: Double = defaultDelay
    private var clientSessionTimeoutMilliseconds: Double = defaultSessionExpiry
    private var defaultDelayTimer: Timer?
    private var defaultDelayTimerLastFireDate: Date?
    internal var attributes = [String: String]()
    private var loadingFonts = false
    internal var isInitialized = false
    internal var isInitFailedForFont = false
    private var pendingPayload: ExecutePayload?
    private var isExecuting = false
    private var placements: [String: RoktEmbeddedView]?
    internal var debugLogEnabled: Bool = false
    internal var frameworkType: RoktFrameworkType = .iOS
    internal var processedEvents = ProcessedEventViewModel()
    internal var fontDiagnostics = FontDiagnosticsViewModel()
    private var roktConfig: RoktConfig?

    // Feature flags
    internal var initFeatureFlags: InitFeatureFlags = InitFeatureFlags(roktTrackingStatus: true,
                                                                       shouldLogFontHappyPath: false,
                                                                       shouldUseFontRegisterWithUrl: false,
                                                                       featureFlags: [:])

    // store callback for partner event integration
    private var roktEvent: ((RoktEvent) -> Void)?
    private var roktEventMap: [String: ((RoktEvent) -> Void)?] = [:]

    // to hold RoktLayout for SwiftUI integration
    private var _executeLayout: Any?

    @available(iOS 15.0, *)
    private var executeLayout: RoktLayout? {
        return _executeLayout as? RoktLayout
    }
    
    // stores timings if feature flag enabled
    internal var processedTimingsRequests: ProcessedTimingsRequestViewModel?

    /// Rokt private initializer. Only available for the singleton object `shared`
    private override init() {
        NetworkingHelper.updateTimeout(timeout: clientTimeoutMilliseconds / 1000)
    }

    // Loading fonts notification observer selector
    @objc func startedLoadingFonts(notification: Notification) {
        loadingFonts = true
    }

    // Finished loading fonts notification observer selector
    @objc func finishedLoadingFonts(notification: Notification) {
        loadingFonts = false
        Rokt.shared.processedTimingsRequests?.setInitEndTime()
        
        if let page = pendingPayload {
            showNow(payload: page)
        }
    }

    // Shows the widget on top the visible view controller
    private func showNow(payload: ExecutePayload) {
        guard !loadingFonts && isInitialized else {
            pendingPayload = payload
            return
        }
        if let placementPage = payload.placementPage {
            showNow(placementPage: placementPage)
        } else if let layoutPage = payload.layoutPage, #available(iOS 15, *) {
            let executeId = initialStateBag()
            do {
                try showNow(layoutPage: layoutPage, executeId: executeId)
            } catch {
                switch error {
                case LayoutFailureError.layoutTransformerError(let pluginId):
                    self.postExecuteFailureHandler(executeId, placementId: pluginId,
                                                   sessionId: layoutPage.sessionId)
                default:
                    self.postExecuteFailureHandler(executeId, placementId: nil,
                                                   sessionId: layoutPage.sessionId)
                }
                self.callOnUnLoad(executeId)
                self.displayController = nil
                self.placements = nil
                self._executeLayout = nil
            }
        }
    }

    @objc public static func setFrameworkType(frameworkType: RoktFrameworkType) {
        shared.frameworkType = frameworkType
    }

    @available(iOS 15, *)
    private func showNow(layoutPage: PageModel, executeId: String) throws {
        pendingPayload = nil
        onShouldHideLoadingIndicator?()
        roktEvent?(RoktEvent.HideLoadingIndicator())
        if let layoutPlugins = layoutPage.layoutPlugins {
            for layoutPlugin in layoutPlugins {
                try DCUIComponent().loadLayout(
                    sessionId: layoutPage.sessionId,
                    layoutPlugin: layoutPlugin,
                    startDate: layoutPage.startDate,
                    responseReceivedDate: layoutPage.responseReceivedDate,
                    placements: placements,
                    layout: executeLayout,
                    config: roktConfig,
                    onLoad: {[weak self] in self?.callOnLoad(executeId)},
                    onUnLoad: {[weak self] in self?.callOnUnLoad(executeId)},
                    onEmbeddedSizeChange: {[weak self] selectedPlacementName, widgetHeight in
                        self?.callOnEmbeddedSizeChange(executeId,
                                                       selectedPlacementName: selectedPlacementName,
                                                       widgetHeight: widgetHeight)
                    },
                    on2stepEvent: {[weak self] event, eventHandler in
                        self?.callOn2stepEvent(executeId, event: event,
                                               eventHandler: eventHandler,
                                               placementId: layoutPlugin.pluginId)
                    },
                    onRoktEvent: {[weak self] event in
                        self?.callOnRoktEvent(executeId, event: event)
                    })
            }
        } else {
            Log.i("Rokt: No Layouts")
            throw LayoutFailureError.layoutEmpty(pluginId: nil)
        }
        displayController = nil
        placements = nil
        _executeLayout = nil
    }

    private func showNow(placementPage: PageViewData) {
        pendingPayload = nil
        onShouldHideLoadingIndicator?()
        roktEvent?(RoktEvent.HideLoadingIndicator())
        let executeId = initialStateBag()
        if let placements = placementPage.placements {
            for placement in placements {
                switch placement.placementLayoutCode {
                case .lightboxLayout, .overlayLayout, .bottomSheetLayout:
                    // lightbox, overlay, bottomSheet
                    if let fullScreenPlacement = placement as? LightBoxViewData {
                        loadFullScreenWidget(placementPage.sessionId,
                                             executeId: executeId,
                                             placement: fullScreenPlacement,
                                             layoutCode: fullScreenPlacement.placementLayoutCode ?? .overlayLayout)
                    } else {
                        RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode,
                                                      callStack: kLayoutDoesNotMatch,
                                                      sessionId: placementPage.sessionId)
                        self.postExecuteFailureHandler(executeId, placementId: placement.placementId,
                                                       sessionId: placementPage.sessionId)
                        self.callOnUnLoad(executeId)
                    }
                case .embeddedLayout:
                    // embedded
                    if let embeddedPlacement = placement as? EmbeddedViewData {
                        loadEmbeddedWidget(placementPage.sessionId, executeId: executeId, placement: embeddedPlacement)
                    } else {
                        RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode, callStack: kLayoutDoesNotMatch,
                                                      sessionId: placementPage.sessionId)
                        self.postExecuteFailureHandler(executeId, placementId: placement.placementId,
                                                       sessionId: placementPage.sessionId)
                        self.callOnUnLoad(executeId)
                    }
                default:
                    // not supported
                    RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode, callStack: kLayoutDoesNotSupported,
                                                  sessionId: placementPage.sessionId)
                    self.postExecuteFailureHandler(executeId, placementId: placement.placementId,
                                                   sessionId: placementPage.sessionId)
                    self.callOnUnLoad(executeId)
                }
            }
        }
        displayController = nil
        placements = nil
    }

    private func loadFullScreenWidget(_ sessionId: String,
                                      executeId: String,
                                      placement: LightBoxViewData,
                                      layoutCode: PlacementLayoutCode) {
        let board = getStoryboard()
        var isOverlay = layoutCode == .overlayLayout
        if layoutCode == .bottomSheetLayout {
            // fallback to overlay for below iOS 15
            if #available(iOS 15.0, *) { isOverlay = false } else { isOverlay = true }
        }
        if let roktViewController = board.instantiateViewController(withIdentifier: kRoktCIdentifier)
            as? RoktViewController {

            roktViewController.initializeRoktViewController(
                sessionId: sessionId, placement: placement, isOverlay: isOverlay,
                onUnLoad: {[weak self] completionType in
                    self?.sendCompletionEvent(executeId: executeId, placementId: placement.placementId,
                                              completionType: completionType)
                    self?.callOnUnLoad(executeId)
                }, on2stepEvent: {[weak self] event, eventHandler in
                    self?.callOn2stepEvent(executeId, event: event, eventHandler: eventHandler,
                                           placementId: placement.placementId)})

            if layoutCode == .bottomSheetLayout, #available(iOS 15.0, *) {
                roktViewController.modalPresentationStyle = .pageSheet
                if placement.bottomSheetExpandable {
                    roktViewController.sheetPresentationController?.detents = [.medium(), .large()]
                } else { roktViewController.sheetPresentationController?.detents = [.medium()] }

                if !placement.bottomSheetDismissible { roktViewController.isModalInPresentation = true }

            } else if layoutCode != .lightboxLayout {
                // overlay or (bottomsheet and below iOS 15)
                roktViewController.modalPresentationStyle = .overFullScreen
                roktViewController.modalTransitionStyle = .crossDissolve
            }
            // Prevent multiple presentations
            if displayController?.presentedViewController == nil {
                callOnRoktEvent(executeId, event: RoktEvent.PlacementReady(placementId: placement.placementId))
                displayController?.present(roktViewController, animated: true, completion: { [weak self] in
                    self?.callOnLoad(executeId)
                    self?.callOnRoktEvent(executeId,
                                          event: RoktEvent.PlacementInteractive(placementId: placement.placementId))
                })
            } else {
                RoktAPIHelper.sendDiagnostics(message: kModalPlacementCallErrorCode,
                                              callStack: kModalAlreadyExists, sessionId: sessionId)
                sendModalLogs()
                self.postExecuteFailureHandler(executeId, placementId: placement.placementId, sessionId: sessionId)
                self.callOnUnLoad(executeId)
            }
        } else {
            self.postExecuteFailureHandler(executeId, placementId: placement.placementId, sessionId: sessionId)
            self.callOnUnLoad(executeId) }
    }

    private func sendModalLogs() {
        Log.i("""
              Rokt: A modal already exists on screen called
              \(String(describing: UIApplication.topViewController().self))
              """)
    }

    private func loadEmbeddedWidget(_ sessionId: String,
                                    executeId: String,
                                    placement: EmbeddedViewData) {
        if let selectedPlacemet = placements?[placement.targetElement] {
            callOnRoktEvent(executeId, event: RoktEvent.PlacementReady(placementId: placement.placementId))
            selectedPlacemet.loadEmbeddedPlacement(
                loadData: EmbeddedPlacementLoadData(sessionId: sessionId, placement: placement),
                onLoad: { [weak self] in
                    self?.callOnLoad(executeId)
                    self?.callOnRoktEvent(executeId,
                                          event: RoktEvent.PlacementInteractive(placementId: placement.placementId))
                },
                onUnLoad: {[weak self] completionType in
                    self?.sendCompletionEvent(executeId: executeId,
                                              placementId: placement.placementId,
                                              completionType: completionType)
                    self?.callOnUnLoad(executeId)
                },
                onEmbeddedSizeChange: {[weak self] selectedPlacementName, widgetHeight in
                    self?.callOnEmbeddedSizeChange(executeId,
                                                   selectedPlacementName: selectedPlacementName,
                                                   widgetHeight: widgetHeight)
                },
                on2stepEvent: {[weak self] event, eventHandler in
                    self?.callOn2stepEvent(executeId, event: event,
                                           eventHandler: eventHandler,
                                           placementId: placement.placementId)
                })

        } else {
            RoktAPIHelper.sendDiagnostics(message: kAPIExecuteErrorCode, callStack: kEmbeddedLayoutDoesntExistMessage
                                            + placement.targetElement + kLocationDoesNotExist, sessionId: sessionId)
            Log.i("Rokt: Embedded layout doesn't exist")
            self.postExecuteFailureHandler(executeId, placementId: placement.placementId, sessionId: sessionId)
            self.callOnUnLoad(executeId)
        }
    }

    private func sendCompletionEvent(executeId: String,
                                     placementId: String,
                                     completionType: PlacementCompletionType) {
        switch completionType {
        case .PlacementClosed:
            self.callOnRoktEvent(executeId, event: RoktEvent.PlacementClosed(placementId: placementId))
        case .PlacementCompleted:
            self.callOnRoktEvent(executeId, event: RoktEvent.PlacementCompleted(placementId: placementId))
        default:
            self.callOnRoktEvent(executeId, event: RoktEvent.PlacementFailure(placementId: placementId))
        }
    }

    private func getStoryboard() -> UIStoryboard {
        let podBundle = Bundle(for: Rokt.self)

        let bundleURL = podBundle.url(forResource: kBundleName, withExtension: kBundleExtension)
        let bundle = Bundle(url: bundleURL!)
        return UIStoryboard.init(name: kStoryboardName, bundle: bundle)
    }

    // Determines and schedules the appropriate time to show the widget
    private func show(_ payload: ExecutePayload) {
        var fireDate = defaultDelayTimer?.fireDate
        if let timer = defaultDelayTimer {
            if !timer.isValid {
                fireDate = defaultDelayTimerLastFireDate
            }
        }
        if let timeDifference = fireDate?.timeIntervalSinceNow,
           let delay = getLaunchDelay(payload: payload) {
            // Doesn't matter if the timer fired or not, we no longer care about the default launch delay
            defaultDelayTimer?.invalidate()
            var elapsedTime = defaultLaunchDelayMilliseconds - timeDifference * 1000
            if timeDifference < 0 {
                // If the timer has fired, timeDifference is negative
                elapsedTime = defaultLaunchDelayMilliseconds + timeDifference * -1000
            }
            // todo check delay type
            if Double(delay) > elapsedTime {
                let timeToShow = Double(delay) - elapsedTime
                Timer.scheduledTimer(timeInterval: timeToShow / 1000,
                                     target: self,
                                     selector: #selector(showTimerDone(timer:)),
                                     userInfo: payload,
                                     repeats: false)
            } else {
                showNow(payload: payload)
            }
        } else {
            showNow(payload: payload)
        }
    }

    private static func setSharedItems(_ topController: UIViewController?, attributes: [String: String],
                                       onLoad: (() -> Void)?, onUnLoad: (() -> Void)?,
                                       onShouldShowLoadingIndicator: (() -> Void)?,
                                       onShouldHideLoadingIndicator: (() -> Void)?,
                                       onEmbeddedSizeChange: ((String, CGFloat) -> Void)?,
                                       on2stepEvent: ((RoktEventType, RoktEventHandler) -> Void)?,
                                       onRoktEvent: ((RoktEvent) -> Void)?,
                                       config: RoktConfig?) {
        shared.displayController = topController
        shared.onLoad = onLoad
        shared.onUnLoad = onUnLoad
        shared.onShouldHideLoadingIndicator = onShouldHideLoadingIndicator
        shared.onEmbeddedSizeChange = onEmbeddedSizeChange
        shared.on2stepEvent = on2stepEvent
        shared.roktEvent = onRoktEvent
        shared.attributes = attributes
        shared.defaultDelayTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(shared.defaultLaunchDelayMilliseconds / 1000),
            target: shared, selector: #selector(defaultTimerDone(timer:)), userInfo: nil, repeats: false)
        shared.processedEvents = ProcessedEventViewModel()
        shared.fontDiagnostics = FontDiagnosticsViewModel()
        shared.roktConfig = config
    }

    @available(iOS 14.5, *)
    private static func isPrivacyDenied(_ status: ATTrackingManager.AuthorizationStatus) -> Bool {
        return status == .denied || status == .restricted
    }

    private static func sendDiagnostics(_ message: String, error: Error, statusCode: Int?, response: String) {
        let callStack = "response: \(response) ,statusCode: \(String(describing: statusCode))" +
            " ,error: \(error.localizedDescription)"
        RoktAPIHelper.sendDiagnostics(message: message, callStack: callStack)
        Log.d(callStack)
    }

    private func getLaunchDelay(payload: ExecutePayload) -> Double? {
        if let page = payload.placementPage {
            let delay = page.placements?.map({ (d: PlacementViewData) -> Int in
                d.launchDelayMilliseconds ?? -1
            }).max()
            return delay != nil && delay != -1 ? Double(delay!) : nil
        }
        return 0
    }

    private func initialStateBag() -> String {
        let executeId = UUID().uuidString
        stateBags[executeId] = ExecuteStateBag(loadedPlacements: 0,
                                               onLoad: onLoad,
                                               onUnLoad: onUnLoad,
                                               onEmbeddedSizeChange: onEmbeddedSizeChange,
                                               on2stepEvent: on2stepEvent,
                                               onRoktEvent: roktEvent)
        return executeId
    }

    private func callOnLoad(_ executeId: String) {
        if let stateBag = stateBags[executeId] {
            if stateBag.loadedPlacements == 0 {
                stateBag.onLoad?()
            }
            stateBags[executeId]?.loadedPlacements += 1
        }
    }
    private func callOnUnLoad(_ executeId: String) {
        if let stateBag = stateBags[executeId] {
            stateBags[executeId]?.loadedPlacements -= 1
            if stateBags[executeId]?.loadedPlacements ?? 0 <= 0 {
                stateBag.onUnLoad?()
                stateBags.removeValue(forKey: executeId)
                clearCallBacks()
            }
        }
    }

    private func callOnEmbeddedSizeChange(_ executeId: String,
                                          selectedPlacementName: String,
                                          widgetHeight: CGFloat) {
        if let stateBag = stateBags[executeId] {
            stateBag.onEmbeddedSizeChange?(selectedPlacementName, widgetHeight)
        }
    }

    private func callOn2stepEvent(_ executeId: String,
                                  event: RoktEventType,
                                  eventHandler: RoktEventHandler,
                                  placementId: String?) {
        if let stateBag = stateBags[executeId] {
            stateBag.on2stepEvent?(event, eventHandler)
            if event == .FirstPositiveEngagement {
                stateBag.onRoktEvent?(eventHandler.getRoktEvent(placementId: placementId))
            }
        }
    }

    private func callOnRoktEvent(_ executeId: String,
                                 event: RoktEvent) {
        if let stateBag = stateBags[executeId] {
            stateBag.onRoktEvent?(event)
        }
    }
    
    private func postExecuteFailureHandler(_ executeId: String,
                                           placementId: String? = nil,
                                           sessionId: String) {
        // handle timings and event
        Rokt.shared.processedTimingsRequests?.processTimingsRequest(sessionId: sessionId)
        self.callOnRoktEvent(executeId, event: RoktEvent.PlacementFailure(placementId: placementId))
    }

    private func conclude(withFailure: Bool = false, sessionId: String? = nil) {
        defaultDelayTimer?.invalidate()
        onShouldHideLoadingIndicator?()
        roktEvent?(RoktEvent.HideLoadingIndicator())

        if withFailure {
            Rokt.shared.processedTimingsRequests?.processTimingsRequest(sessionId: sessionId)
            roktEvent?(RoktEvent.PlacementFailure(placementId: nil))
        }

        onUnLoad?()
        clearCallBacks()
    }

    internal func clearCallBacks() {
        placements = nil
        displayController = nil
        onLoad = nil
        onUnLoad = nil
        onShouldHideLoadingIndicator = nil
        onEmbeddedSizeChange = nil
        on2stepEvent = nil
        roktEvent = nil
    }

    private func sendPageIntialEvents(
        sessionId: String,
        pageInstanceGuid: String,
        startDate: Date,
        responseReceivedDate: Date,
        jwtToken: String
    ) {
        RoktAPIHelper.sendEvent(evenRequest:
                                    EventRequest(sessionId: sessionId, eventType: EventType.SignalInitialize,
                                                 parentGuid: pageInstanceGuid, eventTime: startDate,
                                                 jwtToken: jwtToken))
        RoktAPIHelper.sendEvent(evenRequest:
                                    EventRequest(sessionId: sessionId, eventType: EventType.SignalLoadStart,
                                                 parentGuid: pageInstanceGuid, eventTime: startDate,
                                                 jwtToken: jwtToken))
        RoktAPIHelper.sendEvent(evenRequest:
                                    EventRequest(sessionId: sessionId, eventType: EventType.SignalLoadComplete,
                                                 parentGuid: pageInstanceGuid, eventTime: responseReceivedDate,
                                                 jwtToken: jwtToken))

    }

    // Default show delay timeout done
    @objc private func defaultTimerDone(timer: Timer) {
        defaultDelayTimerLastFireDate = timer.fireDate
    }

    // Widget show delay timer done
    @objc private func showTimerDone(timer: Timer) {
        if let payload = timer.userInfo as? ExecutePayload {
            showNow(payload: payload)
        }
    }

    @objc private static func sentEventToListeners(viewName: String?,
                                                   roktEvent: RoktEvent) {
        if let viewName,
           let eventListener = shared.roktEventMap[viewName] {
            eventListener?(roktEvent)
        }
    }

    // MARK: - Rokt public functions
    /// Rokt developer facing initializer. Sets default launch delay and API timeout
    ///
    /// - Parameters:
    ///   - roktTagId: The tag id provided by Rokt, associated with your account.
    @objc public static func initWith(roktTagId: String) {
        let initStartTime = DateHandler.currentDate()

        shared.roktTagId = roktTagId
        // reset executeSession on init
        shared.executeSession = nil
        shared.isInitFailedForFont = false
        shared.stateBags = [:]

        NotificationCenter.default.removeObserver(shared)
        NotificationCenter.default.addObserver(shared, selector: #selector(startedLoadingFonts(notification:)),
                                               name: NSNotification.Name(kDownloadingFonts), object: nil)
        NotificationCenter.default.addObserver(shared, selector: #selector(finishedLoadingFonts(notification:)),
                                               name: NSNotification.Name(kFinishedDownloadingFonts), object: nil)
        RoktAPIHelper.initialize(roktTagId: roktTagId,
                                 success: { (initResponse) in
            shared.isInitialized = true
            shared.initFeatureFlags = initResponse.featureFlags
            
            if shared.initFeatureFlags.isEnabled(.timingsEnabled) {
                shared.processedTimingsRequests = ProcessedTimingsRequestViewModel()
                shared.processedTimingsRequests?.setInitStartTime(initStartTime)
            }
            
            shared.clientTimeoutMilliseconds = initResponse.timeout != 0 ?
            initResponse.timeout : shared.clientTimeoutMilliseconds
            shared.defaultLaunchDelayMilliseconds = initResponse.delay != 0 ? 
            initResponse.delay : shared.defaultLaunchDelayMilliseconds
            if let clientSessionTimeout = initResponse.clientSessionTimeout {
                shared.clientSessionTimeoutMilliseconds = clientSessionTimeout
            }

            NetworkingHelper.updateTimeout(timeout: shared.clientTimeoutMilliseconds / 1000)
            FontManager.removeUnusedFonts(fonts: initResponse.fonts)
            RoktAPIHelper.downloadFonts(initResponse.fonts)
        }, failure: { (error, statusCode, response) in
            Log.i("Rokt: Initialize failed")
            shared.isInitialized = false
            shared.processedTimingsRequests?.setInitEndTime()
            sendDiagnostics(kAPIInitErrorCode, error: error, statusCode: statusCode, response: response)
        })
    }

    // swiftlint:disable function_body_length
    /// Rokt developer facing execute
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - attributes: A string dictionary containing the parameters that should be displayed in the widget
    ///   - onLoad: Function to execute right after the widget is successfully loaded and displayed
    ///   - onUnLoad: Function to execute right after widget is unloaded, there is no widget or there is an exception
    ///   - onShouldShowLoadingIndicator: Function to execute when the loading indicator should be shown
    ///   - onShouldHideLoadingIndicator: Function to execute when the loading indicator should be hidden
    @objc private static func Execute(viewName: String? = nil,
                                      attributes: [String: String],
                                      placements: [String: RoktEmbeddedView]? = nil,
                                      config: RoktConfig?,
                                      onLoad: (() -> Void)? = nil,
                                      onUnLoad: (() -> Void)? = nil,
                                      onShouldShowLoadingIndicator: (() -> Void)? = nil,
                                      onShouldHideLoadingIndicator: (() -> Void)? = nil,
                                      onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil,
                                      on2stepEvent: ((RoktEventType, RoktEventHandler) -> Void)? = nil,
                                      onRoktEvent: ((RoktEvent) -> Void)? = nil) {

        func preExecuteFailureHandler() {
            shared.processedTimingsRequests?.setSelectionEndTime()
            shared.processedTimingsRequests?.processTimingsRequest()
            onShouldHideLoadingIndicator?()
            onRoktEvent?(RoktEvent.HideLoadingIndicator())
            onUnLoad?()
            onRoktEvent?(RoktEvent.PlacementFailure(placementId: nil))
            RoktAPIHelper.sendDiagnostics(message: kNotInitializedCode, 
                                          callStack: shared.isInitFailedForFont ? kFontFailedError : kInitFailedError,
                                          severity: .info)
        }
        
        func onExperiencesRequestStart() {
            shared.processedTimingsRequests?.setExperiencesRequestStartTime()
        }
        
        func onExperiencesRequestEnd() {
            shared.processedTimingsRequests?.setExperiencesRequestEndTime()
            shared.processedTimingsRequests?.setSelectionEndTime()
        }
        
        shared.processedTimingsRequests?.resetTimingsOnExecute()
        shared.processedTimingsRequests?.setSelectionStartTime()
        if shared.isExecuting || !shared.isInitialized {
            Log.i("Rokt: Execute is already running")
            preExecuteFailureHandler()
            return
        }
        var trackingConsent: UInt?
        if #available(iOS 14.5, *) {
            if !shared.initFeatureFlags.isEnabled(.roktTrackingStatus) &&
                isPrivacyDenied(ATTrackingManager.trackingAuthorizationStatus) {
                RoktAPIHelper.sendDiagnostics(message: kTrackErrorCode, callStack: kTrackError, severity: .warning)
                preExecuteFailureHandler()
                return
            }
            trackingConsent = ATTrackingManager.trackingAuthorizationStatus.rawValue
        }

        shared.isExecuting = true
        shared.placements = placements
        let startDate = Date()
        if let tagId = shared.roktTagId, let topController = UIApplication.topViewController() {
            onShouldShowLoadingIndicator?()
            onRoktEvent?(RoktEvent.ShowLoadingIndicator())
            setSharedItems(topController, attributes: attributes, onLoad: onLoad, onUnLoad: onUnLoad,
                           onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                           onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                           onEmbeddedSizeChange: onEmbeddedSizeChange, on2stepEvent: on2stepEvent,
                           onRoktEvent: onRoktEvent, config: config)

            if #available(iOS 15, *) {
                FontManager.reRegisterFonts {
                    RoktAPIHelper.getExperienceData(
                        viewName: viewName,
                        attributes: attributes,
                        roktTagId: tagId,
                        trackingConsent: trackingConsent, 
                        config: config,
                        onRequestStart: onExperiencesRequestStart,
                        successPlacement: { page in
                            onExperiencesRequestEnd()
                            shared.isExecuting = false

                            guard let page else {
                                shared.conclude(withFailure: true)
                                return
                            }
                            
                            shared.processedTimingsRequests?.setPageProperties(
                                pageId: page.pageId, pageInstanceGuid: page.pageInstanceGuid)

                            // if there is valid page, send initial events
                            let responseReceivedDate = Date()
                            page.setResponseReceivedDate(receivedDate: responseReceivedDate)
                            shared.sendPageIntialEvents(sessionId: page.sessionId,
                                                        pageInstanceGuid: page.pageInstanceGuid,
                                                        startDate: startDate,
                                                        responseReceivedDate: responseReceivedDate,
                                                        jwtToken: page.placementContextJWTToken)
                            page.setStartDate(startDate: startDate)

                            shared.executeSession = ExecuteSession(sessionId: page.sessionId,
                                                                   expiry: shared.clientSessionTimeoutMilliseconds)

                            guard page.placements != nil else {
                                shared.conclude(withFailure: true, sessionId: page.sessionId)
                                return
                            }
                            shared.processedTimingsRequests?.setSelectionEndTime()
                            let payload = ExecutePayload(placementPage: page, layoutPage: nil)
                            shared.show(payload)
                        },
                        successLayout: { page in
                            onExperiencesRequestEnd()
                            shared.isExecuting = false

                            guard var page else {
                                shared.conclude(withFailure: true)
                                return
                            }
                            
                            shared.processedTimingsRequests?.setPageProperties(
                                pageId: page.pageId, pageInstanceGuid: page.pageInstanceGuid)

                            // if there is valid page, send initial events at page-level
                            page.responseReceivedDate = Date()
                            shared.sendPageIntialEvents(sessionId: page.sessionId,
                                                        pageInstanceGuid: page.pageInstanceGuid,
                                                        startDate: startDate,
                                                        responseReceivedDate: page.responseReceivedDate,
                                                        jwtToken: page.placementContextJWTToken)
                            page.startDate = startDate

                            shared.executeSession = ExecuteSession(sessionId: page.sessionId,
                                                                   expiry: shared.clientSessionTimeoutMilliseconds)
                            shared.processedTimingsRequests?.setSelectionEndTime()
                            let payload = ExecutePayload(placementPage: nil, layoutPage: page)
                            shared.show(payload)
                        },
                        failure: { (error, statusCode, response) in
                            onExperiencesRequestEnd()
                            executeFailureHandler(error, statusCode, response)
                        }
                    )}
            } else {
                FontManager.reRegisterFonts {
                    RoktAPIHelper.getPlacement(
                        viewName: viewName,
                        attributes: attributes,
                        roktTagId: tagId,
                        trackingConsent: trackingConsent,
                        success: { page in
                            shared.isExecuting = false

                            guard let page else {
                                shared.conclude(withFailure: true)
                                return
                            }

                            // if there is valid page, send initial events
                            let responseReceivedDate = Date()
                            page.setResponseReceivedDate(receivedDate: responseReceivedDate)
                            shared.sendPageIntialEvents(sessionId: page.sessionId,
                                                        pageInstanceGuid: page.pageInstanceGuid,
                                                        startDate: startDate,
                                                        responseReceivedDate: responseReceivedDate,
                                                        jwtToken: page.placementContextJWTToken)
                            page.setStartDate(startDate: startDate)

                            guard page.placements != nil else {
                                shared.conclude(withFailure: true)
                                return
                            }

                            let payload = ExecutePayload(placementPage: page, layoutPage: nil)
                            shared.show(payload)
                        },
                        failure: executeFailureHandler(_:_:_:)
                    )
                }
            }
        } else {
            shared.processedTimingsRequests?.processTimingsRequest()
            shared.isExecuting = false
            Log.d(StringHelper.localizedStringFor(kInitBeforeDoKey, comment: kInitBeforeDoComment))
            onUnLoad?()
            onRoktEvent?(RoktEvent.PlacementFailure(placementId: nil))
            shared.clearCallBacks()
            Log.i("Rokt: SDK is not initialized")
            RoktAPIHelper.sendDiagnostics(message: kNotInitializedCode,
                                          callStack: shared.isInitFailedForFont ? kFontFailedError : kInitFailedError,
                                          severity: .info)
        }
    }
    // swiftlint:enable function_body_length

    // For SwiftUI integrations
    @available(iOS 15, *)
    internal static func execute(viewName: String? = nil,
                                 attributes: [String: String],
                                 layout: RoktLayout? = nil,
                                 config: RoktConfig? = nil,
                                 onLoad: (() -> Void)? = nil,
                                 onUnLoad: (() -> Void)? = nil,
                                 onShouldShowLoadingIndicator: (() -> Void)? = nil,
                                 onShouldHideLoadingIndicator: (() -> Void)? = nil,
                                 onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil,
                                 onRoktEvent: ((RoktEvent) -> Void)? = nil) {
        shared._executeLayout = layout
        Execute(viewName: viewName,
                attributes: attributes,
                config: config,
                onLoad: onLoad,
                onUnLoad: onUnLoad,
                onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                onEmbeddedSizeChange: onEmbeddedSizeChange,
                onRoktEvent: {roktEvent in
            onRoktEvent?(roktEvent)
            sentEventToListeners(viewName: viewName, roktEvent: roktEvent)
        })
    }

    fileprivate static func executeFailureHandler(_ error: Error, _ statusCode: Int?, _ response: String) {
        shared.isExecuting = false
        sendDiagnostics(kAPIExecuteErrorCode, error: error, statusCode: statusCode, response: response)
        shared.conclude(withFailure: true)
    }

    // MARK: public APIs
    
    /// Rokt developer facing execute
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - attributes: A string dictionary containing the parameters that should be displayed in the widget
    ///   - placements: A dictionary of RoktEmbeddedViews with their names
    ///   - onLoad: Function to execute right after the widget is successfully loaded and displayed
    ///   - onUnLoad: Function to execute right after widget is unloaded, there is no widget or there is an exception
    ///   - onShouldShowLoadingIndicator: Function to execute when the loading indicator should be shown
    ///   - onShouldHideLoadingIndicator: Function to execute when the loading indicator should be hidden
    ///   - onEmbeddedSizeChange: Function to execute when size of embeddedView change, the first item is selected
    ///   Placement and second item is widget height

    @objc public static func execute(viewName: String? = nil,
                                     attributes: [String: String],
                                     placements: [String: RoktEmbeddedView]? = nil,
                                     onLoad: (() -> Void)? = nil,
                                     onUnLoad: (() -> Void)? = nil,
                                     onShouldShowLoadingIndicator: (() -> Void)? = nil,
                                     onShouldHideLoadingIndicator: (() -> Void)? = nil,
                                     onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil) {
        execute(viewName: viewName,
                attributes: attributes,
                placements: placements,
                config: nil,
                onLoad: onLoad,
                onUnLoad: onUnLoad,
                onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                onEmbeddedSizeChange: onEmbeddedSizeChange)
    }
    
    /// Rokt developer facing execute
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - attributes: A string dictionary containing the parameters that should be displayed in the widget
    ///   - placements: A dictionary of RoktEmbeddedViews with their names
    ///   - config: An object which defines RoktConfig
    ///   - onLoad: Function to execute right after the widget is successfully loaded and displayed
    ///   - onUnLoad: Function to execute right after widget is unloaded, there is no widget or there is an exception
    ///   - onShouldShowLoadingIndicator: Function to execute when the loading indicator should be shown
    ///   - onShouldHideLoadingIndicator: Function to execute when the loading indicator should be hidden
    ///   - onEmbeddedSizeChange: Function to execute when size of embeddedView change, the first item is selected
    ///   Placement and second item is widget height
    @objc public static func execute(viewName: String? = nil,
                                     attributes: [String: String],
                                     placements: [String: RoktEmbeddedView]? = nil,
                                     config: RoktConfig? = nil,
                                     onLoad: (() -> Void)? = nil,
                                     onUnLoad: (() -> Void)? = nil,
                                     onShouldShowLoadingIndicator: (() -> Void)? = nil,
                                     onShouldHideLoadingIndicator: (() -> Void)? = nil,
                                     onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil) {
        Execute(viewName: viewName,
                attributes: attributes,
                placements: placements,
                config: config,
                onLoad: onLoad,
                onUnLoad: onUnLoad,
                onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                onEmbeddedSizeChange: onEmbeddedSizeChange,
                onRoktEvent: {roktEvent in
            sentEventToListeners(viewName: viewName, roktEvent: roktEvent)
        })
    }

    /// Rokt developer facing execute
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - attributes: A string dictionary containing the parameters that should be displayed in the widget
    ///   - placements: A dictionary of RoktEmbeddedViews with their names
    ///   - onLoad: Function to execute right after the widget is successfully loaded and displayed
    ///   - onUnLoad: Function to execute right after widget is unloaded, there is no widget or there is an exception
    ///   - onShouldShowLoadingIndicator: Function to execute when the loading indicator should be shown
    ///   - onShouldHideLoadingIndicator: Function to execute when the loading indicator should be hidden
    ///   - onEmbeddedSizeChange: Function to execute when size of embeddedView change, the first item is selected
    ///   Placement and second item is widget height
    ///   - onEvent: Function to execute when some events triggered, the first item is eventType  and
    ///   second is eventHandler
    @objc public static func execute2step(viewName: String? = nil,
                                          attributes: [String: String],
                                          placements: [String: RoktEmbeddedView]? = nil,
                                          onLoad: (() -> Void)? = nil,
                                          onUnLoad: (() -> Void)? = nil,
                                          onShouldShowLoadingIndicator: (() -> Void)? = nil,
                                          onShouldHideLoadingIndicator: (() -> Void)? = nil,
                                          onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil,
                                          onEvent: ((RoktEventType, RoktEventHandler) -> Void)? = nil) {
        execute2step(viewName: viewName,
                attributes: attributes,
                placements: placements,
                config: nil,
                onLoad: onLoad, onUnLoad: onUnLoad,
                onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                onEmbeddedSizeChange: onEmbeddedSizeChange,
                onEvent: onEvent)
    }
    
    /// Rokt developer facing execute
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - attributes: A string dictionary containing the parameters that should be displayed in the widget
    ///   - placements: A dictionary of RoktEmbeddedViews with their names
    ///   - config: An object which defines RoktConfig
    ///   - onLoad: Function to execute right after the widget is successfully loaded and displayed
    ///   - onUnLoad: Function to execute right after widget is unloaded, there is no widget or there is an exception
    ///   - onShouldShowLoadingIndicator: Function to execute when the loading indicator should be shown
    ///   - onShouldHideLoadingIndicator: Function to execute when the loading indicator should be hidden
    ///   - onEmbeddedSizeChange: Function to execute when size of embeddedView change, the first item is selected
    ///   Placement and second item is widget height
    ///   - onEvent: Function to execute when some events triggered, the first item is eventType  and
    ///   second is eventHandler
    @objc public static func execute2step(viewName: String? = nil,
                                          attributes: [String: String],
                                          placements: [String: RoktEmbeddedView]? = nil,
                                          config: RoktConfig? = nil,
                                          onLoad: (() -> Void)? = nil,
                                          onUnLoad: (() -> Void)? = nil,
                                          onShouldShowLoadingIndicator: (() -> Void)? = nil,
                                          onShouldHideLoadingIndicator: (() -> Void)? = nil,
                                          onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil,
                                          onEvent: ((RoktEventType, RoktEventHandler) -> Void)? = nil) {
        Execute(viewName: viewName,
                attributes: attributes,
                placements: placements,
                config: config,
                onLoad: onLoad, onUnLoad: onUnLoad,
                onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                onEmbeddedSizeChange: onEmbeddedSizeChange,
                on2stepEvent: onEvent,
                onRoktEvent: {roktEvent in
            sentEventToListeners(viewName: viewName, roktEvent: roktEvent)
        })
    }

    /// Rokt developer facing execute
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - attributes: A string dictionary containing the parameters that should be displayed in the widget
    ///   - placements: A dictionary of RoktEmbeddedViews with their names
    ///   - onEvent: Function to execute when some events triggered, the first item is RoktEvent
    ///   - onEmbeddedSizeChange: Function to execute when size of embeddedView change, the first item is selected
    ///   Placement and second item is widget height
    @objc public static func executeWithEvents(viewName: String? = nil,
                                               attributes: [String: String],
                                               placements: [String: RoktEmbeddedView]? = nil,
                                               onEvent: ((RoktEvent) -> Void)? = nil,
                                               onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil) {
        executeWithEvents(viewName: viewName,
                          attributes: attributes,
                          placements: placements,
                          config: nil,
                          onEvent: onEvent,
                          onEmbeddedSizeChange: onEmbeddedSizeChange)
    }
    
    /// Rokt developer facing execute
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - attributes: A string dictionary containing the parameters that should be displayed in the widget
    ///   - placements: A dictionary of RoktEmbeddedViews with their names
    ///   - config: An object which defines RoktConfig
    ///   - onEvent: Function to execute when some events triggered, the first item is RoktEvent
    ///   - onEmbeddedSizeChange: Function to execute when size of embeddedView change, the first item is selected
    ///   Placement and second item is widget height
    @objc public static func executeWithEvents(viewName: String? = nil,
                                               attributes: [String: String],
                                               placements: [String: RoktEmbeddedView]? = nil,
                                               config: RoktConfig? = nil,
                                               onEvent: ((RoktEvent) -> Void)? = nil,
                                               onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil) {
        Execute(viewName: viewName,
                attributes: attributes,
                placements: placements,
                config: config,
                onEmbeddedSizeChange: onEmbeddedSizeChange,
                onRoktEvent: {roktEvent in
            onEvent?(roktEvent)
            sentEventToListeners(viewName: viewName, roktEvent: roktEvent)
        })
        
    }
    
    /// Rokt developer facing close for overlay, lightbox, bottomsheet
    @objc public static func close() {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
              let rootViewController = window.rootViewController
        else {
            return
        }
        if let roktVC = rootViewController.presentedViewController as? RoktViewController {
            roktVC.closeModal()
        }

        if #available(iOS 15.0, *),
           let roktVC = rootViewController.presentedViewController as? SwiftUIViewController {
            roktVC.closeModal()
            // close modal
        }
    }

    // Enable or disable Log
    @objc public static func setLoggingEnabled(enable: Bool) {
        shared.debugLogEnabled = enable
    }

    @objc public static func setEnvironment(environment: RoktEnvironment) {
        config = Configuration(environment: Configuration.getEnvironment(environment))
    }

    /// Rokt developer facing events subscription
    ///
    /// - Parameters:
    ///   - viewName: The name that should be displayed in the widget
    ///   - onEvent: Function to execute when some events triggered, the first item is RoktEvent
    @objc public static func events(viewName: String,
                                    onEvent: ((RoktEvent) -> Void)?) {
        shared.roktEventMap[viewName] = onEvent
    }
}

struct ExecutePayload {
    let placementPage: PageViewData?
    let layoutPage: PageModel?
}

struct Log {
    /// Prints in build and stage only
    static func d(_ msg: String, line: Int = #line, fileName: String = #file, funcName: String = #function) {
        if let configuration = Bundle(for: Rokt.self).object(forInfoDictionaryKey: "Configuration") as? String {
            if configuration.contains("STAGE") ||
                configuration.contains("MOCK") ||
                config.environment == .Local ||
                config.environment == .Stage {
                let fname = (fileName as NSString).lastPathComponent
                print("[\(fname) \(funcName):\(line)]", msg)
            }
        }
    }
    /// Prints in debug only if debug enabled
    static func i(_ msg: String) {
        if Rokt.shared.debugLogEnabled {
            debugPrint(msg)
        }
    }

    /// Prints an error message in debug only
    static func error(_ msg: String, line: Int = #line, fileName: String = #file, funcName: String = #function) {
        d("ERROR: \(msg)!!", line: line, fileName: fileName, funcName: funcName)
    }
}

