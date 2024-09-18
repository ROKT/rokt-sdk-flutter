//
//  RoktEmbeddedUIView.swift
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

@objc public class RoktEmbeddedUIView: UIView, UIGestureRecognizerDelegate,
                                       PlacementViewModelCallback {

    private let xib_name = "RoktEmbeddedView"

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var roktOfferView: RoktOfferView!
    @IBOutlet weak var roktOfferViewHeight: NSLayoutConstraint!
    @IBOutlet weak var disclaimerTextView: UITextView!
    @IBOutlet weak var disclaimerTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var embeddedContainer: UIView!
    @IBOutlet weak var embeddedBackgroundContainer: UIView!
    @IBOutlet weak var inlineEmbeddedContainer: UIView!
    @IBOutlet weak var offerBottonContainer: UIView!
    @IBOutlet weak var offerButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var offerButtonBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var footerContainer: UIView!
    @IBOutlet weak var footerSectionDivider: UIView!
    @IBOutlet weak var footerSectionDividerLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var footerSectionDividerRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var footerDividerHeight: NSLayoutConstraint!
    @IBOutlet weak var footerLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var footerRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var disclaimerBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var disclaimerLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var disclaimerRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var footerHeight: NSLayoutConstraint!
    @IBOutlet weak var roktPrivacyButton: LinkButton!
    @IBOutlet weak var partnerPrivacyButton: LinkButton!
    @IBOutlet weak var marginTop: NSLayoutConstraint!
    @IBOutlet weak var marginBottom: NSLayoutConstraint!
    @IBOutlet weak var marginLeft: NSLayoutConstraint!
    @IBOutlet weak var marginRight: NSLayoutConstraint!
    @IBOutlet weak var paddingTop: NSLayoutConstraint!
    @IBOutlet weak var paddingBottom: NSLayoutConstraint!
    @IBOutlet weak var paddingLeft: NSLayoutConstraint!
    @IBOutlet weak var paddingRight: NSLayoutConstraint!
    @IBOutlet weak var endMessageTitle: UILabel!
    @IBOutlet weak var endMessageBody: UILabel!
    @IBOutlet weak var afterOffer: UILabel!
    @IBOutlet weak var afterOfferHeight: NSLayoutConstraint!
    @IBOutlet weak var afterOfferTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var afterOfferLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var afterOfferRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var afterOfferBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBar: UIView!
    @IBOutlet weak var lowerProgressBarHeight: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBarTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBarRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBarBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var lowerProgressBarLeftSpacing: NSLayoutConstraint!
    internal var offerButtons: OfferButtonsController?

    private var onUnLoad: ((PlacementCompletionType) -> Void)?
    private var onEmbeddedSizeChange: ((String, CGFloat) -> Void)?
    private var topBottomMargin: CGFloat = 0
    private var isInitialized = false
    private var isPortrait = false
    private var viewModel: EmbeddedPlacementViewModel!

    // added as a new container below `footerContainer`
    // its bottom will be pinned to `embeddedContainer` and its top to `footerContainer`
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

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    internal func initializeEmbeddedWidget(sessionId: String, placement: EmbeddedViewData,
                                           onLoad: @escaping (() -> Void),
                                           onUnLoad: @escaping ((PlacementCompletionType) -> Void),
                                           onEmbeddedSizeChange: @escaping (String, CGFloat) -> Void,
                                           onEvent: @escaping (RoktEventType, RoktEventHandler) -> Void) {
        Log.i("Rokt: Embedded view is initializing")
        viewModel = EmbeddedPlacementViewModel(sessionId,
                                               placement: placement,
                                               placementCallback: self,
                                               onEvent: onEvent)
        self.onUnLoad = onUnLoad
        endMessageTitle.isHidden = true
        endMessageBody.isHidden = true
        topBottomMargin = 0
        self.onEmbeddedSizeChange = onEmbeddedSizeChange
        self.inlineEmbeddedContainer.alpha = 0

        isPortrait = UIDevice.current.orientation.isPortrait
        setupDisclaimer()
        viewModel.sendSignalLoadStartEvent()

        setupWidget()
        setupMargin()
        setupPadding()
        setupUpperContainer()

        viewModel.sendSignalLoadCompleteEvent()

        roktOfferView.initialOfferView(viewController: parentViewController,
                                       sessionId: sessionId,
                                       urlInExternalBrowser: viewModel.placement.urlInExternalBrowser,
                                       disclaimerTextProperies: getDisclaimerProperties(),
                                       afterofferProperties: getAfterOfferProperties(),
                                       lowerProgressProperties: getLowerProgressBarProperties(),
                                       notifySizeChanged: { [weak self] in self?.resizeEmbeddedWidget()
        })
        Log.i("Rokt: Embedded view is ready")
        if contentView.window != nil {
            viewModel.sendPlacementImpressionEvent()
        }
        showOffer()

        isInitialized = true
        if contentView.window != nil {
            // send the first slot impression event
            viewModel.sendSlotImpressionEvent()
            Log.i("Rokt: Embedded view loaded")
            onLoad()
        }

        addGestureRecognizer()
    }

    private func setupWidget() {
        self.embeddedBackgroundContainer.backgroundColor = UIColor(colorMap: viewModel.placement.backgroundColor,
                                                                   self.traitCollection)
        self.embeddedContainer.clipsToBounds = true
        if let cornerRadius = viewModel.placement.cornerRadius {
            self.embeddedContainer.layer.cornerRadius = CGFloat(cornerRadius)
            self.embeddedBackgroundContainer.layer.cornerRadius = CGFloat(cornerRadius)
        }
        setUpButtons(offerBottonContainer)
        setupFooter()
    }

    private func addGestureRecognizer() {
        // Gesture recognizer to detect the first interaction with the placement
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.delegate = self
        contentView.addGestureRecognizer(tapGesture)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        viewModel.sendSignalActivationEvent()
        contentView.removeGestureRecognizer(gestureRecognizer)
        return false
    }

    private func resizeEmbeddedWidget(closeOnNegativeResponse: Bool = false) {
        self.contentView.isHidden = false

        var widgetHeight: CGFloat

        if !viewModel.isJourneyEnded() && !closeOnNegativeResponse {

            roktOfferView.sizeToFit()
            contentView.sizeToFit()
            embeddedContainer.sizeToFit()
            navigateToContainer.sizeToFit()
            navigateToContainer.layoutIfNeeded()
            offerBottonContainer.layoutIfNeeded()
            roktOfferView.layoutIfNeeded()

            widgetHeight = footerContainer.frame.maxY +
                topBottomMargin +
                navigateContainerHeight()
        } else if viewModel.isEndedWithMessage() {
            endMessageTitle.sizeToFit()
            endMessageBody.sizeToFit()

            roktOfferViewHeight.constant = endMessageBody.frame.maxY - endMessageTitle.frame.minY
            roktOfferView.isHidden = true

            hideOfferButtons()
            hideDisclaimer()
            hideAfterOffer()
            hideLowerProgressBar()

            widgetHeight = endMessageBody.frame.maxY +
                footerHeight.constant +
                offerButtonBottomSpacing.constant +
                topBottomMargin +
                navigateContainerHeight() +
                25
        } else {
            contentView.isHidden = true
            widgetHeight = 0
        }

        contentHeight.constant = widgetHeight
        embeddedContainer.layoutIfNeeded()
        contentView.layoutIfNeeded()

        Log.i("Rokt: Embedded height resized to \(widgetHeight)")

        if Rokt.shared.frameworkType == .Flutter {
            // Flutter view must receive new height beforehand to avoid un-interactable placements
            onEmbeddedSizeChange?(viewModel.placement.targetElement, widgetHeight)
            resizeHeight(newHeight: widgetHeight)
        } else {
            resizeHeight(newHeight: widgetHeight)
            onEmbeddedSizeChange?(viewModel.placement.targetElement, widgetHeight)
        }
    }

    private func showOffer() {
        if !viewModel.isJourneyEnded() {
            let offer = viewModel.offer
            if offer.isGhostOffer() {
                viewModel.goToNextOffer()
            } else {
                updateButtonsTitle()
                roktOfferView.goToOffer(offerViewData: offer)

                UIView.animate(withDuration: kOfferAnimationDuration, animations: { [weak self] () -> Void in
                    self?.inlineEmbeddedContainer.alpha = 1
                })
            }
        }
    }

    internal func animateToNextOffer() {
        UIView.animate(withDuration: kOfferAnimationDuration, animations: { () -> Void in
            self.inlineEmbeddedContainer.alpha = 0
        }, completion: { _ -> Void in
            if self.viewModel.isJourneyEnded() {
                self.goToEndOfJourney(onNegativeResponse: false)
            } else {
                self.showOffer()
            }
        })
    }

    internal func closeOnNegativeResponse() {
        self.goToEndOfJourney(onNegativeResponse: true)
    }

    private func goToEndOfJourney(onNegativeResponse: Bool) {
        if viewModel.isEndedWithMessage(), let endMessageViewData = viewModel.placement.endMessageViewData {
            UIView.animate(withDuration: kOfferAnimationDuration, animations: { () -> Void in
                self.inlineEmbeddedContainer.alpha = 1
            })
            // release offerButtons in order to be recreated if needed
            offerButtons = nil
            endMessageTitle.set(textViewData: endMessageViewData.title)
            endMessageBody.set(textViewData: endMessageViewData.content, editingFinished: {
                self.resizeEmbeddedWidget(closeOnNegativeResponse: onNegativeResponse)
            })
            if onNegativeResponse {
                viewModel.sendDismissalNegativeButtonEvent()
            } else {
                viewModel.sendDismissalEndMessageEvent()
            }

        } else {
            resizeEmbeddedWidget(closeOnNegativeResponse: onNegativeResponse)
            onUnLoad?(.PlacementCompleted)
            if onNegativeResponse {
                viewModel.sendDismissalNegativeButtonEvent()
            } else {
                viewModel.sendDismissalCollapsedEvent()
            }
        }
        Log.i("Rokt: User journey endded on Embedded view")
    }

    private func setUpButtons(_ optionalParentView: UIView?, forceRebuild: Bool = false) {
        if let parentView = optionalParentView,
           offerButtons == nil || forceRebuild {
            parentView.isHidden = false
            offerButtons = OfferButtonsController(positiveButtonStyle: viewModel.placement.positiveButton,
                                                  negativeButtonStyle: viewModel.placement.negativeButton,
                                                  traitCollection: parentView.traitCollection,
                                                  isNegativeButtonVisible: viewModel.placement.isNegativeButtonVisible)
            offerButtons?.addButtonsToView(parentView,
                                           positiveButtonFirst: viewModel.placement.positiveButtonFirst,
                                           buttonStacked: viewModel.placement.buttonsStacked,
                                           offerButtonsActions: self,
                                           buttonsContainerHeight: offerButtonHeight)
        }

    }

    private func updateButtonsTitle() {
        if offerButtons != nil && !viewModel.isJourneyEnded() {
            offerButtons?.updateButtonsTitle(viewModel.offer)
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
                                  spacingTop: offerButtonBottomSpacing,
                                  spacingRight: disclaimerRightSpacing,
                                  spacingBottom: disclaimerBottomSpacing,
                                  spacingLeft: disclaimerLeftSpacing,
                                  removeSpacingTopOnEmpty: false)
    }

    private func hideDisclaimer() {
        disclaimerTextView.isHidden = true
        disclaimerTextViewHeight.constant = 0
    }

    private func getAfterOfferProperties() -> LabelProperties {
        return LabelProperties(label: afterOffer,
                               height: afterOfferHeight,
                               spacingTop: afterOfferTopSpacing,
                               spacingRight: afterOfferRightSpacing,
                               spacingBottom: afterOfferBottomSpacing,
                               spacingLeft: afterOfferLeftSpacing)
    }

    private func hideAfterOffer() {
        afterOffer.isHidden = true
        afterOfferHeight.constant = 0
        afterOfferBottomSpacing.constant = 0
        afterOfferTopSpacing.constant = 0
    }

    private func getLowerProgressBarProperties() -> ContainerProperties {
        return ContainerProperties(container: lowerProgressBar,
                                   height: lowerProgressBarHeight,
                                   spacingTop: lowerProgressBarTopSpacing,
                                   spacingRight: lowerProgressBarRightSpacing,
                                   spacingBottom: lowerProgressBarBottomSpacing,
                                   spacingLeft: lowerProgressBarLeftSpacing)
    }

    private func hideLowerProgressBar() {
        lowerProgressBar.subviews.forEach({ $0.removeFromSuperview() })
        getLowerProgressBarProperties().resizeToZero()
    }

    private func hideOfferButtons() {
        offerBottonContainer.subviews.forEach({ $0.removeFromSuperview() })
        offerBottonContainer.isHidden = true
        offerButtonHeight.constant = 0
    }

    private func setupMargin() {
        marginTop.constant = CGFloat(viewModel.placement.margin.top)
        marginLeft.constant = CGFloat(viewModel.placement.margin.left)
        marginRight.constant = CGFloat(viewModel.placement.margin.right)
        marginBottom.constant = CGFloat(viewModel.placement.margin.bottom)

        topBottomMargin += CGFloat(viewModel.placement.margin.top + viewModel.placement.margin.bottom)
    }

    private func setupPadding() {
        paddingTop.constant = CGFloat(viewModel.placement.padding.top)
        paddingLeft.constant = CGFloat(viewModel.placement.padding.left)
        paddingRight.constant = CGFloat(viewModel.placement.padding.right)
        paddingBottom.constant = CGFloat(viewModel.placement.padding.bottom)

        topBottomMargin += CGFloat(viewModel.placement.padding.bottom)
    }

    private func setupView() {
        let podBundle = Bundle(for: Rokt.self)

        let bundleURL = podBundle.url(forResource: kBundleName, withExtension: kBundleExtension)
        let bundle = Bundle(url: bundleURL!)
        let nib = UINib(nibName: self.xib_name, bundle: bundle)
        self.contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView

        self.contentView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        self.contentView.isHidden = true
    }

    private func setupFooter() {
        let footerElements = FooterElements(footerViewData: viewModel.placement.footerViewData,
                                            footerContainer: footerContainer,
                                            footerSectionDivider: footerSectionDivider,
                                            footerHeight: footerHeight,
                                            footerDividerTopSpacing: offerButtonBottomSpacing,
                                            footerDividerHeight: footerDividerHeight)
        FooterView.setUpFooter(
            footerElements,
            placementButtonActions: self)
    }

    private func setupUpperContainer() {
        let footerRealignElements = EmbeddedFooterRealignElements(
            footerSectionDivider: footerSectionDivider,
            footerSectionDividerLeftSpacing: footerSectionDividerLeftSpacing,
            footerSectionDividerRightSpacing: footerSectionDividerRightSpacing,
            footerContainer: footerContainer,
            footerLeftSpacing: footerLeftSpacing,
            footerRightSpacing: footerRightSpacing)

        let elements = EmbeddedUpperContainerViewElements(
            backgroundWithoutFooterViewData: viewModel.placement.backgroundWithoutFooterViewData,
            container: inlineEmbeddedContainer,
            roktOfferView: roktOfferView,
            lowerProgressBar: lowerProgressBar,
            paddingTop: paddingTop,
            paddingRight: paddingRight,
            paddingBottom: paddingBottom,
            paddingLeft: paddingLeft,
            footerRealignElements: footerRealignElements)
        UpperContainerView.setUpEmbeddedUpperContainerView(elements)
    }

    private func resizeHeight(newHeight: CGFloat) {
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: newHeight)
        contentHeight.constant = newHeight
        for cons in self.constraints where cons.firstAttribute == NSLayoutConstraint.Attribute.height {
            cons.constant = newHeight
        }
    }

    override public func layoutSubviews() {
        if isInitialized && isPortrait != UIDevice.current.orientation.isPortrait {
            isPortrait = UIDevice.current.orientation.isPortrait
            setupFooter()
            if !viewModel.isJourneyEnded() {
                roktOfferView.onRotationChange()
            } else {
                if !endMessageTitle.isHidden && viewModel.placement.endMessageViewData != nil {
                    endMessageTitle.set(textViewData: viewModel.placement.endMessageViewData?.title)
                }
                if !endMessageBody.isHidden && viewModel.placement.endMessageViewData != nil {
                    endMessageBody.set(textViewData: viewModel.placement.endMessageViewData?.content, editingFinished: {
                        self.resizeEmbeddedWidget()
                    })
                }
            }
        }
    }

    private weak var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 17, *) {
            // Required in iOS 17 to immediately update descendant view traits
            updateTraitsIfNeeded()
        }
        if #available(iOS 13, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false
                && isInitialized && (UIApplication.shared.applicationState == .inactive ||
                                        UIApplication.shared.applicationState == .active) {
                if !viewModel.isJourneyEnded() {
                    setupWidget()
                    roktOfferView.setOfferBackground()
                    setUpButtons(offerBottonContainer, forceRebuild: true)

                    updateButtonsTitle()
                    roktOfferView.goToOffer(offerViewData: viewModel.offer, isNewOffer: false)
                } else {
                    self.embeddedBackgroundContainer.backgroundColor =
                        UIColor(colorMap: viewModel.placement.backgroundColor,
                                self.traitCollection)
                    roktOfferView.setOfferBackground()
                    setupFooter()
                    if !endMessageTitle.isHidden {
                        endMessageTitle.set(textViewData: viewModel.placement.endMessageViewData?.title)
                    }
                    if !endMessageBody.isHidden {
                        endMessageBody.set(textViewData: viewModel.placement.endMessageViewData?.content)
                    }
                }
            }
        }
    }
}

