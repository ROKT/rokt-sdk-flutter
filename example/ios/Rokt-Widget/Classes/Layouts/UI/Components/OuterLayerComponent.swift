//
//  RoktEmbeddedComponent.swift
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
struct OuterLayerComponent: View {
    let viewModel: RoktEmbeddedViewModel
    let style: StylingPropertiesModel?

    var containerStyle: ContainerStylingProperties? { style?.container }
    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }

    let parent: ComponentParent
    
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil

    var verticalAlignment: VerticalAlignmentProperty {
        containerStyle?.justifyContent?.asVerticalAlignmentProperty ?? .top
    }

    var horizontalAlignment: HorizontalAlignmentProperty {
        containerStyle?.alignItems?.asHorizontalAlignmentProperty ?? .start
    }
    
    init(
        layouts: [LayoutSchemaUIModel]?,
        style: StylingPropertiesModel?,
        baseDI: BaseDependencyInjection,
        parent: ComponentParent = .root,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>
    ) {
        self.viewModel = RoktEmbeddedViewModel(layouts: layouts, baseDI: baseDI)
        self.style = style
        self.parent = parent
        _parentWidth = parentWidth
        _parentHeight = parentHeight
    }
    
    var body: some View {
        if let layouts = viewModel.layouts {
            build(layouts: layouts)
                .applyLayoutModifier(
                    verticalAlignmentProperty: verticalAlignment,
                    horizontalAlignmentProperty: horizontalAlignment,
                    spacing: spacingStyle,
                    dimension: dimensionStyle,
                    flex: flexStyle,
                    border: borderStyle,
                    background: backgroundStyle,
                    container: containerStyle,
                    parent: parent,
                    parentWidth: $parentWidth,
                    parentHeight: $parentHeight,
                    parentVerticalAlignment: nil,
                    parentHorizontalAlignment: nil,
                    defaultHeight: .fitHeight,
                    defaultWidth: .wrapContent
                )
                .readSize{ size in
                    availableWidth = size.width
                    availableHeight = size.height
                }
                .onLoad {
                    viewModel.sendPluginImpressionEvent()
                }
                .onFirstTouch {
                    viewModel.sendSignalActivationEvent()
                }
        }
    }

    private func build(layouts: [LayoutSchemaUIModel]) -> some View {
        VStack(spacing: 0) {
            ForEach(layouts, id: \.self) { child in
                LayoutSchemaComponent(parent: .column,
                                      layout: child,
                                      baseDI: viewModel.baseDI,
                                      parentWidth: $availableWidth,
                                      parentHeight: $availableHeight,
                                      styleState: .constant(.default),
                                      parentBackgroundStyle: backgroundStyle)
            }
        }
    }
}

@available(iOS 15, *)
class GlobalScreenSize: ObservableObject {
    @Published var width: CGFloat?
    @Published var height: CGFloat?
}
