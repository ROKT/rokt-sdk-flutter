//
//  StyleComponent.swift
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
internal extension View {
    
    func frame(
        dimension: DimensionStylingProperties?,
        weight: Float?,
        parent: ComponentParent,
        defaultWidth: WidthFitProperty,
        parentWidth: CGFloat?,
        defaultHeight: HeightFitProperty,
        parentHeight: CGFloat?,
        horizontalAxisAlignment: Alignment,
        verticalAxisAlignment: Alignment,
        alignSelf: FlexChildFlexPosition?,
        parentRowAlignment: VerticalAlignment? = nil,
        parentColumnAlignment: HorizontalAlignment? = nil,
        rowAlignmentOverride: VerticalAlignment? = nil,
        columnAlignmentOverride: HorizontalAlignment? = nil,
        expandsToContainerOnSelfAlign: Bool
    ) -> some View {
        var minWidth: CGFloat?
        var maxWidth: CGFloat?
        var minHeight: CGFloat?
        var maxHeight: CGFloat?
        var alignment: Alignment = horizontalAxisAlignment
        
        // update with width values
        let width = WidthModifier(widthProperty: dimension?.width,
                                  minimum: dimension?.minWidth,
                                  maximum: dimension?.maxWidth,
                                  alignment: horizontalAxisAlignment,
                                  defaultWidth: defaultWidth,
                                  parentWidth: parentWidth)
        if width.widthProperty != nil,
           width.isFixedWidth,
           let fixedWidth = width.fixedWidth {
            minWidth = fixedWidth
            maxWidth = fixedWidth
            alignment = width.alignment
        } else {
            if let frameMinWidth = width.frameMinWidth {
                minWidth = frameMinWidth
                alignment = width.alignment
            }
            if let frameMaxWidth = width.frameMaxWidth {
                maxWidth = frameMaxWidth
                alignment = width.alignment
            }
        }
        
        // update with percentage width values
        let percentageWidth = PercentageWidthModifier(width: parentWidth,
                                                      percentage: dimension?.width)
        if let percentageWidth = percentageWidth.frameWidth {
            minWidth = percentageWidth
            maxWidth = percentageWidth
            alignment = horizontalAxisAlignment
        }
        
        
        // update with height values
        let height = HeightModifier(heightProperty: dimension?.height,
                                    minimum: dimension?.minHeight,
                                    maximum: dimension?.maxHeight,
                                    alignment: verticalAxisAlignment,
                                    defaultHeight: defaultHeight,
                                    parentHeight: parentHeight)
        if height.heightProperty != nil,
           height.isFixedHeight,
           let fixedHeight = height.fixedHeight {
            minHeight = fixedHeight
            maxHeight = fixedHeight
            alignment = height.alignment
        } else {
            if let frameMinHeight = height.frameMinHeight {
                minHeight = frameMinHeight
                alignment = height.alignment
            }
            if let frameMaxHeight = height.frameMaxHeight {
                maxHeight = frameMaxHeight
                alignment = height.alignment
            }
        }

        // update with percentage height
        let percentageHeight = PercentageHeightModifier(height: parentHeight,
                                                        percentage: dimension?.height)
        if let percentageHeight = percentageHeight.frameHeight {
            minHeight = percentageHeight
            maxHeight = percentageHeight
            alignment = verticalAxisAlignment
        }
        
        // update with weight
        let weight = WeightModifier(weight: weight,
                                    parent: parent,
                                    verticalAlignment: verticalAxisAlignment,
                                    horizontalAlignment: horizontalAxisAlignment)

        if let frameMaxWidth = weight.frameMaxWidth {
            maxWidth = frameMaxWidth
            alignment = weight.alignment
        }
        if let frameMaxHeight = weight.frameMaxHeight {
            maxHeight = frameMaxHeight
            alignment = weight.alignment
        }
        
        // update with align self stretch
        let alignSelfStretch = AlignSelfStretchModifier(alignSelf: alignSelf,
                                                        parent: parent,
                                                        parentHeight: parentHeight,
                                                        parentWidth: parentWidth,
                                                        parentRowAlignment: parentRowAlignment,
                                                        parentColumnAlignment: parentColumnAlignment)
        if let frameMaxWidth = alignSelfStretch.frameMaxWidth {
            maxWidth = frameMaxWidth
            alignment = alignSelfStretch.wrapperAlignment
        }
        if let frameMaxHeight = alignSelfStretch.frameMaxHeight {
            maxHeight = frameMaxHeight
            alignment = alignSelfStretch.wrapperAlignment
        }
        
        let alignSelf = AlignSelfModifier(alignSelf: alignSelf, parent: parent,
                                          parentHeight: parentHeight,
                                          parentWidth: parentWidth,
                                          parentRowAlignment: parentRowAlignment,
                                          parentColumnAlignment: parentColumnAlignment,
                                          rowAlignmentOverride: rowAlignmentOverride,
                                          columnAlignmentOverride: columnAlignmentOverride,
                                          expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign)
        if alignSelf.frameMaxWidth != nil || alignSelf.frameMaxHeight != nil {
            maxWidth = maxWidth ?? alignSelf.frameMaxWidth
            maxHeight = maxHeight ?? alignSelf.frameMaxHeight
            alignment = alignSelf.wrapperAlignment
        }
        
        return modifier(FrameModifier(minWidth: minWidth,
                                      maxWidth: maxWidth,
                                      minHeight: minHeight,
                                      maxHeight: maxHeight,
                                      alignment: alignment))
    }
    
