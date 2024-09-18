//
//  RoktViewController.swift
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

import UIKit
import SafariServices

/// Main Rokt widget view controller
public class RoktViewController: UIViewController, UIGestureRecognizerDelegate, PlacementViewModelCallback {

    @IBOutlet weak var placementContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var disclaimerTextView: UITextView!
    @IBOutlet weak var roktPrivacyButton: LinkButton!
    @IBOutlet weak var disclaimerBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var disclaimerLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var disclaimerRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var partnerPrivacyButton: LinkButton!
    @IBOutlet weak var offerButtonsContainer: UIView!
    @IBOutlet weak var buttonsContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBar: UIView!
    @IBOutlet weak var lowerProgressBarHeight: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBarTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBarBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBarRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBarLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var footerContainer: UIView!
    @IBOutlet weak var footerSectionDivider: UIView!
    @IBOutlet weak var buttonsBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var footerDividerHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var disclaimerTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var footerHeight: NSLayoutConstraint!
    @IBOutlet weak var roktOfferView: RoktOfferView!
    @IBOutlet weak var buttomViewContainer: UIView!
    internal var offerButtons: OfferButtonsController?
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var placementHeight: NSLayoutConstraint!
    @IBOutlet weak var marginTop: NSLayoutConstraint!
    @IBOutlet weak var marginRight: NSLayoutConstraint!
    @IBOutlet weak var marginBottom: NSLayoutConstraint!
    @IBOutlet weak var marginLeft: NSLayoutConstraint!
    @IBOutlet weak var afterOffer: UILabel!
    @IBOutlet weak var afterOfferHeight: NSLayoutConstraint!
    @IBOutlet weak var afterOfferTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var afterOfferRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var afterOfferLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var afterOfferBottomSpacing: NSLayoutConstraint!

    // Footer Divider
    @IBOutlet weak var footerDividerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerDividerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerDividerBottomConstraint: NSLayoutConstraint!

    // Divider below title
    @IBOutlet weak var titleDividerContainer: UIView!
    @IBOutlet weak var titleDividerContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDividerContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDividerContainerLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleDivider: UIView!
    @IBOutlet weak var titleDividerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDividerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDividerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDividerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDividerBottomConstraint: NSLayoutConstraint!

    // no NavigateToContainer, we have to activate at least one of these
    // if there is a NavigateToContainer, we have to deactivate both of these since that becomes the last View
    @IBOutlet weak var bottomContainerToSuperviewBottomGTEConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContainerToSuperviewBottomEqualConstraint: NSLayoutConstraint!

    // default 13-point bottom gap that exists if there is NavigateToContainer
    // if there is NavigateToContainer, set this constant to 0
    @IBOutlet weak var privacyPolicyContainerBottomConstraint: NSLayoutConstraint!

    // no NavigateContainer, activate to pin bottomContainer to placementContainer
    // there is NavigateContainer, deactivate to pin navigateToContainer to placementContainer
    @IBOutlet weak var bottomContainerBottomToPlacementContainerBottomEqualConstraint: NSLayoutConstraint!

    // added as a new container below `buttomViewContainer`
    // its bottom will be pinned to `PlacementContainer` and its top to `buttomViewContainer`
    internal lazy var navigateToContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let defaultButtonFrame = CGRect(x: 0, y: 0, width: 100, height: 40)
    internal private(set) var navigateButton: OfferButton?
    private var tapOnCloseForNavigateButton = true

    internal lazy var navigateButtonDivider: UIView = {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }()

    @IBOutlet weak var lowerTitleContainer: UIView!

    // constraints binding the `Title` to the same container as the Close button
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleContainerGreaterThanHeightConstraint: NSLayoutConstraint!

    private var onUnLoad: ((PlacementCompletionType) -> Void)?
    private var onEvent: ((RoktEventType, RoktEventHandler) -> Void)?
    private var isFirstPositiveEngagementSend = false
    private var currentOffer = 0
    private var dismissOption: DismissOptions = .defaultDimiss

    private var viewModel: LightBoxPlacementViewModel!
    private var firstEventSent = false
    private var isOverlay = false
    private var footerDividerTopSpacing: CGFloat = 0

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.sendSignalLoadStartEvent()