extension RoktEmbeddedUIView: OfferButtonsActions {
    @objc func yesAction() {
        viewModel.yesAction(parentViewController: parentViewController)
    }

    @objc func noAction() {
        viewModel.noAction()
    }
}

extension RoktEmbeddedUIView: PlacementViewButtonActions {
    @objc func footerLinkButtonTapped(_ sender: LinkButton) {
        if parentViewController != nil {
            sender.presentLink(on: parentViewController,
                               sessionId: viewModel.sessionId,
                               urlInExternalBrowser: viewModel.placement.urlInExternalBrowser)
        }
    }
}

extension RoktEmbeddedUIView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if let viewContoller = parentViewController {
            OfferButtonHandler.staticUrlHandler(url: URL,
                                                sessionId: viewModel.sessionId,
                                                viewController: viewContoller,
                                                safariDelegate: self,
                                                urlInExternalBrowser: viewModel.placement.urlInExternalBrowser)
        }
        return false
    }
}

extension RoktEmbeddedUIView: SFSafariViewControllerDelegate {
    public func safariViewController(_ controller: SFSafariViewController,
                                     didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            controller.dismiss(animated: true)
            viewModel.sendWebViewDiagnostics()
        }
    }
}

fileprivate extension RoktEmbeddedUIView {
    func navigateContainerHeight() -> CGFloat {
        buttonAndMarginHeight() + dividerAndMarginHeight()
    }

    func buttonAndMarginHeight() -> CGFloat {
        let isNavigateToButtonVisible = viewModel.placement.isNavigateButtonVisible

        guard isNavigateToButtonVisible else { return 0}

        return kButtonsHeight +
            CGFloat(viewModel.placement.navigateToButtonStyles?.margin.top ?? 0) +
            CGFloat(viewModel.placement.navigateToButtonStyles?.margin.bottom ?? 0)
    }

    func dividerAndMarginHeight() -> CGFloat {
        let isNavigateToDividerVisible = viewModel.placement.navigateToDivider?.isVisible ?? false

        guard isNavigateToDividerVisible else { return 0 }

        return CGFloat(viewModel.placement.navigateToDivider?.height ?? 0) +
            CGFloat(viewModel.placement.navigateToDivider?.margin.top ?? 0) +
            CGFloat(viewModel.placement.navigateToDivider?.margin.bottom ?? 0)
    }

    // MARK: - Navigate To Section
    func setupNavigateContainer() {
        let isNavigateToDividerVisible = viewModel.placement.navigateToDivider?.isVisible ?? false
        let isNavigateToButtonVisible = viewModel.placement.isNavigateButtonVisible

        guard isNavigateToDividerVisible || isNavigateToButtonVisible else { return }

        let placementBG = viewModel.placement.backgroundColor
        navigateToContainer.backgroundColor = UIColor(colorMap: placementBG, traitCollection)
        inlineEmbeddedContainer.addSubview(navigateToContainer)

        NSLayoutConstraint.activate([
            navigateToContainer.leftAnchor.constraint(equalTo: inlineEmbeddedContainer.leftAnchor),
            navigateToContainer.rightAnchor.constraint(equalTo: inlineEmbeddedContainer.rightAnchor),
            navigateToContainer.heightAnchor.constraint(equalToConstant: navigateContainerHeight())
        ])

        let navContBtmConst = navigateToContainer.bottomAnchor.constraint(equalTo: inlineEmbeddedContainer.bottomAnchor)
        navContBtmConst.priority = UILayoutPriority(500)

        // swap the bottom anchor from `inlineEmbeddedContainer` to `navigateToContainer`
        navContBtmConst.isActive = true
        paddingBottom.isActive = false

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
