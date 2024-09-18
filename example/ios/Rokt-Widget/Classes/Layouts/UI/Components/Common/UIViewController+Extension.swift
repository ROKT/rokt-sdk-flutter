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
                                @ViewBuilder builder: (((CGFloat) -> Void)?) -> Content) {
        let modal = SwiftUIViewController(rootView: AnyView(EmptyView().background(Color.clear)),
                                          baseDI: baseDI,
                                          onUnload: onUnLoad)
        var isModalLoaded = false
        
        func closeOverlay(_: Any? = nil) {
            modal.dismiss(animated: true, completion: nil)
        }
        
        func onSizeChange(size: CGFloat) {
            DispatchQueue.main.async {
                if #available(iOS 16.0, *),
                   let type = placementType, type == .BottomSheet,
                   bottomSheetUIModel != nil ,
                   let sheet = modal.sheetPresentationController {
                    sheet.animateChanges {
                        sheet.detents = [.custom { context in
                            return size
                        }]
                    }
                    if !isModalLoaded {
                        isModalLoaded = true
                        onLoad()
                    }
                }
            }
        }
        
        modal.rootView = AnyView(
            builder(onSizeChange)
                .environment(\.viewController, modal)
                .background(Color.clear)
        )
        modal.view.isOpaque = false
    
        baseDI.actionCollection[.close] = closeOverlay

        if let type = placementType, type == .BottomSheet,
           let bottomSheetUIModel = bottomSheetUIModel {
            applyBottomSheetStyles(modal: modal, bottomSheetUIModel: bottomSheetUIModel)
            isModalLoaded = didLoadBottomSheetWithHeight(modal: modal, bottomSheetUIModel: bottomSheetUIModel)
        } else {
            modal.modalPresentationStyle = .overFullScreen
            modal.view.backgroundColor = .clear
            isModalLoaded = true
        }
        
        self.present(modal, animated: true, completion: {
            if isModalLoaded {
                onLoad()
            }
        })
    }
    
    internal func applyBottomSheetStyles(modal: UIHostingController<AnyView>,
                                         bottomSheetUIModel: BottomSheetUIModel) {
        modal.modalPresentationStyle = .pageSheet
        if bottomSheetUIModel.allowBackdropToClose != true {
            modal.isModalInPresentation = true
        }
        // update borderRadius if there is a default style
        if let defaultStyle = bottomSheetUIModel.defaultStyle,
           !defaultStyle.isEmpty,
            let borderRadius = defaultStyle[0].border?.borderRadius {
            modal.sheetPresentationController?.preferredCornerRadius = CGFloat(borderRadius)
        }
    }
    
    internal func didLoadBottomSheetWithHeight(modal: UIHostingController<AnyView>,
                                               bottomSheetUIModel: BottomSheetUIModel) -> Bool {
        if #available(iOS 16.0, *),
           let defaultStyle = bottomSheetUIModel.defaultStyle,
           !defaultStyle.isEmpty,
           let dimensionType = defaultStyle[0].dimension?.height {
            if let customDetents = getCustomBottomSheetDetents(dimensionType: dimensionType) {
                modal.sheetPresentationController?.detents = customDetents
                return true
            } else {
                let zeroDetents: [UISheetPresentationController.Detent] = [.custom { context in
                    return CGFloat(0)
                }]
                modal.sheetPresentationController?.detents = zeroDetents
                return false
            }
        } else {
            // Default on iOS 15 and below
            modal.sheetPresentationController?.detents = [.medium()]
            return true
        }
    }
    
    @available(iOS 16.0, *)
    internal func getCustomBottomSheetDetents(dimensionType: DimensionHeightValue)
    -> [UISheetPresentationController.Detent]? {
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
                return nil
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
        // The viewcontroller is dismissed by touching outside of swipe down
        if baseDI?.eventProcessor.dismissOption == nil {
            baseDI?.eventProcessor.sendDismissalEvent()
        }
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
