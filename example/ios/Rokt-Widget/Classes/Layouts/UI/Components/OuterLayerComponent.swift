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
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    let viewModel: RoktEmbeddedViewModel
    let style: StylingPropertiesModel?
    let onSizeChange: ((CGFloat) -> Void)?

    var containerStyle: ContainerStylingProperties? { style?.container }
    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }

    let parent: ComponentParentType
    
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil
    
    @State var lastUpdatedHeight:CGFloat = 0

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
        parent: ComponentParentType = .root,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        onSizeChange: ((CGFloat) -> Void)? = nil
    ) {
        self.viewModel = RoktEmbeddedViewModel(layouts: layouts, baseDI: baseDI)
        self.style = style
        self.parent = parent
        _parentWidth = parentWidth
        _parentHeight = parentHeight
        self.onSizeChange = onSizeChange
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
                    parentOverride: nil,
                    defaultHeight: .fitHeight,
                    defaultWidth: .wrapContent
                )
                .readSize(spacing: spacingStyle) { size in
                    availableWidth = size.width
                    availableHeight = size.height
                    DispatchQueue.background.async {
                        notifyHeightChanged(size.height)
                    }
                    
                }
                .onLoad {
                    viewModel.sendOnLoadEvents()
                    Log.i("Rokt: view loaded")
                }
                .onFirstTouch {
                    viewModel.sendSignalActivationEvent()
                }
                .onChange(of: colorScheme) { newColor in
                    viewModel.updateAttributedStrings(newColor)
                }
        }
    }

    private func build(layouts: [LayoutSchemaUIModel]) -> some View {
        VStack(spacing: 0) {
            ForEach(layouts, id: \.self) { child in
                LayoutSchemaComponent(config: ComponentConfig(parent: .column, position: nil),
                                      layout: child,
                                      baseDI: viewModel.baseDI,
                                      parentWidth: $availableWidth,
                                      parentHeight: $availableHeight,
                                      styleState: .constant(.default),
                                      parentOverride: ComponentParentOverride(parentVerticalAlignment: nil, 
                                                                              parentHorizontalAlignment: nil,
                                                                              parentBackgroundStyle: backgroundStyle,
                                                                              stretchChildren: nil))
            }
        }
    }
    
    func notifyHeightChanged(_ newHeight: CGFloat) {
        if lastUpdatedHeight != newHeight {
            onSizeChange?(newHeight)
            lastUpdatedHeight = newHeight
        }
    }
}

@available(iOS 15, *)
class GlobalScreenSize: ObservableObject, Equatable {
    @Published var width: CGFloat?
    @Published var height: CGFloat?
}
