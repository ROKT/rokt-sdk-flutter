//
//  ProgressIndicatorComponent.swift
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
struct ProgressIndicatorComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    let parent: ComponentParent
    let model: ProgressIndicatorUIModel
    let baseDI: BaseDependencyInjection

    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil

    @Binding var currentIndex: Int

    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?

    var style: ProgressIndicatorStyles? {
        model.defaultStyle
    }
    var containerStyle: ContainerStylingProperties? { style?.container }
    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }

    var parentBackgroundStyle: BackgroundStylingProperties?

    var passableBackgroundStyle: BackgroundStylingProperties? {
        backgroundStyle ?? parentBackgroundStyle
    }

    var verticalAlignmentOverride: VerticalAlignment? {
        containerStyle?.justifyContent?.asVerticalAlignment.vertical
    }
    var horizontalAlignmentOverride: HorizontalAlignment? {
        containerStyle?.alignItems?.asHorizontalAlignment.horizontal
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
    
    var startIndex: Int {
        // ensure startIndex is a valid positive integer
        guard let startPosition = model.settings?.startPosition,
              startPosition > 0
        else {
            return 0
        }
        // -1 for index as "startPosition" starts at 1 like indicator position
        return Int(startPosition) - 1
    }

    var totalItems = 0

    init(
        parent: ComponentParent,
        model: ProgressIndicatorUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        parentVerticalAlignment: VerticalAlignment?,
        parentHorizontalAlignment: HorizontalAlignment?,
        parentBackgroundStyle: BackgroundStylingProperties?
    ) {
        self.parent = parent
        self.model = model
        self.baseDI = baseDI

        _parentWidth = parentWidth
        _parentHeight = parentHeight

        self.parentVerticalAlignment = parentVerticalAlignment
        self.parentHorizontalAlignment = parentHorizontalAlignment
        self.parentBackgroundStyle = parentBackgroundStyle

        _currentIndex = baseDI.sharedData.items[SharedData.currentOfferIndexKey] as? Binding<Int> ?? .constant(0)
        totalItems = baseDI.sharedData.items[SharedData.totalItemsKey] as? Int ?? 0
    }

    var body: some View {
        if currentIndex >= startIndex {
            createContainer()
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
                    verticalAlignmentOverride: verticalAlignmentOverride,
                    horizontalAlignmentOverride: horizontalAlignmentOverride,
                    defaultHeight: .wrapContent,
                    defaultWidth: .wrapContent,
                    isContainer: true
                )
                .readSize { size in
                    availableWidth = size.width
                    availableHeight = size.height
                }
        } else {
            EmptyView()
        }
    }

    func createContainer() -> some View {
        return HStack(alignment: rowPerpendicularAxisAlignment(alignItems: containerStyle?.alignItems), spacing: 0) {
            ForEach((startIndex..<totalItems), id:\.self) { index in
                let isSeenIndex = index < currentIndex
                let isActiveIndex = index == currentIndex
                let style = isSeenIndex ? model.seenIndicatorStyle : (
                    isActiveIndex ? model.activeIndicatorStyle :
                        model.indicatorStyle)

                let model = ProgressIndicatorComponent.createAndBindRichTextUIModel(
                    value: "\(index)",
                    dataBinding: model.dataBinding,
                    defaultStyle: style
                )
                RichTextComponent(parent: .row,
                                  model: model,
                                  baseDI: baseDI,
                                  parentWidth: $availableWidth,
                                  parentHeight: $availableHeight,
                                  parentVerticalAlignment:
                                    rowPerpendicularAxisAlignment(alignItems: style?.container?.alignItems ?? containerStyle?.alignItems),
                                  parentHorizontalAlignment:
                                    rowPrimaryAxisAlignment(justifyContent: style?.container?.justifyContent ?? containerStyle?.justifyContent).asHorizontalType,
                                  borderStyle: style?.border)
                // overrides default text color with indicator style's text color
                .foregroundColor(hex: style?.text?.textColor?.adaptiveColor)
            }
        }
    }

    private static func createAndBindRichTextUIModel(
        value: String?,
        dataBinding: DataBinding<String>,
        defaultStyle: IndicatorStyles?
    ) -> RichTextUIModel {
        let model = RichTextUIModel(
            value: value,
            defaultStyle: toTextStyleModel(defaultStyle),
            linkStyle: nil,
            openLinks: nil,
            stateDataExpansionClosure: ProgressIndicatorUIModel.performDataExpansion
        )

        model.updateDataBinding(dataBinding: dataBinding)

        return model
    }
    
    private static func toTextStyleModel(_ style: IndicatorStyles?) -> RichTextStyle? {
        guard let style else { return nil }

        return RichTextStyle(dimension: style.dimension,
                             flexChild: style.flexChild,
                             spacing: style.spacing,
                             background: style.background,
                             text: style.text)
    }
}
