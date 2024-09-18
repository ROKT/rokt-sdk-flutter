//
//  RoktEmbeddedView.swift
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
import SwiftUI

@objc public class RoktEmbeddedView: UIView {
    var roktEmbeddedUIView: RoktEmbeddedUIView?
    var roktEmbeddedSwiftUIView: UIView?

    var topConstaint: NSLayoutConstraint?
    var leadingConstaint: NSLayoutConstraint?
    var trailingConstaint: NSLayoutConstraint?
    var heightConstaint: NSLayoutConstraint?
    // The default is -1 as 0 is a valid state. -1 means embedded view is not loaded correctly
    private var latestHeight: CGFloat = -1

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    internal func loadEmbeddedPlacement(loadData: EmbeddedPlacementLoadData,
                                        onLoad: @escaping (() -> Void),
                                        onUnLoad: @escaping ((PlacementCompletionType) -> Void),
                                        onEmbeddedSizeChange: @escaping (String, CGFloat) -> Void,
                                        on2stepEvent: @escaping (RoktEventType, RoktEventHandler) -> Void) {
        cleanupEmbeddedView()

        roktEmbeddedUIView = RoktEmbeddedUIView(
            frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        if let roktEmbeddedUIView {
            roktEmbeddedUIView.autoresizingMask = [
                UIView.AutoresizingMask.flexibleWidth,
                UIView.AutoresizingMask.flexibleHeight
            ]
            addSubview(roktEmbeddedUIView)
            Log.i("Rokt: Embedded view attached to the screen")
            func onSizeChange(name: String, size: CGFloat) {
                self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: size)
                for cons in self.constraints where cons.firstAttribute == NSLayoutConstraint.Attribute.height {
                    cons.constant = size
                }
                onEmbeddedSizeChange(name, size)
            }

            decideTranslatesAutoresizingMask()
            addEmbeddedLayoutConstraints(embeddedView: roktEmbeddedUIView)

            roktEmbeddedUIView.initializeEmbeddedWidget(sessionId: loadData.sessionId,
                                                        placement: loadData.placement,
                                                        onLoad: onLoad,
                                                        onUnLoad: onUnLoad,
                                                        onEmbeddedSizeChange: onSizeChange,
                                                        onEvent: on2stepEvent)
        }
    }

    @available(iOS 15, *)
    func loadEmbeddedLayout<Content: View>(baseDI: BaseDependencyInjection,
                                           onUnLoad: @escaping (() -> Void),
                                           onSizeChange: @escaping ((CGFloat) -> Void),
                                           @ViewBuilder builder: () -> Content) {
        cleanupEmbeddedView()

        let vc = ResizableHostingController(rootView: AnyView(builder()))
        let swiftuiView = vc.view!
        self.roktEmbeddedSwiftUIView = swiftuiView

        parentViewControllers?.addChild(vc)
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false

        decideTranslatesAutoresizingMask()

        addSubview(swiftuiView)
        Log.i("Rokt: Embedded view attached to the screen")

        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: 0)
        swiftuiView.frame = self.frame
        addEmbeddedLayoutConstraints(embeddedView: swiftuiView)
        addEmbeddedLayoutActions(baseDI: baseDI,
                                 onUnLoad: onUnLoad,
                                 onSizeChange: onSizeChange,
                                 swiftuiView: swiftuiView)

