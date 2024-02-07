//
//  StringExtension.swift
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

internal extension String {
    var htmlAttributed: NSAttributedString? {
        do {
            guard let data = data(using: String.Encoding.utf8) else { return nil }
            
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            Log.d("Error parsing html: \(error)")
            return nil
        }
    }

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    var titleCase: String {
        var words = self.split(separator: " ")
        words = words.map({String($0.first!).uppercased() + $0.dropFirst()})
        return words.joined(separator: " ")
    }
}