    func overflow(overflow: Overflow?, axis: Axis.Set) -> some View {
        modifier(OverflowModifier(overFlow: overflow, axis: axis))
    }
    
    func background(backgroundStyle: BackgroundStylingProperties?) -> some View {
        modifier(BackgroundModifier(backgroundStyle: backgroundStyle))
    }
    
    func backgroundColor(hex: String?) -> some View {
        modifier(BackgroundColorModifier(backgroundColor: hex))
    }
    
    func backgroundImage(backgroundImage: BackgroundImage?) -> some View {
        modifier(BackgroundImageModifier(backgroundImage: backgroundImage))
    }
    
    func foregroundColor(hex: String?) -> some View {
        modifier(ForegroundModifier(color: hex))
    }
    
    func padding(frame: FrameAlignmentProperty?) -> some View {
        modifier(PaddingModifier(padding: frame))
    }
    
    func offset(offset: OffsetProperty?) -> some View {
        modifier(OffsetModifier(offset: offset))
    }

    func margin(frame: FrameAlignmentProperty?) -> some View {
        modifier(PaddingModifier(padding: frame))
    }
    
    func border(
        borderRadius: Float?,
        borderColor: ThemeColor?,
        borderWidth: Float?,
        borderStyle: BorderStyle?
    ) -> some View {
        modifier(BorderModifier(borderRadius: borderRadius,
                                borderColor: borderColor,
                                borderWidth: borderWidth,
                                borderStyle: borderStyle))
    }
    
    func shadow(
        backgroundColor: ThemeColor?,
        borderRadius: Float?,
        xOffset: Float?,
        yOffset: Float?,
        shadowColor: ThemeColor?,
        blurRadius: Float?,
        isContainer: Bool
    ) -> some View {
        return modifier(ShadowModifier(
            backgroundColor: backgroundColor?.adaptiveColor,
            borderRadius: borderRadius,
            shadowOffsetX: xOffset,
            shadowOffsetY: yOffset,
            shadowColor: shadowColor,
            blurRadius: blurRadius,
            isContainer: isContainer)
        )
    }
    
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
    
    func onFirstTouch(perform action: (() -> Void)? = nil) -> some View {
        modifier(FirstTouchModifier(perform: action))
    }
    
    // return type must be `Alignment` since Width/Height uses the axis-independent type in `frame`
    func rowPrimaryAxisAlignment(justifyContent: FlexPosition?) -> Alignment  {
        guard let justifyContent else { return .leading }

        return justifyContent.asHorizontalAlignment
    }

    // return type must be `VerticalAlignment` since HStack needs axis-specific type
    func rowPerpendicularAxisAlignment(alignItems: FlexPosition?) -> VerticalAlignment {
        guard let alignItems,
              let horizontalAlignment = alignItems.asVerticalAlignment.asVerticalType
        else { return .top }

        return horizontalAlignment
    }

    // return type must be `Alignment` since Width/Height uses the axis-independent type in `frame`
    func columnPrimaryAxisAlignment(justifyContent: FlexPosition?) -> Alignment  {
        guard let justifyContent else { return .top }

        return justifyContent.asVerticalAlignment
    }

    // return type must be `HorizontalAlignment` since VStack needs axis-specific type
    func columnPerpendicularAxisAlignment(alignItems: FlexPosition?) -> HorizontalAlignment {
        guard let alignItems,
              let horizontalAlignment = alignItems.asHorizontalAlignment.asHorizontalType
        else { return .leading }

        return horizontalAlignment
    }
}

enum StyleState {
    case `default`, pressed, disabled, hovered
}

@available(iOS 15, *)
struct FrameModifier: ViewModifier {
    let minWidth: CGFloat?
    let maxWidth: CGFloat?
    let minHeight: CGFloat?
    let maxHeight: CGFloat?
    let alignment: Alignment

    init(minWidth: CGFloat?,
         maxWidth: CGFloat?,
         minHeight: CGFloat?,
         maxHeight: CGFloat?,
         alignment: Alignment) {
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.alignment = alignment
    }

