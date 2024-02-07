//
//  UIViewController+Extension.swift
//  Pods
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import UIKit
import SwiftUI

@available(iOS 15, *)
struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

@available(iOS 15, *)
struct ViewControllerHolder {
    weak var value: UIViewController?
}

@available(iOS 15, *)
extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

@available(iOS 15, *)
extension UIViewController {
    func present<Content: View>(placementType: PlacementType?,
                                bottomSheetUIModel: BottomSheetUIModel?,
                                baseDI: BaseDependencyInjection,
                                onLoad: @escaping (() -> Void),
                                onUnLoad: @escaping (() -> Void),
                                @ViewBuilder builder: () -> Content) {
        let modal = SwiftUIViewController(rootView: AnyView(EmptyView().background(Color.clear)),
                                          baseDI: baseDI,
                                          onUnload: onUnLoad)

        baseDI.actionCollection[DCUIComponent.closeAction] = closeOverlay

        if let type = placementType, type == .BottomSheet,
           let bottomSheetUIModel = bottomSheetUIModel {
            applyBottomSheetStyles(modal: modal, bottomSheetUIModel: bottomSheetUIModel)
        } else {
            modal.modalPresentationStyle = .overFullScreen
            modal.view.backgroundColor = .clear
        }

        modal.rootView = AnyView(
            builder()
                .environment(\.viewController, modal)
                .background(Color.clear)
                .onDisappear(perform: {
                    // The viewcontroller is dismissed by touching outside of swipe down
                    if baseDI.eventProcessor.dismissOption == nil {
                        baseDI.eventProcessor.sendDismissalEvent()
                    }
                })
        )
        
        func closeOverlay() {
            modal.dismiss(animated: true, completion: nil)
        }

        modal.view.isOpaque = false
        
        self.present(modal, animated: true, completion: {
            onLoad()
        })
    }
    
    
    @available(iOS 15, *)
    internal func applyBottomSheetStyles(modal: UIHostingController<AnyView>,
                                         bottomSheetUIModel: BottomSheetUIModel) {
        modal.modalPresentationStyle = .pageSheet
        if bottomSheetUIModel.settings?.allowBackdropToClose != true {
            modal.isModalInPresentation = true
        }
        if let borderRadius = bottomSheetUIModel.defaultStyle?.border?.borderRadius {
            modal.sheetPresentationController?.preferredCornerRadius = CGFloat(borderRadius)
        }
        let defaultDetents: [UISheetPresentationController.Detent] = [.medium()]
        if #available(iOS 16.0, *),
           let dimensionType = bottomSheetUIModel.defaultStyle?.dimension?.height {
            modal.sheetPresentationController?.detents = getCustomBottomSheetDetents(
                dimensionType: dimensionType, defaultDetents: defaultDetents)
        } else {
            modal.sheetPresentationController?.detents = defaultDetents
        }
    }
    
    @available(iOS 16.0, *)
    internal func getCustomBottomSheetDetents(dimensionType: DimensionHeightValue,
                                              defaultDetents: [UISheetPresentationController.Detent])
    -> [UISheetPresentationController.Detent] {
        switch dimensionType {
        case .fixed(let value):
            return [.custom { context in
                return CGFloat(value)
            }]
        case .percentage(let value):
            return [.custom { context in
                return context.maximumDetentValue * CGFloat(value/100)
            }]
        case .fit(let type):
            if type == .fitHeight {
                return [.large()]
            } else {
                return defaultDetents
            }
        }
    }
    
}

@available(iOS 15.0, *)
final class SwiftUIViewController: UIHostingController<AnyView> {
    let onUnload: (() -> Void)?
    let baseDI: BaseDependencyInjection?
    required init?(coder: NSCoder) {
        self.onUnload = nil
        self.baseDI = nil
        super.init(coder: coder, rootView: AnyView(EmptyView()))
    }
    
    init(rootView: AnyView, baseDI: BaseDependencyInjection?, onUnload: @escaping (() -> Void)) {
        self.onUnload = onUnload
        self.baseDI = baseDI
        super.init(rootView: rootView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        onUnload?()
    }
    
    func closeModal() {
        if let baseDI {
            baseDI.eventProcessor.dismissOption = .partnerTriggered
            baseDI.eventProcessor.sendDismissalEvent()
        }
        dismiss(animated: true)
    }
}
