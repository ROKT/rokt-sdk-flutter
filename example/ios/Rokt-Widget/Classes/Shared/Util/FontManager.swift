//
//  FontManager.swift
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
internal class FontManager {
    static let keyTimestamp = "timestamp"
    static let keyName = "name"
    static let fontExtension = ".ttf"
    static let sevenDays: Double = 7 * 24 * 60 * 60
    
    class func downloadFonts(_ fonts: [FontModel]) {
        if fonts.count > 0 {
            NotificationCenter.default.post(Notification(name: Notification.Name(kDownloadingFonts)))
            var downloadedFonts = 0
            
            for font in fonts {
                guard let fileUrl = getFileUrl(name: font.name) else {
                    Rokt.shared.isInitialized = false
                    RoktAPIHelper.sendDiagnostics(message: kAPIFontErrorCode,
                                                  callStack: "font: \(font.url), error: FileManager default urls")
                    NotificationCenter.default.post(Notification(name:
                                                                    Notification.Name(kFinishedDownloadingFonts)))
                    return
                }
                if isSystemFont(font: font) {
                    downloadedFonts += 1
                    if downloadedFonts == fonts.count {
                        NotificationCenter.default.post(Notification(name:
                            Notification.Name(kFinishedDownloadingFonts)))
                    }
                } else if FontManager.isDownloadingFontRequired(font: font) {
                    let destination: DownloadRequest.DownloadFileDestination = {
                        _, _ in
                        return (fileUrl, [.createIntermediateDirectories, .removePreviousFile])
                    }
                    
                    downloadedFonts += 1
                    RoktNetWorkAPI.downloadFont(font: font, destination: destination, fileUrl: fileUrl,
                                                isLastFont: downloadedFonts == fonts.count)
                } else {
                    registerFont(font: font, fileUrl: fileUrl)
                    downloadedFonts += 1
                    if downloadedFonts == fonts.count {
                        NotificationCenter.default.post(Notification(name:
                            Notification.Name(kFinishedDownloadingFonts)))
                    }
                }
            }
        }
    }
    
    class func registerFont(font: FontModel, fileUrl: URL, isDownloaded: Bool = false) {
        if let fontData = try? NSData(contentsOf: fileUrl, options: [.mappedIfSafe]),
           let dataProvider = CGDataProvider(data: fontData) {
            var errorFont: Unmanaged<CFError>?
            if let cgFont = CGFont(dataProvider) {
                if CTFontManagerRegisterGraphicsFont(cgFont, &errorFont) {
                    Log.d("Font loaded: \(cgFont.fullName ?? "" as CFString)")
                }
                if isDownloaded {
                    saveFontDatails(font: font)
                }
            } else {
                Rokt.shared.isInitialized = false
                RoktAPIHelper.sendDiagnostics(message: kAPIFontErrorCode,
                                              callStack: "font: \(font.url), error: registring font on device")
            }
        } else {
            Rokt.shared.isInitialized = false
            RoktAPIHelper.sendDiagnostics(message: kAPIFontErrorCode,
                                          callStack: "font: \(font.url), error: reading font data")
        }
    }
    
    static func isDownloadingFontRequired(font: FontModel) -> Bool {
        if let storedFont = UserDefaultsDataAccess.getFontDetails(key: font.url),
            let fontTimeStampString = storedFont[keyTimestamp],
            let fontTimeStamp = Double(fontTimeStampString),
            isFontFileExist(name: font.name) && !isFontExpired(timeStamp: fontTimeStamp) {
            return false
        }
        return true
    }
    
    static func isSystemFont(font: FontModel) -> Bool {
        return UIFont.familyNames
            .filter({ $0.lowercased() != "system font" })
            .compactMap { UIFont.fontNames(forFamilyName: $0)}
            .compactMap {
                $0.filter({ $0 == font.name })
            }.filter({ $0.count > 0 }).count > 0
    }
    
    static func saveFontDatails(font: FontModel) {
        UserDefaultsDataAccess.addToFontArray(key: font.url)
        let fontDetail = [keyName: font.name, keyTimestamp: "\(Date().timeIntervalSince1970)"]
        UserDefaultsDataAccess.setFontDetails(key: font.url, values: fontDetail)
    }
    
    static func isFontExpired(timeStamp: Double) -> Bool {
        return Date().timeIntervalSince1970 - timeStamp > sevenDays
    }
    
    static func removeUnusedFonts(fonts: [FontModel]) {
        if var downloadedFonts = UserDefaultsDataAccess.getFontArray() {
            for font in fonts {
                if downloadedFonts.contains(font.url) {
                    downloadedFonts.remove(at: downloadedFonts.firstIndex(of: font.url)!)
                }
            }
            for downloadedFont in downloadedFonts {
                removeFont(key: downloadedFont)
            }
        }
    }
    
    private static func removeFont(key: String) {
        if let storedFont = UserDefaultsDataAccess.getFontDetails(key: key) {
            UserDefaultsDataAccess.removeFontDetails(key: key)
            UserDefaultsDataAccess.removeFontFromFontArray(key: key)
            if let fontName = storedFont[keyName],
               let fileUrl = getFileUrl(name: fontName) {
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    do {
                        try FileManager.default.removeItem(at: fileUrl)
                    } catch {}
                }
            }
        }
    }
    
    internal static func getFileUrl(name: String) -> URL? {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsUrl.appendingPathComponent("\(name)\(fontExtension)")
        }
        return nil
    }
    
    internal static func isFontFileExist(name: String) -> Bool {
        guard let fileURL = getFileUrl(name: name) else { return false }
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
}
