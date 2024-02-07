//
//  RoktOfferView.swift
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

internal class RoktOfferView: UIView {

    private let xib_name = "RoktOfferView"
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var preOfferLabel: UILabel!
    @IBOutlet weak var progressDotsContainer: UIView!
    @IBOutlet weak var progressDotsHeight: NSLayoutConstraint!
    @IBOutlet weak var progressDotsTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var progressDotsRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var progressDotsBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var progressDotsLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var offerTextView: UITextView!
    @IBOutlet weak var confirmationMessageLabel: UILabel!
    @IBOutlet weak var offerContainer: UIView!
    @IBOutlet weak var offerContentView: UIView!
    @IBOutlet weak var confirmationMessageTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var confirmationMessageBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var confirmationMessageLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var confirmationMessageRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var preOfferBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var preOfferLeftSpacing: NSLayoutConstraint!
    @IBOutlet weak var preOfferRightSpacing: NSLayoutConstraint!
    @IBOutlet weak var offerLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var offerTopPadding: NSLayoutConstraint!
    @IBOutlet weak var offerRightPadding: NSLayoutConstraint!
    @IBOutlet weak var offerBottomPadding: NSLayoutConstraint!
    
    @IBOutlet weak var imageContainer: UIView!
    private var offer: OfferViewData!
    private weak var viewController: UIViewController?
    private var notifySizeChanged: (() -> Void)?
    private var offerViewModel: OfferViewModel!
    private var disclaimerTextProperies: TextViewProperties?
    private var afterofferProperties: LabelProperties?
    private var lowerProgressBarProperties: ContainerProperties?
    private var preOfferTopSpacing: CGFloat = 0
    private var footerDividerTopSpacing: CGFloat = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.isHidden = true
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
        self.contentView.isHidden = true
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
    }
    
    internal func initialOfferView(viewController: UIViewController?,
                                   sessionId: String,
                                   urlInExternalBrowser: Bool,
                                   disclaimerTextProperies: TextViewProperties? = nil,
                                   afterofferProperties: LabelProperties? = nil,
                                   lowerProgressProperties: ContainerProperties? = nil,
                                   footerDividerTopSpacing: CGFloat = 0,
                                   notifySizeChanged: @escaping (() -> Void)) {
        self.isHidden = false
        self.offerViewModel = OfferViewModel(sessionId, urlInExternalBrowser: urlInExternalBrowser)
        self.disclaimerTextProperies = disclaimerTextProperies
        self.afterofferProperties = afterofferProperties
        self.lowerProgressBarProperties = lowerProgressProperties
        self.contentView.isHidden = false
        self.viewController = viewController
        self.offerTextView.textContainer.lineFragmentPadding = 0
        self.offerTextView.textContainerInset = .zero
        self.notifySizeChanged = notifySizeChanged
        self.footerDividerTopSpacing = footerDividerTopSpacing
    }
    internal func setOfferBackground() {
        if let background = offer.background {
            offerContentView.backgroundColor = UIColor(colorMap: background, self.traitCollection)
        }
    }
    
    internal func goToOffer(offerViewData: OfferViewData, isNewOffer: Bool = true) {
        self.offer = offerViewData
        setOfferBackground()
        offerContainer.isHidden = false
        if let background = offer.background {
            offerContainer.backgroundColor = UIColor(colorMap: background, self.traitCollection)
        }
        let defaultOfferPadding = FrameAlignment(top: 0, right: 0, bottom: 0, left: 0)
        setOfferPadding(padding: offer.padding ?? defaultOfferPadding)
        
        setConfirmationMessage()
        setDisclaimer()
        setAfterOffer()
        
        preOfferLabel.set(textViewData: offer.beforeOfferViewData)
        if let beforeOfferViewData = offer.beforeOfferViewData {
            let defaultBeforeOfferPadding = FrameAlignment(top: 0, right: 0, bottom: Float(kPreOfferBottomSpacing),
                                                           left: 0)
            setBeforeOfferPadding(padding: beforeOfferViewData.padding,
                                  defaultPadding: defaultBeforeOfferPadding)
        } else {
            setBeforeOfferPadding(defaultPadding: defaultOfferPadding)
        }
        
        ProgressBarView.addProgressBarDots(
            ProgressBarElements(
                pageIndicator: offer.pageIndicator,
                progressContainer: ContainerProperties(container: progressDotsContainer,
                                                       height: progressDotsHeight,
                                                       spacingTop: progressDotsTopSpacing,
                                                       spacingRight: progressDotsRightSpacing,
                                                       spacingBottom: progressDotsBottomSpacing,
                                                       spacingLeft: progressDotsLeftSpacing),
                lowerProgressContainer: lowerProgressBarProperties,
                traitCollection: self.traitCollection,
                preOfferTopSpacing: preOfferTopSpacing,
                footerDividerTopSpacing: footerDividerTopSpacing))
        if isNewOffer && (offerContainer.window != nil || isFullScreenWidget()) {
            offerViewModel.sendImpressionEvent(offerViewData.creativeInstanceGuid)
        }
        
        // load offer Image and titleView
        let offerImageTitleView = OfferImageTitleView(imageViewData: offer.image,
                                                      titleViewData: offer.title,
                                                      notifySizeChanged: {
            self.resizeOfferView()
        })
        offerImageTitleView.loadOfferImageTitleView(container: imageContainer)
        
        setOfferContent()
    }
    
    private func setOfferContent() {
        offerTextView.delegate = self
        
        self.offerTextView.set(textViewData: self.offer.content, editingFinished: {
            if let content = self.offer.content,
               let font = UIFont(name: content.textStyleViewData.fontFamily,
                                 size: CGFloat(content.textStyleViewData.fontSize)) {
                
                self.offerTextView.tintColor =  UIColor(colorMap: content.textStyleViewData.fontColor,
                                                        self.traitCollection)
                var termsAndPrivacyHtml = "\(kSpaceHTML)"
                if let termsLink = self.offer.termsAndConditionsButton {
                    termsAndPrivacyHtml +=
                    self.convertLinkViewDatatoHTML(termsLink, font: font,
                                                                  lastLineWidth: self.offerTextView.getLasLineWidth(),
                                                                  availableWidth: self.offerTextView.frame.width)
                    self.offerTextView.set(textViewData: self.offer.content, extraString: termsAndPrivacyHtml,
                                           editingFinished: {
                                            self.setOfferPrivacy(font: font, termsAndPrivacyHtml: termsAndPrivacyHtml)
                                           })
                } else {
                    self.setOfferPrivacy(font: font, termsAndPrivacyHtml: termsAndPrivacyHtml)
                }
            }
        })
    }
    
    private func setOfferPrivacy(font: UIFont, termsAndPrivacyHtml: String) {
        if let privacyLink = self.offer.privacyPolicyButton {
            let finalTermsAndPrivacy = termsAndPrivacyHtml +
            self.convertLinkViewDatatoHTML(privacyLink, font: font,
                                                          lastLineWidth: self.offerTextView.getLasLineWidth(),
                                                          availableWidth: self.offerTextView.frame.width)
            self.offerTextView.set(textViewData: self.offer.content, extraString: finalTermsAndPrivacy,
                                   editingFinished: {
                                    self.offerLoadingFinished()
                                   })
        } else {
            offerLoadingFinished()
        }
    }
    
    private func offerLoadingFinished() {
        self.offerTextView.sizeToFit()
        self.resizeOfferView()
    }
    
    private func setOfferPadding(padding: FrameAlignment) {
        offerTopPadding.constant = CGFloat(padding.top)
        offerLeftPadding.constant = CGFloat(padding.left)
        offerRightPadding.constant = CGFloat(padding.right)
        offerBottomPadding.constant = CGFloat(padding.bottom)
    }
    
    private func setBeforeOfferPadding(padding: FrameAlignment? = nil,
                                       defaultPadding: FrameAlignment) {
        if let padding = padding {
            preOfferLeftSpacing?.constant = CGFloat(padding.left)
            preOfferRightSpacing?.constant = CGFloat(padding.right)
            preOfferBottomSpacing?.constant = CGFloat(padding.bottom)
            preOfferTopSpacing = CGFloat(padding.top)
        } else {
            preOfferLeftSpacing?.constant = CGFloat(defaultPadding.left)
            preOfferRightSpacing?.constant = CGFloat(defaultPadding.right)
            preOfferBottomSpacing?.constant = CGFloat(defaultPadding.bottom)
            preOfferTopSpacing = CGFloat(defaultPadding.top)
        }
    }
    
    private func setConfirmationMessage() {
        confirmationMessageLabel.set(textViewData: offer.confirmationMessage?.textViewData)
        if offer.confirmationMessage?.textViewData != nil {
            setSpacing(frameAlignment: offer.confirmationMessage?.textViewData?.padding,
                       defaultFrameAlignment: FrameAlignment(top: kConfirmationMessageSpacing,
                                                      right: 0,
                                                      bottom: kConfirmationMessageSpacing,
                                                      left: 0),
                       spacingTop: confirmationMessageTopSpacing,
                       spacingRight: confirmationMessageRightSpacing,
                       spacingBottom: confirmationMessageBottomSpacing,
                       spacingLeft: confirmationMessageLeftSpacing)
        } else {
            confirmationMessageTopSpacing.constant = CGFloat(kConfirmationMessageSpacing)
            confirmationMessageBottomSpacing.constant = 0
        }
        if let margin = offer.confirmationMessage?.margin {
            // add configured margin to spacing
            confirmationMessageTopSpacing?.constant += CGFloat(margin.top)
            confirmationMessageRightSpacing?.constant += CGFloat(margin.right)
            confirmationMessageBottomSpacing?.constant += CGFloat(margin.bottom)
            confirmationMessageLeftSpacing?.constant += CGFloat(margin.left)
        }
    }
    
    private func setDisclaimer() {
        disclaimerTextProperies?.textView?.set(textViewData: offer.disclaimer?.textViewData,
                                              editingFinished: {
            self.disclaimerTextProperies?.resizeTextView()
        })
        if let margin = offer.disclaimer?.margin,
           offer.disclaimer?.textViewData != nil {
            // override default margins
            disclaimerTextProperies?.spacingRight?.constant = -CGFloat(margin.right)
            disclaimerTextProperies?.spacingBottom?.constant = CGFloat(margin.bottom)
            disclaimerTextProperies?.spacingLeft?.constant = CGFloat(margin.left)
            if disclaimerTextProperies?.spacingTop != nil {
                disclaimerTextProperies?.spacingTop?.constant = CGFloat(margin.top)
            } else {
                // set top spacing using confirmation message top/bottom spacings
                setDisclaimerTopSpacing(disclaimerTopMargin: margin.top)
            }
        }
    }
    
    private func setDisclaimerTopSpacing(disclaimerTopMargin: Float) {
        var confirmationMessageTopMargin: Float = 0
        var confirmationMessageBottomMargin: Float = 0
        var confirmationMessageBottomPadding: Float = 0
        
        if let margin = offer.confirmationMessage?.margin {
            confirmationMessageTopMargin = margin.top
            confirmationMessageBottomMargin = margin.bottom
        }
        if let padding = offer.confirmationMessage?.textViewData?.padding {
            confirmationMessageBottomPadding = padding.bottom
        }
        // overrides confirmation message top or bottom spacing,
        // using disclaimer top margin
        if offer.confirmationMessage?.textViewData != nil {
            confirmationMessageBottomSpacing.constant = CGFloat(
                disclaimerTopMargin + confirmationMessageBottomMargin +
                confirmationMessageBottomPadding)
        } else {
            confirmationMessageTopSpacing.constant = CGFloat(
                disclaimerTopMargin + confirmationMessageTopMargin)
        }
    }
    
    private func setAfterOffer() {
        
        afterofferProperties?.label?.set(textViewData: offer.afterOfferViewData,
                                         editingFinished: {
            self.afterofferProperties?.resizeLabel()
        })
        setSpacing(frameAlignment: offer.afterOfferViewData?.padding,
                   defaultFrameAlignment: FrameAlignment(top: 0, right: 0, bottom: kAfterOfferSpacing, left: 0),
                   spacingTop: afterofferProperties?.spacingTop,
                   spacingRight: afterofferProperties?.spacingRight,
                   spacingBottom: afterofferProperties?.spacingBottom,
                   spacingLeft: afterofferProperties?.spacingLeft)
    }
    
    private func setSpacing(frameAlignment: FrameAlignment?,
                            defaultFrameAlignment: FrameAlignment,
                            spacingTop: NSLayoutConstraint?,
                            spacingRight: NSLayoutConstraint?,
                            spacingBottom: NSLayoutConstraint?,
                            spacingLeft: NSLayoutConstraint?) {
        if let frameAlignment = frameAlignment {
            spacingTop?.constant = CGFloat(frameAlignment.top)
            spacingRight?.constant = CGFloat(frameAlignment.right)
            spacingBottom?.constant = CGFloat(frameAlignment.bottom)
            spacingLeft?.constant = CGFloat(frameAlignment.left)
        } else {
            spacingTop?.constant = CGFloat(defaultFrameAlignment.top)
            spacingRight?.constant = CGFloat(defaultFrameAlignment.right)
            spacingBottom?.constant = CGFloat(defaultFrameAlignment.bottom)
            spacingLeft?.constant = CGFloat(defaultFrameAlignment.left)
        }
    }
    
    internal func resizeTextView(textView: UITextView, viewHeight: NSLayoutConstraint,
                                 bottomMargin: NSLayoutConstraint?) {
        if textView.text == "" {
            viewHeight.constant = 0
            if let bottomMargin = bottomMargin {
                bottomMargin.constant = 0
            }
        } else {
            textView.layoutIfNeeded()
            textView.sizeToFit()
            viewHeight.constant = textView.frame.height
        }
    }

   private func resizeOfferView() {
        offerContentView.sizeToFit()
        offerContentView.layoutIfNeeded()
        resizeParentHeight(newHeight: offerContentView.frame.height)
        self.superview?.sizeToFit()
        self.superview?.layoutIfNeeded()
        if let notifySizeChanged = notifySizeChanged {
            notifySizeChanged()
        }
    }
    
    internal func onRotationChange() {
        if offer != nil && offerViewModel.sessionId != nil {
            preOfferLabel.sizeToFit()
            confirmationMessageLabel.sizeToFit()
            disclaimerTextProperies?.resizeTextView()
            
            setOfferContent()
        }
    }
    
    private func resizeParentHeight(newHeight: CGFloat) {
        for cons in self.constraints where cons.firstAttribute == NSLayoutConstraint.Attribute.height {
            cons.constant = newHeight
        }
    }
    
    private func isFullScreenWidget() -> Bool {
        return viewController is RoktViewController
    }
    
    private func convertLinkViewDatatoHTML(_ linkButton: LinkViewData,
                                           font: UIFont, lastLineWidth: CGFloat,
                                           availableWidth: CGFloat) -> String {
        let textSize = (linkButton.text+" ").widthOfString(usingFont: font)
        
        let html = """
        <a \(linkButton.underline ? "" : "style='text-decoration:none;'")
        href='\(linkButton.link)'>\(linkButton.text)</a>\(kSpaceHTML)
        """

        if textSize + lastLineWidth + kWidthSpacingThreshold > availableWidth {
            return "\(kBreakHTML)\(html)"
        } else {
            return html
        }
    }
    
    private func openURL(url: URL, viewController: UIViewController?, delagate: SFSafariViewControllerDelegate) {
        if let viewController = viewController {
            OfferButtonHandler.staticUrlHandler(url: url,
                                                sessionId: offerViewModel.sessionId,
                                                viewController: viewController,
                                                safariDelegate: delagate,
                                                urlInExternalBrowser: offerViewModel.urlInExternalBrowser)
        }
    }
}
extension RoktOfferView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        openURL(url: URL, viewController: viewController, delagate: self)
        return false
    }
}
extension RoktOfferView: SFSafariViewControllerDelegate {
    public func safariViewController(_ controller: SFSafariViewController,
                                     didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            controller.dismiss(animated: true)
            offerViewModel.sendWebViewDiagnostics()
        }
    }
}
