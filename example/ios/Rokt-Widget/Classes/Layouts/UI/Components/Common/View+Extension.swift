//
//  View+Extension.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import SwiftUI

@available(iOS 15, *)
extension View {
    func readSize(spacing: SpacingStylingProperties? = nil, onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { value in
            var newSize = CGSize(width: value.width, height: value.height)
            
            if let padding = spacing?.padding {
                let paddingFrame = FrameAlignmentProperty.getFrameAlignment(padding)
                newSize.width = newSize.width - paddingFrame.left - paddingFrame.right
                newSize.height = newSize.height - paddingFrame.top - paddingFrame.bottom
            }
            
            if let margin = spacing?.margin {
                let marginFrame = FrameAlignmentProperty.getFrameAlignment(margin)
                newSize.width = newSize.width - marginFrame.left - marginFrame.right
                newSize.height = newSize.height - marginFrame.top - marginFrame.bottom
            }
    
            DispatchQueue.main.async {
                onChange(newSize)
            }
        }
    }
    
    // When the view moves inside the SignalViewed area, start timer.
    // When timer is over and view is still inside this area, execute closure.
    func onBecomingViewed(currentOffer: Int? = nil,
                          execute: @escaping (() -> Void)) -> some View {
        background(
            GeometryReader { geometryProxy in
                let intersectPercent = UIScreen.main.bounds.intersectPercent(geometryProxy)
                Color.clear
                    .onAppear {
                        if intersectPercent > kSignalViewedIntersectThreshold {
                            
                            Timer.scheduledTimer(withTimeInterval: kSignalViewedTimeThreshold, repeats: false) { timer in
                                if UIScreen.main.bounds.intersectPercent(geometryProxy) > kSignalViewedIntersectThreshold {
                                    execute()
                                }
                            }
                        }
                    }
                    .onChange(of: intersectPercent) { value in
                        if value > kSignalViewedIntersectThreshold {

                            Timer.scheduledTimer(withTimeInterval: kSignalViewedTimeThreshold, repeats: false) { timer in
                                if UIScreen.main.bounds.intersectPercent(geometryProxy) > kSignalViewedIntersectThreshold {
                                    execute()
                                }
                            }
                        }
                    }
                    .onChange(of: currentOffer) { value in
                        if intersectPercent > kSignalViewedIntersectThreshold {
                            
                            Timer.scheduledTimer(withTimeInterval: kSignalViewedTimeThreshold, repeats: false) { timer in
                                if UIScreen.main.bounds.intersectPercent(geometryProxy) > kSignalViewedIntersectThreshold {
                                    execute()
                                }
                            }
                        }
                    }
            }
        )
    }
    
    @ViewBuilder func `ifLet`<Content: View, T>(
        _ optional: Optional<T>,
        transform: (Self, T) -> Content
    ) -> some View {
        if let optional {
            transform(self, optional)
        } else {
            self
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
