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
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func loadEmbeddedPlacement(sessionId: String, placement: EmbeddedViewData,
                                        onLoad: @escaping (() -> Void), onUnLoad: @escaping (() -> Void),
                                        onEmbeddedSizeChange: @escaping (String, CGFloat) -> Void,
                                        onEvent: @escaping (RoktEventType, RoktEventHandler) -> Void) {
        subviews.forEach({ $0.removeFromSuperview() })
        roktEmbeddedUIView = RoktEmbeddedUIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        if let roktEmbeddedUIView {
            roktEmbeddedUIView.autoresizingMask = [
                UIView.AutoresizingMask.flexibleWidth,
                UIView.AutoresizingMask.flexibleHeight
            ]
            addSubview(roktEmbeddedUIView)
            
            func onSizeChange(name: String, size: CGFloat){
                self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: size)
                for cons in self.constraints where cons.firstAttribute == NSLayoutConstraint.Attribute.height {
                    cons.constant = size
                }
                onEmbeddedSizeChange(name, size)
            }
            
            self.translatesAutoresizingMaskIntoConstraints = true
            
            NSLayoutConstraint.activate([
                self.topAnchor.constraint(equalTo: roktEmbeddedUIView.topAnchor),
                self.leadingAnchor.constraint(equalTo: roktEmbeddedUIView.leadingAnchor),
                self.heightAnchor.constraint(equalToConstant: 0),
                self.trailingAnchor.constraint(equalTo: roktEmbeddedUIView.trailingAnchor)
            ])
            
            roktEmbeddedUIView.initializeEmbeddedWidget(sessionId: sessionId,
                                                        placement: placement,
                                                        onLoad: onLoad,
                                                        onUnLoad: onUnLoad,
                                                        onEmbeddedSizeChange: onSizeChange,
                                                        onEvent: onEvent)
        }
    }
    
    @available(iOS 15, *)
    func loadEmbeddedLayout<Content: View>(baseDI: BaseDependencyInjection,
                                           onUnLoad: @escaping (() -> Void),
                                           onSizeChange: @escaping ((CGFloat) -> Void),
                                           @ViewBuilder builder: () -> Content) {
        subviews.forEach({ $0.removeFromSuperview() })
        let vc = ResizableHostingController(rootView: AnyView(builder()))
        let swiftuiView = vc.view!
        self.roktEmbeddedSwiftUIView = swiftuiView
        
        parentViewControllers?.addChild(vc)
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false

        self.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(swiftuiView)
        
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: 0)
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: swiftuiView.topAnchor),
            self.leadingAnchor.constraint(equalTo: swiftuiView.leadingAnchor),
            self.heightAnchor.constraint(equalToConstant: 0),
            self.trailingAnchor.constraint(equalTo: swiftuiView.trailingAnchor)
        ])
        
        baseDI.actionCollection[DCUIComponent.closeAction] = closeEmbedded
        baseDI.actionCollection[DCUIComponent.unloadAction] = sendUnloadSignal

        func closeEmbedded() {
            // change the size to zero
            updateEmbeddedSize(0)
            // remove view from superView
            swiftuiView.removeFromSuperview()
            self.roktEmbeddedSwiftUIView = nil
            // notify the changes
            onSizeChange(0)

            // call onUnload but don't dismiss view for embedded
            onUnLoad()
        }

        func sendUnloadSignal() {
            onUnLoad()
        }
        
        vc.didMove(toParent: parentViewControllers)
    }
    
    func updateEmbeddedSize(_ size: CGFloat) {
        if roktEmbeddedSwiftUIView != nil {
            for cons in self.constraints where cons.firstAttribute == NSLayoutConstraint.Attribute.height {
                cons.constant = size
                cons.isActive = true
            }
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: size)
            roktEmbeddedSwiftUIView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: size)
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
