//
//  OfferButtonHandler.swift
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
import SafariServices

protocol OfferButtonCallback {
    func goToNextOffer()
    func closeOnNegativeResponse()
}

@objc internal protocol OfferButtonsActions {
    @objc func yesAction()
    @objc func noAction()
}

class OfferButtonHandler {
    internal class func yesActionHandler(
        buttonViewData: ButtonViewData,
        sessionId: String,
        campaignId: String?,
        callback: OfferButtonCallback?,
        viewController: UIViewController?,
        webviewCallback: RoktWebViewCallback,
        shouldSendResponseEvent: Bool = true
    ) {
        if let urlString = buttonViewData.url, buttonViewData.action ==  .url ||
            urlString != "" {

            guard let url = URL(string: urlString) else {
                RoktAPIHelper.sendDiagnostics(message: kUrlErrorCode,
                                              callStack: buttonViewData.url ?? "",
                                              sessionId: sessionId,
                                              campaignId: campaignId)

                callback?.goToNextOffer()

                return
            }

            if url.isWebURL() && !buttonViewData.actionInExternalBrowser {
                if shouldSendResponseEvent {
                    sendEvent(sessionId: sessionId, buttonViewData: buttonViewData)
                }

                openRoktWebView(url: url,
                                viewController: viewController,
                                sessionId: sessionId,
                                campaignId: campaignId,
                                webviewCallback: webviewCallback)
            } else {
                // external browser
                callback?.goToNextOffer()

                openLinkInExternalBrowser(url: url,
                                          sessionId: sessionId,
                                          campaignId: campaignId,
                                          buttonViewData: buttonViewData)
            }

        } else {
            if shouldSendResponseEvent {
                sendEvent(sessionId: sessionId, buttonViewData: buttonViewData)
            }

            callback?.goToNextOffer()
        }
    }

    internal class func noActionHandler(buttonViewData: ButtonViewData, sessionId: String,
                                        callback: OfferButtonCallback?) {
        sendEvent(sessionId: sessionId, buttonViewData: buttonViewData)
        if buttonViewData.closeOnPress {
            callback?.closeOnNegativeResponse()
        } else {
            callback?.goToNextOffer()
        }
    }

    internal class func staticUrlHandler(url: URL,
                                         sessionId: String,
                                         viewController: UIViewController?,
                                         safariDelegate: SFSafariViewControllerDelegate? = nil,
                                         urlInExternalBrowser: Bool) {

        if urlInExternalBrowser {
            openLinkInExternalBrowser(url: url,
                                      sessionId: sessionId,
                                      campaignId: nil,
                                      buttonViewData: nil,
                                      isResponseURL: false)
        } else {
            openLinkInSafariViewController(url: url, viewController: viewController, safariDelegate: safariDelegate)
        }

    }

    private class func openLinkInSafariViewController(url: URL, viewController: UIViewController?,
                                                      safariDelegate: SFSafariViewControllerDelegate?) {

        let safariVC = SFSafariViewController(url: url)
        if let delagate = safariDelegate {
            safariVC.delegate = delagate
        }
        safariVC.modalPresentationStyle = .overFullScreen

        viewController?.present(safariVC, animated: true, completion: nil)
    }

    internal class func openRoktWebView(url: URL, viewController: UIViewController?,
                                        sessionId: String, campaignId: String? = nil,
                                        webviewCallback: RoktWebViewCallback? = nil) {
        if viewController != nil {
            RoktWebView.openWebView(viewController!, url: url,
                                    sessionId: sessionId,
                                    campaignId: campaignId,
                                    callback: webviewCallback)
        }
    }

    private class func sendEvent(sessionId: String, buttonViewData: ButtonViewData) {
        RoktAPIHelper.sendEvent(evenRequest: EventRequest(sessionId: sessionId,
                                                          eventType: buttonViewData.eventType,
                                                          parentGuid: buttonViewData.instanceGuid,
                                                          jwtToken: buttonViewData.responseJWTToken))
    }

    private class func openLinkInExternalBrowser(url: URL,
                                                 sessionId: String,
                                                 campaignId: String?,
                                                 buttonViewData: ButtonViewData?,
                                                 isResponseURL: Bool = true) {
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] =
        Rokt.shared.initFeatureFlags.isEnabled(.openUrlFromRokt) ? [.init(rawValue: "isRokt"): true] : [:]

        UIApplication.shared.open(url, options: options, completionHandler: { isSuccessfullyOpened in
            if let buttonViewData,
               isResponseURL && isSuccessfullyOpened {
                sendEvent(sessionId: sessionId, buttonViewData: buttonViewData)
            } else if !isSuccessfullyOpened {
                RoktAPIHelper.sendDiagnostics(message: kLinkErrorCode,
                                              callStack: kExternalBrowserError + url.absoluteString,
                                              sessionId: sessionId,
                                              campaignId: campaignId)
            }
        })
    }
}
