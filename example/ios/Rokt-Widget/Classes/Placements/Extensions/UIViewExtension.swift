//
//  UIViewExtension.swift
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

internal extension UIView {
    func isBoundingBoxHidden() -> Bool {
        return self.window == nil || self.isHidden || self.alpha < 0.1
    }

    func isBoundingBoxCutoff() -> Bool {
        guard let parentView = self.superview else {
            return false
        }

        // calculate current view's rect inside screen coordinate space
        let viewRect = self.convert(self.bounds, to: UIScreen.main.coordinateSpace)
        // calculate parent view's rect inside screen coordinate space
        let parentViewRect = parentView.convert(parentView.bounds, to: UIScreen.main.coordinateSpace)
        return (parentViewRect.intersectPercent(viewRect) < kBoundingBoxCutoffThreshold
                && !parentView.isBoundingBoxCutoff())
    }
}

internal extension UIView {
    func ownerViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.ownerViewController()
        } else {
            return nil
        }
    }
}

// cancellable timers attached to a UIView
// checks if UIView is visible onscreen
private var onBecomingViewedTimer: Timer?
private var viewIntersectionTimer: Timer?

internal extension UIView {
    private func isOwnerViewControllerCurrentVisible() -> Bool {
        UIApplication.topViewController() == ownerViewController()
    }

    func onBecomingViewed(_ execute: @escaping (() -> Void)) {
        onBecomingViewedTimer = Timer.scheduledTimer(
            withTimeInterval: kSignalViewedCheckInterval, repeats: true
        ) { [weak self] timerUntilViewed in
            guard let self else { return }

            let rect = self.convert(self.bounds, to: UIScreen.main.coordinateSpace)

            if UIScreen.main.bounds.intersectPercent(rect) > kSignalViewedIntersectThreshold,
               self.isOwnerViewControllerCurrentVisible() {
                
                timerUntilViewed.invalidate()

                viewIntersectionTimer = Timer.scheduledTimer(
                    withTimeInterval: kSignalViewedTimeThreshold, repeats: false
                ) { _ in
                    if UIScreen.main.bounds.intersectPercent(rect) > kSignalViewedIntersectThreshold {
                        execute()
                    }
                }
            }
        }
    }

    func clearSignalViewedTimers() {
        onBecomingViewedTimer?.invalidate()
        viewIntersectionTimer?.invalidate()

        onBecomingViewedTimer = nil
        viewIntersectionTimer = nil
    }
}
