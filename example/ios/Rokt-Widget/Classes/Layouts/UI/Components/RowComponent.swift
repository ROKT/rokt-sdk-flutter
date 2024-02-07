//
//  RowComponent.swift
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
struct RowComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    var style: RowStyle? {
        switch styleState {
        case .hovered :
            return model.hoveredStyle
        case .pressed :
            return model.pressedStyle
        case .disabled :
            return model.disabledStyle
        default:
            return model.defaultStyle
        }
    }
    
    var containerStyle: ContainerStylingProperties? { style?.container }
    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }

    let parent: ComponentParent
    let model: RowUIModel
    let baseDI: BaseDependencyInjection

    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @Binding var styleState: StyleState
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil

    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?

    var parentBackgroundStyle: BackgroundStylingProperties?

    var passableBackgroundStyle: BackgroundStylingProperties? {
        backgroundStyle ?? parentBackgroundStyle
    }

    var verticalAlignment: VerticalAlignmentProperty {
        if let justifyContent = containerStyle?.alignItems?.asVerticalAlignmentProperty {
            return justifyContent
        } else if let parentAlign = parentVerticalAlignment?.asVerticalAlignmentProperty {
            return parentAlign
        } else {
            return .top
        }
    }

    var horizontalAlignment: HorizontalAlignmentProperty {
        if let alignItems = containerStyle?.justifyContent?.asHorizontalAlignmentProperty {
            return alignItems
        } else if let parentAlign = parentHorizontalAlignment?.asHorizontalAlignmentProperty {
            return parentAlign
        } else {
            return .start
        }
    }

    var body: some View {
        build()
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
                parentVerticalAlignment: parentVerticalAlignment,
                parentHorizontalAlignment: parentHorizontalAlignment,
                parentBackgroundStyle: passableBackgroundStyle,
                defaultHeight: .wrapContent,
                defaultWidth: .fitWidth,
                overFlowAxis: .horizontal,
                isContainer: true
            )
            // required for alignSelf. don't remove
            .fixedSize(horizontal: false, vertical: true)
            .readSize { size in
                availableWidth = size.width
                availableHeight = size.height
            }
    }
    
    func build() -> some View {
        return HStack(alignment: rowPerpendicularAxisAlignment(alignItems: containerStyle?.alignItems), spacing: 0) {
            if let children = model.children {
                ForEach(children, id: \.self) { child in
                    LayoutSchemaComponent(parent: .row,
                                          layout: child,
                                          baseDI: baseDI,
                                          parentWidth: $availableWidth,
                                          parentHeight: $availableHeight,
                                          styleState: $styleState,
                                          parentVerticalAlignment: rowPerpendicularAxisAlignment(alignItems: containerStyle?.alignItems),
                                          parentHorizontalAlignment: rowPrimaryAxisAlignment(justifyContent: containerStyle?.justifyContent).asHorizontalType,
                                          parentBackgroundStyle: passableBackgroundStyle)
                }
            }
        }
    }

}