        setupDisclaimer()
        loadWidgetData()

        viewModel.sendSignalLoadCompleteEvent()
        self.scrollContentView.alpha = 0

        roktOfferView.initialOfferView(viewController: self,
                                       sessionId: viewModel.sessionId,
                                       urlInExternalBrowser: viewModel.placement.urlInExternalBrowser,
                                       disclaimerTextProperies: getDisclaimerProperties(),
                                       afterofferProperties: getAfterOfferProperties(),
                                       lowerProgressProperties: getLowerProgressBarProperties(),
                                       footerDividerTopSpacing: footerDividerTopSpacing,
                                       notifySizeChanged: {
                                        DispatchQueue.main.async { [weak self] in
                                            self?.resizeOfferView()
                                        }
                                       })

        showOffer()

        addGestureRecognizer()

        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(appWillEnterForeground),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
    }

    @objc
    private func appWillEnterForeground() {
        resizeOfferView()
    }

    public override func viewDidAppear(_ animated: Bool) {
        if !firstEventSent {
            // send event only once if view actually appeard
            viewModel.sendPlacementImpressionEvent()
            // send the first slot impression event
            if !viewModel.isJourneyEnded() {
                viewModel.sendSlotImpressionEvent()
            }
            firstEventSent = true
            Log.i("Rokt: View loaded")
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.sendDismissalEvent(dismissOption)
        callOnUnload(dismissOption: dismissOption)
        Rokt.shared.clearCallBacks()
        Log.i("Rokt: User journey endded")

        // swiftlint:disable:next notification_center_detachment
        NotificationCenter.default.removeObserver(self)
    }

    private func callOnUnload(dismissOption: DismissOptions) {
        switch dismissOption {
        case .noMoreOffer:
            self.onUnLoad?(.PlacementCompleted)
        default:
            self.onUnLoad?(.PlacementClosed)
        }
    }

    private func addGestureRecognizer() {
        // Gesture recognizer to detect the first interaction with the placement
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        viewModel.sendSignalActivationEvent()
        view.removeGestureRecognizer(gestureRecognizer)
        return false
    }

    // Loads main UI elements for the placement
    private func loadWidgetData() {
        if isOverlay {
            placementContainer.alpha = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + kOverlayAnimationDelay) {
                UIView.animate(withDuration: kOfferAnimationDuration,
                               animations: { () -> Void in
                                self.placementContainer.alpha = 1
                               })
            }
            if let backround = viewModel.placement.lightboxBackground {
                view.backgroundColor = UIColor(colorMap: backround, self.traitCollection)
            } else {
                view.backgroundColor = UIColor.clear
            }
        }
        setupMargin()
        setupBorder()
        view.isOpaque = false
        scrollView.backgroundColor = UIColor(colorMap: viewModel.placement.backgroundColor, self.traitCollection)
        buttomViewContainer.backgroundColor = UIColor(colorMap: viewModel.placement.backgroundColor,
                                                      self.traitCollection)
        setupTitle(viewModel.placement.title)
        setUpButtons(offerButtonsContainer)

        setupTitleDivider()
        setupNavigateContainer()
        setupFooterDivider()

        let footerElements = FooterElements(footerViewData: viewModel.placement.footerViewData,
                                            footerContainer: footerContainer,
                                            footerSectionDivider: footerSectionDivider,
                                            footerHeight: footerHeight,
                                            footerDividerTopSpacing: buttonsBottomSpacing,
                                            footerDividerHeight: footerDividerHeight)

        FooterView.setUpFooter(
            footerElements,
            placementButtonActions: self
        )
        UpperContainerView.setUpOverlayUpperContainerView(
            OverlayUpperContainerViewElements(
                backgroundWithoutFooterViewData:
                    viewModel.placement.backgroundWithoutFooterViewData,
                scrollView: scrollView,
                scrollContentView: scrollContentView,
                buttonViewContainer: buttomViewContainer,
                lowerProgressBar: lowerProgressBar)
        )
    }

    private func setupTitle(_ titleViewData: TitleViewData) {
        titleLabel.set(textViewData: titleViewData.textViewData)
        titleLabel.numberOfLines = viewModel.numberOfLinesForTitle()

        titleContainer.backgroundColor = UIColor(colorMap: titleViewData.backgroundColor, self.traitCollection)
        lowerTitleContainer.backgroundColor = UIColor(colorMap: titleViewData.backgroundColor, self.traitCollection)

        adjustCloseButtonImageSource(titleViewData.closeButtonThinVariant)

        if let circleColor = titleViewData.closeButtonCircleColor, circleColor[0] != "" {
            closeButton.layer.cornerRadius = closeButton.frame.width / 2
            closeButton.backgroundColor = UIColor(colorMap: circleColor, self.traitCollection)
        }
        closeButton.tintColor = UIColor(colorMap: titleViewData.closeButtonColor, self.traitCollection)

        adjustTitleConstraints(position: viewModel.placement.titlePosition)
    }

    private func adjustCloseButtonImageSource(_ closeButtonThinVariant: Bool) {
        guard closeButtonThinVariant,
              let bundleURL = Bundle(for: Rokt.self).url(forResource: kBundleName,
                                                         withExtension: kBundleExtension) else { return }

        closeButton.setImage(UIImage(named: kThinCloseButtonSourceName,
                                     in: Bundle(url: bundleURL),
                                     compatibleWith: self.traitCollection),
                             for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    private func adjustTitleConstraints(position: TitlePosition) {
        switch position {
        case .bottom:
            setTitleInTopContainerConstraints(isActive: false)

            titleLabel.removeFromSuperview()

            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            lowerTitleContainer.addSubview(titleLabel)

            NSLayoutConstraint.activate([
                titleContainer.heightAnchor.constraint(equalToConstant: 52),
                titleLabel.topAnchor.constraint(equalTo: lowerTitleContainer.topAnchor,
                                                constant: CGFloat(viewModel.placement.titleMargin.top)),
                titleLabel.bottomAnchor.constraint(equalTo: lowerTitleContainer.bottomAnchor,
                                                   constant: -CGFloat(viewModel.placement.titleMargin.bottom)),
                titleLabel.leadingAnchor.constraint(equalTo: lowerTitleContainer.leadingAnchor,
                                                    constant: CGFloat(viewModel.placement.titleMargin.left)),
                titleLabel.trailingAnchor.constraint(equalTo: lowerTitleContainer.trailingAnchor,
                                                     constant: -CGFloat(viewModel.placement.titleMargin.right))
            ])
        case .inline:
            setTitleInTopContainerConstraints(isActive: true)

            titleTopConstraint.constant = CGFloat(viewModel.placement.titleMargin.top)
            titleBottomConstraint.constant = -CGFloat(viewModel.placement.titleMargin.bottom)
            titleLeadingConstraint.constant = CGFloat(viewModel.placement.titleMargin.left)
            titleTrailingConstraint.constant = -CGFloat(viewModel.placement.titleMargin.right)

            lowerTitleContainer.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }

    private func setTitleInTopContainerConstraints(isActive: Bool) {
        guard areTitleConstraintsNotNil() else { return }

        titleTopConstraint.isActive = isActive
        titleBottomConstraint.isActive = isActive
        titleLeadingConstraint.isActive = isActive
        titleTrailingConstraint.isActive = isActive
        titleContainerGreaterThanHeightConstraint.isActive = isActive
    }

    // the storyboard-based constraints become nil when switching trait collections (dark/light mode)
    // on a trait collection change, we do not update the constraints, only the colors
    private func areTitleConstraintsNotNil() -> Bool {
        titleTopConstraint != nil &&
            titleBottomConstraint != nil &&
            titleLeadingConstraint != nil &&
            titleTrailingConstraint != nil &&
            titleContainerGreaterThanHeightConstraint != nil
    }

    private func conclude(_ dismissOption: DismissOptions) {
        self.dismissOption = dismissOption
        dismiss(animated: true)
    }

    internal func animateToNextOffer() {
        if viewModel.isJourneyEnded() {
            conclude(.noMoreOffer)
            return
        }

        UIView.animate(withDuration: kOfferAnimationDuration, animations: { () -> Void in
            self.scrollContentView.alpha = 0
        }, completion: { _ -> Void in
            self.showOffer()
        })
    }

    internal func closeOnNegativeResponse() {
        conclude(.negativeButton)
    }

    public func closeModal() {
        conclude(.partnerTriggered)
    }

    //     Set up the view controller sub controllers and views to display the offer
    private func showOffer() {
        if !viewModel.isJourneyEnded() {
            let offer = viewModel.offer
            if offer.isGhostOffer() {
                viewModel.goToNextOffer()
            } else {
                roktOfferView.goToOffer(offerViewData: offer)
                updateButtonsTitle()
                resizeOfferView()
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                UIView.animate(withDuration: kOfferAnimationDuration, animations: { () -> Void in
                    self.scrollContentView.alpha = 1
                })
            }
        }
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        roktOfferView.onRotationChange()
        resizeOfferView()
    }

    private func resizeOfferView() {
        let isNavigateToContainerVisible = viewModel.placement.isNavigateButtonVisible ||
            (viewModel.placement.navigateToDivider?.isVisible ?? false)

        if isNavigateToContainerVisible {
            bottomContainerToSuperviewBottomGTEConstraint.isActive = false
            bottomContainerToSuperviewBottomEqualConstraint.isActive = false
            // if there is NO `navigateToContainer` and this is false, empty space at the bottom
            // will be visible between the placement container and the placement body
            bottomContainerBottomToPlacementContainerBottomEqualConstraint.isActive = false

            privacyPolicyContainerBottomConstraint.constant = 0
        }

        // in an OVERLAY placement, the content size is reduced to only take up the needed space
        // this means we have to recalculate the view heights manually
        if isOverlay {
            let scrollViewContentHeight = scrollContentView.frame.height
            let titleBarHeight = titleContainer.frame.height
            let bottomContainerHeight = buttomViewContainer.frame.height
            let navigateToContainerHeight = navigateToContainer.frame.height

            let totalHeight = scrollViewContentHeight +
                titleBarHeight +
                bottomContainerHeight +
                navigateToContainerHeight
            placementHeight.isActive = false
            placementHeight.constant = totalHeight

            bottomContainerToSuperviewBottomEqualConstraint.isActive = false
            // allows the overlay to shrink to only cover its content height
            bottomContainerToSuperviewBottomGTEConstraint.isActive = true
        }
    }

    private func setUpButtons(_ parentView: UIView?, forceRebuild: Bool = false) {
        if offerButtons == nil || forceRebuild {
            offerButtons = OfferButtonsController(positiveButtonStyle: viewModel.placement.positiveButton,
                                                  negativeButtonStyle: viewModel.placement.negativeButton,
                                                  traitCollection: self.traitCollection,
                                                  needInitialPadding: true,
                                                  isNegativeButtonVisible: viewModel.placement.isNegativeButtonVisible)
            offerButtons?.addButtonsToView(parentView,
                                           positiveButtonFirst: viewModel.placement.positiveButtonFirst,
                                           buttonStacked: viewModel.placement.buttonsStacked,
                                           offerButtonsActions: self,
                                           buttonsContainerHeight: buttonsContainerHeight)
        }
    }

    private func setupDisclaimer() {
        disclaimerTextView.delegate = self
        disclaimerTextView.textContainerInset = UIEdgeInsets.zero
        disclaimerTextView.textContainer.lineFragmentPadding = 0
    }

    private func getDisclaimerProperties() -> TextViewProperties {
        return TextViewProperties(textView: disclaimerTextView,
                                  height: disclaimerTextViewHeight,
                                  spacingRight: disclaimerRightSpacing,
                                  spacingBottom: disclaimerBottomSpacing,
                                  spacingLeft: disclaimerLeftSpacing,
                                  removeSpacingTopOnEmpty: false)
    }

    private func getAfterOfferProperties() -> LabelProperties {
        return LabelProperties(label: afterOffer,
                               height: afterOfferHeight,
                               spacingTop: afterOfferTopSpacing,
                               spacingRight: afterOfferRightSpacing,
                               spacingBottom: afterOfferBottomSpacing,
                               spacingLeft: afterOfferLeftSpacing)
    }

    private func getLowerProgressBarProperties() -> ContainerProperties {
        return ContainerProperties(container: lowerProgressBar,
                                   height: lowerProgressBarHeight,
                                   spacingTop: lowerProgressBarTopSpacing,
                                   spacingRight: lowerProgressBarRightSpacing,
                                   spacingBottom: lowerProgressBarBottomSpacing,
                                   spacingLeft: lowerProgressBarLeftSpacing)
    }

    private func setupMargin() {
        if isOverlay {
            marginTop.constant = CGFloat(viewModel.placement.margin.top)
            marginLeft.constant = CGFloat(viewModel.placement.margin.left)
            marginRight.constant = CGFloat(viewModel.placement.margin.right)
            marginBottom.constant = CGFloat(viewModel.placement.margin.bottom)
        }
    }

    private func setupBorder() {
        if isOverlay {
            placementContainer.clipsToBounds = true
            if let cornerRadius = viewModel.placement.cornerRadius {
                placementContainer.layer.cornerRadius = CGFloat(cornerRadius)
            }
            if let borderColor = viewModel.placement.borderColor {
                placementContainer.layer.borderColor = UIColor(colorMap: borderColor, traitCollection).cgColor
            }
            if let borderWidth = viewModel.placement.borderThickness {
                placementContainer.layer.borderWidth = CGFloat(borderWidth)
            }
        }
    }

    private func updateButtonsTitle() {
        if offerButtons != nil && !viewModel.isJourneyEnded() {
            offerButtons?.updateButtonsTitle(viewModel.offer)
        }
    }

    @IBAction public func done(_ sender: Any) {
        conclude(.closeButton)
    }

    @objc
    private func didTapNavigateTo() {
        let shouldCloseOnTap = viewModel.placement.navigateToButtonData?.closeOnPress ?? true

        if shouldCloseOnTap {
            conclude(.navigateBackToApp)
        }
    }

    internal func initializeRoktViewController(sessionId: String,
                                               placement: LightBoxViewData,
                                               isOverlay: Bool,
                                               onUnLoad: @escaping ((PlacementCompletionType) -> Void),
                                               on2stepEvent: @escaping (RoktEventType, RoktEventHandler) -> Void) {
        self.isOverlay = isOverlay
        self.viewModel = LightBoxPlacementViewModel(sessionId,
                                                    placement: placement,
                                                    placementCallback: self,
                                                    onEvent: on2stepEvent)
        self.onUnLoad = onUnLoad
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 17, *) {
            // Required in iOS 17 to immediately update descendant view traits
            updateTraitsIfNeeded()
        }
        if #available(iOS 13, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false &&
                (UIApplication.shared.applicationState == .inactive ||
                    UIApplication.shared.applicationState == .active) {
                loadWidgetData()
                roktOfferView.setOfferBackground()
                roktOfferView.goToOffer(offerViewData: viewModel.offer, isNewOffer: false)
            }
        }
    }
}

