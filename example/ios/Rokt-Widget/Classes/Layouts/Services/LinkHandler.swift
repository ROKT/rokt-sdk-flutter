//
//  LinkHandler.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/


import Foundation
import SafariServices

class LinkHandler: LinkInterceptor {
    static var shared = LinkHandler()

    private init() {}

    func staticLinkHandler(url: URL, open: LinkOpenTarget, sessionId: String) {
        switch open {
        case .internally:
            guard url.isWebURL() else {
                RoktAPIHelper.sendDiagnostics(message: kUrlErrorCode,
                                              callStack: url.absoluteString,
                                              sessionId: sessionId)
                return
            }
            let safariVC = SFSafariViewController(url: url)
            safariVC.modalPresentationStyle = .overFullScreen
            UIApplication.topViewController()?.present(safariVC, animated: true, completion: nil)
        case .externally:
            LinkHandler.openExternalLink(url)
        case .passthrough:
            //todo: change to handle pass to url event once merged
            LinkHandler.openExternalLink(url)
        }
    }
    
    @available(iOS 15, *)
    func creativeLinkHandler(url: URL,
                             viewModel: CreativeResponseViewModel,
                             callback: CreativeResponseComponent) {
        let open = viewModel.model.openLinks ?? .internally
        switch open {
        case .internally:
            if let topViewController = UIApplication.topViewController() {
                RoktWebView.openWebView(topViewController, url: url,
                                        sessionId: viewModel.baseDI.eventProcessor.sessionId,
                                        callback: callback)
            } else {
                LinkHandler.openExternalLink(url)
            }
        case .externally:
            LinkHandler.openExternalLink(url)
            viewModel.goToNextOffer()
        case .passthrough:
            //todo: change to handle pass to url event once merged
            LinkHandler.openExternalLink(url)
            viewModel.goToNextOffer()
        }
    }
    
    static func openExternalLink(_ url: URL) {
        if Rokt.shared.initFeatureFlags.isEnabled(.openUrlFromRokt) {
            UIApplication.shared.open(url, options: [.init(rawValue: "isRokt"): true])
        } else {
            UIApplication.shared.open(url)
        }
    }
}

@available(iOS 15, *)
protocol LinkInterceptor {
    func staticLinkHandler(url: URL,
                           open: LinkOpenTarget,
                           sessionId: String)

    func creativeLinkHandler(url: URL,
                             viewModel: CreativeResponseViewModel,
                             callback: CreativeResponseComponent)
}
