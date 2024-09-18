//
//  FontDiagnosticsViewModel.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

class FontDiagnosticsViewModel {
    var processedFontDiagnostics = Set<FontDiagnostics>()
    
    internal func insertProcessedFontDiagnostics(_ fontFamily: String) -> Bool {
        let pendingFontDiagnostics = FontDiagnostics(fontFamily: fontFamily)
        return processedFontDiagnostics.insert(pendingFontDiagnostics).inserted
    }
}