extension RoktViewController: OfferButtonsActions {
    func yesAction() {
        viewModel.yesAction(parentViewController: self)
    }

    func noAction() {
        viewModel.noAction()
    }
}

extension RoktViewController: PlacementViewButtonActions {
    @objc func footerLinkButtonTapped(_ sender: LinkButton) {
        sender.presentLink(on: self, sessionId: viewModel.sessionId,
                           urlInExternalBrowser: viewModel.placement.urlInExternalBrowser)
    }
}

extension RoktViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        OfferButtonHandler.staticUrlHandler(url: URL,
                                            sessionId: viewModel.sessionId,
                                            viewController: self,
                                            safariDelegate: self,
                                            urlInExternalBrowser: viewModel.placement.urlInExternalBrowser)
        return false
    }
}

extension RoktViewController: SFSafariViewControllerDelegate {
    public func safariViewController(_ controller: SFSafariViewController,
                                     didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            controller.dismiss(animated: true)
            viewModel.sendWebViewDiagnostics()
        }
    }
}

fileprivate extension RoktViewController {
    // MARK: - Navigate To
    func setupNavigateContainer() {
        let isNavigateToDividerVisible = viewModel.placement.navigateToDivider?.isVisible ?? false
        let isNavigateToButtonVisible = viewModel.placement.isNavigateButtonVisible

        guard isNavigateToDividerVisible || isNavigateToButtonVisible else { return }

        navigateToContainer.backgroundColor = UIColor(colorMap: viewModel.placement.backgroundColor, traitCollection)

        placementContainer.addSubview(navigateToContainer)

        NSLayoutConstraint.activate([
            navigateToContainer.leftAnchor.constraint(equalTo: placementContainer.leftAnchor),
            navigateToContainer.rightAnchor.constraint(equalTo: placementContainer.rightAnchor),
            navigateToContainer.topAnchor.constraint(equalTo: buttomViewContainer.bottomAnchor),
            navigateToContainer.bottomAnchor.constraint(equalTo: placementContainer.bottomAnchor)
        ])

        addNavigateToButtonDivider()
        addNavigateToButton()

        setNavigateToElementConstraints(
            isNavigateToDividerVisible: isNavigateToDividerVisible,
            isNavigateToButtonVisible: isNavigateToButtonVisible
        )
    }

    private func setNavigateToElementConstraints(
        isNavigateToDividerVisible: Bool,
        isNavigateToButtonVisible: Bool
    ) {
        guard isNavigateToDividerVisible || isNavigateToButtonVisible else { return }

        let topDividerMargin = CGFloat(viewModel.placement.navigateToDivider?.margin.top ?? 16)
        let bottomDividerMargin = CGFloat(viewModel.placement.navigateToDivider?.margin.bottom ?? 0)

        let topButtonMargin = CGFloat(viewModel.placement.navigateToButtonStyles?.margin.top ?? 16)
        let bottomButtonMargin = CGFloat(viewModel.placement.navigateToButtonStyles?.margin.bottom ?? 16)

        if isNavigateToDividerVisible && isNavigateToButtonVisible {
            navigateButtonDivider.topAnchor.constraint(
                equalTo: navigateToContainer.topAnchor,
                constant: topDividerMargin
            ).isActive = true

            navigateButton?.topAnchor.constraint(
                equalTo: navigateButtonDivider.bottomAnchor,
                constant: (bottomDividerMargin + topButtonMargin)
            ).isActive = true

            navigateButton?.bottomAnchor.constraint(
                equalTo: navigateToContainer.bottomAnchor,
                constant: -bottomButtonMargin
            ).isActive = true
        } else if isNavigateToDividerVisible && !isNavigateToButtonVisible {
            navigateButtonDivider.topAnchor.constraint(
                equalTo: navigateToContainer.topAnchor,
                constant: topDividerMargin
            ).isActive = true

            navigateButtonDivider.bottomAnchor.constraint(
                equalTo: navigateToContainer.bottomAnchor,
                constant: -bottomDividerMargin
            ).isActive = true
        } else if !isNavigateToDividerVisible && isNavigateToButtonVisible {
            navigateButton?.topAnchor.constraint(
                equalTo: navigateToContainer.topAnchor,
                constant: topButtonMargin
            ).isActive = true

            navigateButton?.bottomAnchor.constraint(
                equalTo: navigateToContainer.bottomAnchor,
                constant: -bottomButtonMargin
            ).isActive = true
        }
    }

    func addNavigateToButtonDivider() {
        let isNavigateToDividerVisible = viewModel.placement.navigateToDivider?.isVisible ?? false

        guard isNavigateToDividerVisible,
              let navigateToButtonDividerData = viewModel.placement.navigateToDivider
        else { return }

        navigateToContainer.addSubview(navigateButtonDivider)

        if let explicitColor = navigateToButtonDividerData.backgroundColor {
            navigateButtonDivider.backgroundColor = UIColor(colorMap: explicitColor, traitCollection)
        }

        NSLayoutConstraint.activate([
            navigateButtonDivider.heightAnchor.constraint(equalToConstant: navigateToButtonDividerData.height),
            navigateButtonDivider.leftAnchor.constraint(
                equalTo: navigateToContainer.leftAnchor,
                constant: CGFloat(navigateToButtonDividerData.margin.left)
            ),
            navigateButtonDivider.rightAnchor.constraint(
                equalTo: navigateToContainer.rightAnchor,
                constant: -CGFloat(navigateToButtonDividerData.margin.right)
            )
        ])
    }

    func addNavigateToButton() {
        guard viewModel.placement.isNavigateButtonVisible,
              let navigateButtonStyle = viewModel.placement.navigateToButtonStyles
        else { return }

        navigateButton = OfferButton(
            frame: defaultButtonFrame,
            buttonStyles: navigateButtonStyle,
            traitCollection: traitCollection
        )
        navigateButton?.titleLabel?.numberOfLines = 0
        navigateButton?.titleLabel?.lineBreakMode = .byWordWrapping
        navigateButton?.translatesAutoresizingMaskIntoConstraints = false
        navigateButton?.addTarget(self, action: #selector(didTapNavigateTo), for: .touchUpInside)

        guard let navigateButton else { return }

        navigateToContainer.addSubview(navigateButton)

        navigateButton.updateButtons(text: viewModel.placement.navigateToButtonData?.text)

        let leftMargin = CGFloat(viewModel.placement.navigateToButtonStyles?.margin.left ?? 0)
        let rightMargin = CGFloat(viewModel.placement.navigateToButtonStyles?.margin.right ?? 0)

        let minHeight = max(viewModel.placement.navigateToButtonStyles?.minHeight ?? kButtonsHeight, kButtonsHeight)

        NSLayoutConstraint.activate([
            navigateButton.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight),
            navigateButton.leftAnchor.constraint(
                equalTo: navigateToContainer.leftAnchor,
                constant: leftMargin
            ),
            navigateButton.rightAnchor.constraint(
                equalTo: navigateToContainer.rightAnchor,
                constant: -rightMargin
            )
        ])
    }
}

