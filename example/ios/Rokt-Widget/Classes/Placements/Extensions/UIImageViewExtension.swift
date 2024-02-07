//
//  UIImageViewExtension.swift
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

internal extension UIImageView {
    func loadFromLink(link: String, sessionId: String? = nil,
                      downloadImageCallBack: ((Bool, UIImage?) -> Void)? = nil) {
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    if error != nil {
                        RoktAPIHelper.sendDiagnostics(message: kViewErrorCode ,
                                                      callStack: kOfferImageError + link + error!.localizedDescription,
                                                      sessionId: sessionId)
                    } else {
                        RoktAPIHelper.sendDiagnostics(message: kOfferImageError ,
                                                      callStack: kOfferImageError + link ,
                                                      sessionId: sessionId)
                    }
                    downloadImageCallBack?(false, nil)
                    return
            }
            downloadImageCallBack?(true, image)
            
            }.resume()
    }
    
    func isInDarkMode() -> Bool {
        if #available(iOS 13, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                return true
            }
        }
        return false
    }
}
