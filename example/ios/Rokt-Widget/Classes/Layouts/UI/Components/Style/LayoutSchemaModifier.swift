//
//  LayoutSchemaModifier.swift
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
struct LayoutSchemaModifier: ViewModifier, SpacingStyleable {
    let verticalAlignmentProperty: VerticalAlignmentProperty
    let horizontalAlignmentProperty: HorizontalAlignmentProperty

    let spacing: SpacingStylingProperties?
    let dimension: DimensionStylingProperties?
    let flex: FlexChildStylingProperties?
    let border: BorderStylingProperties?
    let background: BackgroundStylingProperties?
    let container: ContainerStylingProperties?

    let parent: ComponentParent

    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?

    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?
    let parentBackgroundStyle: BackgroundStylingProperties?

    let verticalAlignmentOverride: VerticalAlignment?
    let horizontalAlignmentOverride: HorizontalAlignment?

    let defaultHeight: HeightFitProperty
    let defaultWidth: WidthFitProperty

    let expandsToContainerOnSelfAlign: Bool
    let overflowAxis: Axis.Set

    let isContainer: Bool

    func body(content: Content) -> some View {
        content
            .padding(frame: getPadding())
            .offset(offset: getOffset())
            // HAS TO BE APPLIED BEFORE BACKGROUND
            .frame(dimension: dimension,
                   weight: flex?.weight,
                   parent: parent,
                   defaultWidth: defaultWidth,
                   parentWidth: parentWidth,
                   defaultHeight: defaultHeight,
                   parentHeight: parentHeight,
                   horizontalAxisAlignment: horizontalAlignmentProperty.getAlignment(),
                   verticalAxisAlignment: verticalAlignmentProperty.getAlignment(),
                   alignSelf: flex?.alignSelf,
                   parentRowAlignment: parentVerticalAlignment,
                   parentColumnAlignment: parentHorizontalAlignment,
                   rowAlignmentOverride: verticalAlignmentOverride,
                   columnAlignmentOverride: horizontalAlignmentOverride,
                   expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign)
            .background(backgroundStyle: background)
            .border(
                borderRadius: border?.borderRadius,
                borderColor: border?.borderColor,
                borderWidth: border?.borderWidth,
                borderStyle: border?.borderStyle
            )
            .overflow(overflow: container?.overflow, axis: overflowAxis)
            .shadow(
                backgroundColor: parentBackgroundStyle?.backgroundColor,
                borderRadius: border?.borderRadius,
                xOffset: container?.shadow?.offsetX,
                yOffset: container?.shadow?.offsetY,
                shadowColor: container?.shadow?.color,
                blurRadius: container?.shadow?.blurRadius,
                isContainer: isContainer
            )
            .margin(frame: getMargin())
    }
}

@available(iOS 15, *)
internal extension View {
    func applyLayoutModifier(
        verticalAlignmentProperty: VerticalAlignmentProperty,
        horizontalAlignmentProperty: HorizontalAlignmentProperty,
        spacing: SpacingStylingProperties?,
        dimension: DimensionStylingProperties?,
        flex: FlexChildStylingProperties?,
        border: BorderStylingProperties?,
        background: BackgroundStylingProperties?,
        container: ContainerStylingProperties? = nil,
        parent: ComponentParent,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        parentVerticalAlignment: VerticalAlignment?,
        parentHorizontalAlignment: HorizontalAlignment?,
        parentBackgroundStyle: BackgroundStylingProperties? = nil,
        verticalAlignmentOverride: VerticalAlignment? = nil,
        horizontalAlignmentOverride: HorizontalAlignment? = nil,
        defaultHeight: HeightFitProperty,
        defaultWidth: WidthFitProperty,
        expandsToContainerOnSelfAlign: Bool = false,
        overFlowAxis: Axis.Set = .vertical,
        isContainer: Bool = false
    ) -> some View {
        modifier(LayoutSchemaModifier(
            verticalAlignmentProperty: verticalAlignmentProperty,
            horizontalAlignmentProperty: horizontalAlignmentProperty,
            spacing: spacing,
            dimension: dimension,
            flex: flex,
            border: border,
            background: background,
            container: container,
            parent: parent,
            parentWidth: parentWidth,
            parentHeight: parentHeight,
            parentVerticalAlignment: parentVerticalAlignment,
            parentHorizontalAlignment: parentHorizontalAlignment,
            parentBackgroundStyle: parentBackgroundStyle,
            verticalAlignmentOverride: verticalAlignmentOverride,
            horizontalAlignmentOverride: horizontalAlignmentOverride,
            defaultHeight: defaultHeight,
            defaultWidth: defaultWidth,
            expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign,
            overflowAxis: overFlowAxis,
            isContainer: isContainer
        ))
    }
}
