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
    private var onShouldShowLoadingIndicator: (() -> Void)?
    private var onShouldHideLoadingIndicator: (() -> Void)?
    private var onEmbeddedSizeChange: ((String, CGFloat) -> Void)?
    private var onEvent: ((RoktEventType, RoktEventHandler) -> Void)?
    private var clientTimeoutMilliseconds: Double = defaultTimeout
    private var defaultLaunchDelayMilliseconds: Double = defaultDelay
    private var clientSessionTimeoutMilliseconds: Double = defaultSessionExpiry
    private var defaultDelayTimer: Timer?
    private var defaultDelayTimerLastFireDate: Date?
    internal var attributes = [String: String]()
    private var loadingFonts = false
    internal var isInitialized = false
    private var roktTrackingStatus = true
    private var pendingPayload: ExecutePayload?
    private var isExecuting = false
    private var placements: [String: RoktEmbeddedView]?
    internal var debugLogEnabled: Bool = false
    // to hold RoktLayout for SwiftUI integration
    private var _executeLayout: Any?
    @available(iOS 15.0, *)
    private var executeLayout: RoktLayout? {
        return _executeLayout as? RoktLayout
    }
    
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
            showNow(layoutPage: layoutPage)
        }
    }
    
    @available(iOS 15, *)
    private func showNow(layoutPage: PageModel) {
        pendingPayload = nil
        onShouldHideLoadingIndicator?()
        let executeId = initialStateBag()
        if let layoutPlugins = layoutPage.layoutPlugins {
            for layoutPlugin in layoutPlugins {
                DCUIComponent().loadLayout(sessionId: layoutPage.sessionId,
                                           layoutPlugin: layoutPlugin,
                                           startDate: layoutPage.startDate,
                                           placements: placements,
                                           layout: executeLayout,
                                           onLoad: {[weak self] in self?.callOnLoad(executeId)},
                                           onUnLoad: {[weak self] in self?.callOnUnLoad(executeId)},
                                           onEmbeddedSizeChange: {[weak self] selectedPlacementName, widgetHeight in
                    self?.callOnEmbeddedSizeChange(executeId,
                                                   selectedPlacementName: selectedPlacementName,
                                                   widgetHeight: widgetHeight)
                },
                                           onEvent: {[weak self] event, eventHandler in
                    (self?.onEvent ?? {_, _ in})(event, eventHandler)
                })
            }
        } else {
            callOnUnLoad(executeId)
        }
        displayController = nil
        placements = nil
        _executeLayout = nil
    }
    
    private func showNow(placementPage: PageViewData) {
        pendingPayload = nil
        onShouldHideLoadingIndicator?()
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
                        self.callOnUnLoad(executeId)
                    }
                case .embeddedLayout:
                    // embedded
                    if let embeddedPlacement = placement as? EmbeddedViewData {
                        loadEmbeddedWidget(placementPage.sessionId, executeId: executeId, placement: embeddedPlacement)
                    } else {
                        RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode, callStack: kLayoutDoesNotMatch,
                                                      sessionId: placementPage.sessionId)
                        self.callOnUnLoad(executeId)
                    }
                default:
                    //not supported
                    RoktAPIHelper.sendDiagnostics(message: kValidationErrorCode, callStack: kLayoutDoesNotSupported,
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
        let podBundle = Bundle(for: Rokt.self)
        
        let bundleURL = podBundle.url(forResource: kBundleName, withExtension: kBundleExtension)
        let bundle = Bundle(url: bundleURL!)
        let board = UIStoryboard.init(name: kStoryboardName, bundle: bundle)
        var isOverlay = layoutCode == .overlayLayout
        if layoutCode == .bottomSheetLayout {
            if #available(iOS 15.0, *) {
                isOverlay = false
            } else {
                // fallback to overlay
                isOverlay = true
            }
        }
        if let roktViewController = board.instantiateViewController(withIdentifier: kRoktCIdentifier)
            as? RoktViewController {
            roktViewController.initializeRoktViewController(sessionId: sessionId, placement: placement,
                                                            isOverlay: isOverlay,
                                                            onUnLoad: {[weak self] in self?.callOnUnLoad(executeId)},
                                                            onEvent: {[weak self] event, eventHandler in
                                                                (self?.onEvent ?? {_, _ in})(event, eventHandler)})
            
            if layoutCode == .bottomSheetLayout,
                      #available(iOS 15.0, *) {
                roktViewController.modalPresentationStyle = .pageSheet
                if placement.bottomSheetExpandable {
                    roktViewController.sheetPresentationController?.detents = [.medium(), .large()]
                } else {
                    roktViewController.sheetPresentationController?.detents = [.medium()]
                }
                if !placement.bottomSheetDismissible {
                    roktViewController.isModalInPresentation = true
                }
                
            } else if layoutCode != .lightboxLayout {
                // overlay or (bottomsheet and below iOS 15)
                roktViewController.modalPresentationStyle = .overFullScreen
                roktViewController.modalTransitionStyle = .crossDissolve
            }
            // Prevent multiple presentations
            if displayController?.presentedViewController == nil {
                displayController?.present(roktViewController, animated: true, completion: { [weak self] in
                    self?.callOnLoad(executeId)
                })
            } else {
                RoktAPIHelper.sendDiagnostics(
                    message: kModalPlacementCallErrorCode,
                    callStack: kModalAlreadyExists,
                    sessionId: sessionId
                )
            }
        } else {
            self.callOnUnLoad(executeId)
        }
    }
    
    private func loadEmbeddedWidget(_ sessionId: String,
                                    executeId: String,
                                    placement: EmbeddedViewData) {
        if let selectedPlacemet = placements?[placement.targetElement] {
            selectedPlacemet.loadEmbeddedPlacement(
                sessionId: sessionId, placement: placement, onLoad: {
                    [weak self] in self?.callOnLoad(executeId)},
                onUnLoad: {
                    [weak self] in self?.callOnUnLoad(executeId)},
                onEmbeddedSizeChange: {[weak self] selectedPlacementName, widgetHeight in
                    self?.callOnEmbeddedSizeChange(executeId,
                                                   selectedPlacementName: selectedPlacementName,
                                                   widgetHeight: widgetHeight)
                },
                onEvent: {[weak self] event, eventHandler in
                    (self?.onEvent ?? {_, _ in})(event, eventHandler)
                })
            
        } else {
            RoktAPIHelper.sendDiagnostics(message: kAPIExecuteErrorCode, callStack: kEmbeddedLayoutDoesntExistMessage
                + placement.targetElement + kLocationDoesNotExist, sessionId: sessionId)
            self.callOnUnLoad(executeId)
        }
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
                                       onEvent: ((RoktEventType, RoktEventHandler) -> Void)?) {
        shared.displayController = topController
        shared.onLoad = onLoad
        shared.onUnLoad = onUnLoad
        shared.onShouldShowLoadingIndicator = onShouldShowLoadingIndicator
        shared.onShouldHideLoadingIndicator = onShouldHideLoadingIndicator
        shared.onEmbeddedSizeChange = onEmbeddedSizeChange
        shared.onEvent = onEvent
        shared.attributes = attributes
        shared.defaultDelayTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(shared.defaultLaunchDelayMilliseconds / 1000),
            target: shared, selector: #selector(defaultTimerDone(timer:)), userInfo: nil, repeats: false)
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
                                               onEmbeddedSizeChange: onEmbeddedSizeChange)
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
    
    private func conclude() {
        defaultDelayTimer?.invalidate()
        onShouldHideLoadingIndicator?()
        onUnLoad?()
        clearCallBacks()
    }
    
    internal func clearCallBacks() {
        placements = nil
        displayController = nil
        onLoad = nil
        onUnLoad = nil
        onShouldShowLoadingIndicator = nil
        onShouldHideLoadingIndicator = nil
        onEmbeddedSizeChange = nil
        onEvent = nil
    }
    
    private func sendPageIntialEvents(sessionId: String, pageInstanceGuid: String, startDate: Date) {
        RoktAPIHelper.sendEvent(evenRequest:
            EventRequest(sessionId: sessionId, eventType: EventType.SignalInitialize,
                         parentGuid: pageInstanceGuid, eventTime: startDate))
        RoktAPIHelper.sendEvent(evenRequest:
            EventRequest(sessionId: sessionId, eventType: EventType.SignalLoadStart,
                         parentGuid: pageInstanceGuid, eventTime: startDate))
        RoktAPIHelper.sendEvent(evenRequest:
            EventRequest(sessionId: sessionId, eventType: EventType.SignalLoadComplete,
                         parentGuid: pageInstanceGuid))
        
    }
    
    // Default show delay timeout done
    @objc private func defaultTimerDone(timer: Timer) {
        onShouldShowLoadingIndicator?()
        defaultDelayTimerLastFireDate = timer.fireDate
    }
    
    // Widget show delay timer done
    @objc private func showTimerDone(timer: Timer) {
        if let payload = timer.userInfo as? ExecutePayload {
            showNow(payload: payload)
        }
    }
    
    // MARK: - Rokt public functions
    /// Rokt developer facing initializer. Sets default launch delay and API timeout
    ///
    /// - Parameters:
    ///   - roktTagId: The tag id provided by Rokt, associated with your account.
    @objc public static func initWith(roktTagId: String) {
        print("Yes")
        shared.roktTagId = roktTagId
        // reset executeSession on init
        shared.executeSession = nil
        shared.stateBags = [:]
        NotificationCenter.default.removeObserver(shared)
        NotificationCenter.default.addObserver(shared, selector: #selector(startedLoadingFonts(notification:)),
                                               name: NSNotification.Name(kDownloadingFonts), object: nil)
        NotificationCenter.default.addObserver(shared, selector: #selector(finishedLoadingFonts(notification:)),
                                               name: NSNotification.Name(kFinishedDownloadingFonts), object: nil)
        RoktAPIHelper.initialize(roktTagId: roktTagId,
                                 success: { (timeout, delay, clientSessionTimeout, fonts, roktTrackingStatus) in
            shared.isInitialized = true
            shared.roktTrackingStatus = roktTrackingStatus
            shared.clientTimeoutMilliseconds = timeout != 0 ? timeout : shared.clientTimeoutMilliseconds
            shared.defaultLaunchDelayMilliseconds = delay != 0 ? delay : shared.defaultLaunchDelayMilliseconds
            if let clientSessionTimeout {
                shared.clientSessionTimeoutMilliseconds = clientSessionTimeout
            }
            
            NetworkingHelper.updateTimeout(timeout: shared.clientTimeoutMilliseconds / 1000)
            FontManager.removeUnusedFonts(fonts: fonts)
            RoktAPIHelper.downloadFonts(fonts)
            
        }, failure: { (error, statusCode, response) in
            shared.isInitialized = false
            sendDiagnostics(kAPIInitErrorCode, error: error, statusCode: statusCode, response: response)
        })
    }

    // swiftlint:disable function_body_length
    /// Rokt developer facing initializer
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
                                      onLoad: (() -> Void)? = nil,
                                      onUnLoad: (() -> Void)? = nil,
                                      onShouldShowLoadingIndicator: (() -> Void)? = nil,
                                      onShouldHideLoadingIndicator: (() -> Void)? = nil,
                                      onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil,
                                      onEvent: ((RoktEventType, RoktEventHandler) -> Void)? = nil) {
        if shared.isExecuting || !shared.isInitialized {
            Log.i(StringHelper.localizedStringFor(kExecuteIsRunningKey, comment: kExecuteIsRunningComment))
            onUnLoad?()
            return
        }
        var trackingConsent: UInt?
        if #available(iOS 14.5, *) {
            if !shared.roktTrackingStatus && isPrivacyDenied(ATTrackingManager.trackingAuthorizationStatus) {
                RoktAPIHelper.sendDiagnostics(message: kTrackErrorCode, callStack: kTrackError, severity: .warning)
                onUnLoad?()
                return
            }
            trackingConsent = ATTrackingManager.trackingAuthorizationStatus.rawValue
        }
        shared.isExecuting = true
        shared.placements = placements
        let startDate = Date()
        if let tagId = shared.roktTagId, let topController = UIApplication.topViewController() {
            setSharedItems(topController, attributes: attributes, onLoad: onLoad, onUnLoad: onUnLoad,
                           onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                           onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                           onEmbeddedSizeChange: onEmbeddedSizeChange, onEvent: onEvent)

            if #available(iOS 15, *) {
                RoktAPIHelper.getExperienceData(
                    viewName: viewName,
                    attributes: attributes,
                    roktTagId: tagId,
                    trackingConsent: trackingConsent,
                    successPlacement: { page in

                        shared.isExecuting = false

                        guard let page else {
                            shared.conclude()
                            return
                        }

                        // if there is valid page, send initial events
                        shared.sendPageIntialEvents(sessionId: page.sessionId,
                                                    pageInstanceGuid: page.pageInstanceGuid,
                                                    startDate: startDate)
                        page.setStartDate(startDate: startDate)
                        
                        shared.executeSession = ExecuteSession(sessionId: page.sessionId,
                                                               expiry: shared.clientSessionTimeoutMilliseconds)

                        guard page.placements != nil else {
                            shared.conclude()
                            return
                        }
                        let payload = ExecutePayload(placementPage: page, layoutPage: nil)
                        shared.show(payload)
                    },
                    successLayout: { page in

                        shared.isExecuting = false
                        
                        guard var page else {
                            shared.conclude()
                            return
                        }
                        
                        // if there is valid page, send initial events
                        shared.sendPageIntialEvents(sessionId: page.sessionId,
                                                    pageInstanceGuid: page.pageInstanceGuid,
                                                    startDate: startDate)
                        page.startDate = startDate
                        
                        shared.executeSession = ExecuteSession(sessionId: page.sessionId,
                                                               expiry: shared.clientSessionTimeoutMilliseconds)

                        let payload = ExecutePayload(placementPage: nil, layoutPage: page)
                        shared.show(payload)
                    },
                    failure: executeFailureHandler
                )
            } else {
                RoktAPIHelper.getPlacement(
                    viewName: viewName,
                    attributes: attributes,
                    roktTagId: tagId,
                    trackingConsent: trackingConsent,
                    success: { page in
                        shared.isExecuting = false

                        guard let page else {
                            shared.conclude()
                            return
                        }

                        // if there is valid page, send initial events
                        shared.sendPageIntialEvents(sessionId: page.sessionId,
                                                    pageInstanceGuid: page.pageInstanceGuid,
                                                    startDate: startDate)
                        page.setStartDate(startDate: startDate)

                        guard page.placements != nil else {
                            shared.conclude()
                            return
                        }

                        let payload = ExecutePayload(placementPage: page, layoutPage: nil)
                        shared.show(payload)
                    },
                    failure: executeFailureHandler(_:_:_:)
                )
            }
        } else {
            shared.isExecuting = false
            Log.d(StringHelper.localizedStringFor(kInitBeforeDoKey, comment: kInitBeforeDoComment))
            onUnLoad?()
            shared.clearCallBacks()
        }
    }
    
    // For SwiftUI integrations
    @available(iOS 15, *)
    internal static func execute(viewName: String? = nil,
                                 attributes: [String: String],
                                 layout: RoktLayout? = nil,
                                 onLoad: (() -> Void)? = nil,
                                 onUnLoad: (() -> Void)? = nil,
                                 onShouldShowLoadingIndicator: (() -> Void)? = nil,
                                 onShouldHideLoadingIndicator: (() -> Void)? = nil,
                                 onEmbeddedSizeChange: ((String, CGFloat) -> Void)? = nil) {
        shared._executeLayout = layout
        Execute(viewName: viewName,
                attributes: attributes,
                onLoad: onLoad, onUnLoad: onUnLoad,
                onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                onEmbeddedSizeChange: onEmbeddedSizeChange)
    }

    fileprivate static func executeFailureHandler(_ error: Error, _ statusCode: Int?, _ response: String) {
        shared.isExecuting = false
        sendDiagnostics(kAPIExecuteErrorCode, error: error, statusCode: statusCode, response: response)
        shared.conclude()
    }
    
    /// Rokt developer facing initializer
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
        Execute(viewName: viewName,
                attributes: attributes,
                placements: placements,
                onLoad: onLoad, onUnLoad: onUnLoad,
                onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                onEmbeddedSizeChange: onEmbeddedSizeChange)
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
    
    /// Rokt developer facing initializer
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
        Execute(viewName: viewName,
                attributes: attributes,
                placements: placements,
                onLoad: onLoad, onUnLoad: onUnLoad,
                onShouldShowLoadingIndicator: onShouldShowLoadingIndicator,
                onShouldHideLoadingIndicator: onShouldHideLoadingIndicator,
                onEmbeddedSizeChange: onEmbeddedSizeChange,
                onEvent: onEvent)
    }
    
    // Enable or disable Log
    @objc public static func setLoggingEnabled(enable: Bool) {
        shared.debugLogEnabled = enable
    }
    
    @objc public static func setEnvironment(environment: RoktEnvironment) {
        config = Configuration(environment: Configuration.getEnvironment(environment))
    }

}

struct ExecutePayload {
    let placementPage: PageViewData?
    let layoutPage: PageModel?
}