    func body(content: Content) -> some View {
        content
            .frame(minWidth: minWidth,
                   maxWidth: maxWidth,
                   minHeight: minHeight,
                   maxHeight: maxHeight,
                   alignment: alignment)
    }
}

@available(iOS 15, *)
struct PercentageWidthModifier {
    let width: CGFloat?
    let percentage: DimensionWidthValue?

    init(width: CGFloat?, percentage: DimensionWidthValue?) {
        self.width = width
        self.percentage = percentage
    }
    
    var frameWidth: CGFloat? {
        guard let width,
              let percentage,
              case .percentage(let value) = percentage
        else {
            return nil
        }
        return width * CGFloat(value / 100)
    }
}

@available(iOS 15, *)
struct PercentageHeightModifier {

    let height: CGFloat?
    let percentage: DimensionHeightValue?

    init(height: CGFloat?, percentage: DimensionHeightValue?) {
        self.height = height
        self.percentage = percentage
    }
    
    var frameHeight: CGFloat? {
        guard let height,
              let percentage,
              case .percentage(let value) = percentage
        else {
            return nil
        }
        return height * CGFloat(value / 100)
    }
}

@available(iOS 15, *)
struct WeightModifier {
    let weight: Float?
    let parent:ComponentParent
    let verticalAlignment: Alignment
    let horizontalAlignment: Alignment
    
    var alignment: Alignment {
        switch parent {
        case .row:
            return horizontalAlignment
        case .column:
            return verticalAlignment
        case .root:
            return horizontalAlignment
        }
    }

    var frameMaxHeight: CGFloat? {
        guard let weight, weight != 0 else {
            return nil
        }
        switch parent {
        case .column:
            return .infinity
        default:
            return nil
        }
    }
    
    var frameMaxWidth: CGFloat? {
        guard let weight, weight != 0 else {
            return nil
        }
        switch parent {
        case .row:
            return .infinity
        default:
            return nil
        }
    }
}

@available(iOS 15, *)
struct ForegroundModifier: ViewModifier {
    let color: String?
    
    var foregroundColor: Color? {
        guard let color else { return nil }
        return Color(hex: color)
    }

    func body(content: Content) -> some View {
        content.foregroundColor(foregroundColor)
    }
}

@available(iOS 15, *)
struct PaddingModifier: ViewModifier {
    let padding: FrameAlignmentProperty?

    func body(content: Content) -> some View {
        content
            .padding(.top, padding?.top ?? 0)
            .padding(.leading, padding?.left ?? 0)
            .padding(.bottom, padding?.bottom ?? 0)
            .padding(.trailing, padding?.right ?? 0)
    }
}

@available(iOS 15, *)
struct OffsetModifier: ViewModifier {
    let offset: OffsetProperty?

    func body(content: Content) -> some View {
        content
            .offset(
                x: offset?.x ?? 0,
                y: offset?.y ?? 0
            )
    }
}

@available(iOS 15, *)
struct BorderModifier: ViewModifier {
    let borderRadius: Float?
    let borderColor: ThemeColor?
    let borderWidth: Float?
    let borderStyle: BorderStyle?
    
    func body(content: Content) -> some View {
        content
            .cornerRadius(CGFloat(borderRadius ?? 0))
            .overlay(
                RoundedRectangle(cornerRadius: CGFloat(borderRadius ?? 0))
                    .strokeBorder(
                        Color(hex: borderColor?.adaptiveColor),
                        style: getStrokeStyle(borderWidth: borderWidth ?? 0, borderStyle: borderStyle)
                    )
            )
    }
    
    func getStrokeStyle(borderWidth: Float, borderStyle: BorderStyle?) -> StrokeStyle {
        guard let borderStyle else { return StrokeStyle(lineWidth: CGFloat(borderWidth))}
        
        switch borderStyle {
        case .dashed:
            return StrokeStyle(
                lineWidth: CGFloat(borderWidth),
                dash: [10]
            )
            // To be supported when these styles are in SSoT
//        case .none:
//            return StrokeStyle(dash: [0])
//        case .dotted:
//            return StrokeStyle(
//                lineWidth: CGFloat(borderWidth),
//                lineCap: CGLineCap.round,
//                dash: [1, CGFloat(borderWidth*2)]
//            )
        default:
            return StrokeStyle(
                lineWidth: CGFloat(borderWidth)
            )
        }
    }
}

@available(iOS 15, *)
struct ViewDidLoadModifier: ViewModifier {
    
    @State private var loaded = false
    private let action: (() -> Void)?
    
    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            if !loaded {
                loaded = true
                action?()
            }
        }
    }
}

@available(iOS 15, *)
struct FirstTouchModifier: ViewModifier {
    
    @State private var loaded = false
    private let action: (() -> Void)?
    
    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded({
                if !loaded {
                    loaded = true
                    action?()
                }
            })
        )
    }
}
