//
//  LinkButton.swift
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

class LinkButton: UIButton {
    var linkViewData: LinkViewData?

    func set(linkViewData: LinkViewData, editingFinished: (() -> Void)? = nil) {
        self.linkViewData = linkViewData

        set(text: linkViewData.text,
            textStyle: linkViewData.textStyleViewData,
            for: .normal,
            traitCollection: self.traitCollection, editingFinished: editingFinished)
    }

    func presentLink(on viewController: UIViewController?, sessionId: String, urlInExternalBrowser: Bool) {
        if let urlString = linkViewData?.link, let url = URL(string: urlString) {
            OfferButtonHandler.staticUrlHandler(url: url,
                                                sessionId: sessionId,
                                                viewController: viewController,
                                                safariDelegate: viewController as? SFSafariViewControllerDelegate,
                                                urlInExternalBrowser: urlInExternalBrowser)
        } else {
            RoktAPIHelper.sendDiagnostics(message: kUrlErrorCode,
                                          callStack: linkViewData?.link ?? "",
                                          sessionId: sessionId)
        }
    }
}