        vc.didMove(toParent: parentViewControllers)
    }

    @available(iOS 15, *)
    private func addEmbeddedLayoutActions(baseDI: BaseDependencyInjection,
                                          onUnLoad: @escaping (() -> Void),
                                          onSizeChange: @escaping ((CGFloat) -> Void),
                                          swiftuiView: UIView) {
        baseDI.actionCollection[.close] = closeEmbedded
        if Rokt.shared.initFeatureFlags.isEnabled(.boundingBox) {
            baseDI.actionCollection[.checkBoundingBox] = checkBoundingBox
            baseDI.actionCollection[.checkBoundingBoxMissized] = checkBoundingBoxMissized
            // Check the height on the initial load
            checkBoundingBoxMissized()
        }

        func checkBoundingBox(_: Any? = nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + kBoundingBoxCheckDelay) {
                if self.isBoundingBoxHidden() {
                    RoktAPIHelper.sendDiagnostics(message: kLayoutHiddenErrorCode,
                                                  callStack: "Layout hidden",
                                                  severity: .warning,
                                                  sessionId: baseDI.eventProcessor.sessionId)
                }
                checkBoundingBoxMissized()
                if self.isBoundingBoxCutoff() {
                    RoktAPIHelper.sendDiagnostics(message: kLayoutCutoffErrorCode,
                                                  callStack: "Layout cutoff",
                                                  severity: .warning,
                                                  sessionId: baseDI.eventProcessor.sessionId)
                }
            }
        }

        func checkBoundingBoxMissized(_: Any? = nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + kBoundingBoxCheckDelay) {
                if let height = self.heightConstaint?.constant,
                   !height.isEqual(to: self.latestHeight) {
                    let layoutMissizedCallStack = self.latestHeight.isEqual(to: -1)
                        ? "Layout not loaded initially"
                        : "Layout target height is \(self.latestHeight) but actual height is \(height)"
                    RoktAPIHelper.sendDiagnostics(message: kLayoutMissizedErrorCode,
                                                  callStack: layoutMissizedCallStack,
                                                  severity: .warning,
                                                  sessionId: baseDI.eventProcessor.sessionId)
                }
            }
        }

        func closeEmbedded(_: Any? = nil) {
            // change the size to zero
            updateEmbeddedSize(0)
            // remove view from superView
            swiftuiView.removeFromSuperview()
            self.roktEmbeddedSwiftUIView = nil
            // notify the changes
            onSizeChange(0)
            Log.i("Rokt: User journey endded on Embedded view")
            onUnLoad()
        }
    }

    func updateEmbeddedSize(_ size: CGFloat) {
        if roktEmbeddedSwiftUIView != nil {
            Log.i("Rokt: Embedded height resized to \(size)")
            for cons in self.constraints where cons.firstAttribute == NSLayoutConstraint.Attribute.height {
                cons.constant = size
                cons.isActive = true
            }
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: size)
            roktEmbeddedSwiftUIView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: size)
            latestHeight = size
        }
    }

    private func decideTranslatesAutoresizingMask() {
        // translateAutoresizingMaskIntoConstraints only when view doesn't have any constraints.
        if !self.constraints.isEmpty {
            self.translatesAutoresizingMaskIntoConstraints = false
        } else {
            self.translatesAutoresizingMaskIntoConstraints = true
        }
    }

    private func cleanupEmbeddedView() {
        subviews.forEach({ $0.removeFromSuperview() })
        removeEmbeddedLayoutConstraint(topConstaint)
        removeEmbeddedLayoutConstraint(leadingConstaint)
        removeEmbeddedLayoutConstraint(trailingConstaint)
        removeEmbeddedLayoutConstraint(heightConstaint)
    }

    private func addEmbeddedLayoutConstraints(embeddedView: UIView) {
        topConstaint = NSLayoutConstraint(item: self, attribute: .top,
                                          relatedBy: .equal, toItem: embeddedView,
                                          attribute: .top, multiplier: 1, constant: 0)
        leadingConstaint = NSLayoutConstraint(item: self, attribute: .leading,
                                              relatedBy: .equal, toItem: embeddedView,
                                              attribute: .leading, multiplier: 1, constant: 0)
        trailingConstaint = NSLayoutConstraint(item: self, attribute: .trailing,
                                               relatedBy: .equal, toItem: embeddedView,
                                               attribute: .trailing, multiplier: 1, constant: 0)
        heightConstaint = NSLayoutConstraint(item: self, attribute: .height,
                                             relatedBy: .equal, toItem: nil,
                                             attribute: .notAnAttribute, multiplier: 1, constant: 0)
        addEmbeddedLayoutConstraint(topConstaint)
        addEmbeddedLayoutConstraint(leadingConstaint)
        addEmbeddedLayoutConstraint(trailingConstaint)
        addEmbeddedLayoutConstraint(heightConstaint)
    }

    private func addEmbeddedLayoutConstraint(_ layoutConstraint: NSLayoutConstraint?) {
        if let layoutConstraint {
            self.addConstraint(layoutConstraint)
        }
    }

    private func removeEmbeddedLayoutConstraint(_ layoutConstraint: NSLayoutConstraint?) {
        if let layoutConstraint {
            self.removeConstraint(layoutConstraint)
        }
    }
}

@available(iOS 15, *)
class ResizableHostingController<Content>: UIHostingController<Content> where Content: View {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.invalidateIntrinsicContentSize()
    }
}

extension UIResponder {
    public var parentViewControllers: UIViewController? {
        return next as? UIViewController ?? next?.parentViewControllers
    }
}

struct EmbeddedPlacementLoadData {
    let sessionId: String
    let placement: EmbeddedViewData
}