fileprivate extension RoktViewController {
    func setupTitleDivider() {
        titleDividerContainer.backgroundColor = UIColor(
            colorMap: viewModel.placement.backgroundColor,
            self.traitCollection
        )

        if viewModel.placement.titleDivider?.isVisible == true {
            titleDivider.isHidden = false
            setTitleDividerConstraintsState(isActive: true)
        } else {
            titleDivider.isHidden = true
            setTitleDividerConstraintsState(isActive: false)
        }
    }

    private func setTitleDividerConstraintsState(isActive: Bool) {
        if isActive, let dividerDimensions = viewModel.placement.titleDivider {
            let margin = dividerDimensions.margin

            titleDividerHeightConstraint.constant = dividerDimensions.height
            titleDividerTopConstraint.constant = CGFloat(margin.top)
            titleDividerTrailingConstraint.constant = -CGFloat(margin.right)
            titleDividerLeadingConstraint.constant = CGFloat(margin.left)
            titleDividerBottomConstraint.constant = -CGFloat(margin.bottom)

            let topDividerContainerHeight = dividerDimensions.height + CGFloat(margin.top + margin.bottom)
            titleDividerContainerHeightConstraint.constant = topDividerContainerHeight
        } else {
            titleDividerHeightConstraint.constant = 0
            titleDividerTopConstraint.constant = 0
            titleDividerTrailingConstraint.constant = 0
            titleDividerLeadingConstraint.constant = 0
            titleDividerBottomConstraint.constant = 0

            titleDividerContainerHeightConstraint.constant = 0
        }
    }
}

fileprivate extension RoktViewController {
    func setupFooterDivider() {
        let margin = viewModel.placement.footerViewData.footerDivider.margin

        footerDividerTrailingConstraint.constant = -CGFloat(margin.right)
        footerDividerLeadingConstraint.constant = CGFloat(margin.left)
        footerDividerBottomConstraint.constant = -CGFloat(margin.bottom)
        footerDividerTopSpacing = CGFloat(margin.top)

        footerDividerHeight.constant = viewModel.placement.footerViewData.footerDivider.height
    }
}
