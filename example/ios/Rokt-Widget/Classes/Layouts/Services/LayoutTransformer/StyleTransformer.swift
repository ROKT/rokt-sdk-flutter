//
//  StyleTransformer.swift
//  Rokt-Widget
//
//  Licensed under the Rokt Software Development Kit (SDK) Terms of Use
//  Version 2.0 (the "License");
//
//  You may not use this file except in compliance with the License.
//
//  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/

import Foundation

@available(iOS 13, *)
struct StyleTransformer {
    
    static func getUpdatedStyle(_ defaultStyle: StylingPropertiesModel?,
                                newStyle: StylingPropertiesModel?) -> StylingPropertiesModel? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return StylingPropertiesModel(container: updatedContainer(defaultStyle?.container,
                                                                  newStyle: newStyle?.container),
                                      background: updatedBackground(defaultStyle?.background,
                                                                    newStyle: newStyle?.background),
                                      dimension : updatedDimension(defaultStyle?.dimension,
                                                                   newStyle: newStyle?.dimension),
                                      flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                                   newStyle: newStyle?.flexChild),
                                      spacing: updatedSpacing(defaultStyle?.spacing,
                                                              newStyle: newStyle?.spacing),
                                      border: updatedBorder(defaultStyle?.border,
                                                            newStyle: newStyle?.border))
    }
    
    static func getUpdatedStyle(_ defaultStyle: RowStyle?,
                                newStyle: RowStyle?) -> RowStyle? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return RowStyle(container: updatedContainer(defaultStyle?.container,
                                                    newStyle: newStyle?.container),
                        background: updatedBackground(defaultStyle?.background,
                                                      newStyle: newStyle?.background),
                        border: updatedBorder(defaultStyle?.border,
                                              newStyle: newStyle?.border),
                        dimension : updatedDimension(defaultStyle?.dimension,
                                                     newStyle: newStyle?.dimension),
                        flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                     newStyle: newStyle?.flexChild),
                        spacing: updatedSpacing(defaultStyle?.spacing,
                                                newStyle: newStyle?.spacing))
    }
    
    static func getUpdatedStyle(_ defaultStyle: ColumnStyle?,
                                newStyle: ColumnStyle?) -> ColumnStyle? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return ColumnStyle(container: updatedContainer(defaultStyle?.container,
                                                       newStyle: newStyle?.container),
                           background: updatedBackground(defaultStyle?.background,
                                                         newStyle: newStyle?.background),
                           border: updatedBorder(defaultStyle?.border,
                                                 newStyle: newStyle?.border),
                           dimension : updatedDimension(defaultStyle?.dimension,
                                                        newStyle: newStyle?.dimension),
                           flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                        newStyle: newStyle?.flexChild),
                           spacing: updatedSpacing(defaultStyle?.spacing,
                                                   newStyle: newStyle?.spacing))
    }
    
    static func getUpdatedStyle(_ defaultStyle: OneByOneDistributionStyles?,
                                newStyle: OneByOneDistributionStyles?) -> OneByOneDistributionStyles? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return OneByOneDistributionStyles(container: updatedContainer(defaultStyle?.container,
                                                                      newStyle: newStyle?.container),
                                          background: updatedBackground(defaultStyle?.background,
                                                                        newStyle: newStyle?.background),
                                          border: updatedBorder(defaultStyle?.border,
                                                                newStyle: newStyle?.border),
                                          dimension : updatedDimension(defaultStyle?.dimension,
                                                                       newStyle: newStyle?.dimension),
                                          flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                                       newStyle: newStyle?.flexChild),
                                          spacing: updatedSpacing(defaultStyle?.spacing,
                                                                  newStyle: newStyle?.spacing))
    }
    
    static func getUpdatedStyle(_ defaultStyle: CarouselDistributionStyles?,
                                newStyle: CarouselDistributionStyles?) -> CarouselDistributionStyles? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return CarouselDistributionStyles(container: updatedContainer(defaultStyle?.container,
                                                                      newStyle: newStyle?.container),
                                          background: updatedBackground(defaultStyle?.background,
                                                                        newStyle: newStyle?.background),
                                          border: updatedBorder(defaultStyle?.border,
                                                                newStyle: newStyle?.border),
                                          dimension : updatedDimension(defaultStyle?.dimension,
                                                                       newStyle: newStyle?.dimension),
                                          flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                                       newStyle: newStyle?.flexChild),
                                          spacing: updatedSpacing(defaultStyle?.spacing,
                                                                  newStyle: newStyle?.spacing))
    }
    
    static func getUpdatedStyle(_ defaultStyle: BasicTextStyle?,
                                newStyle: BasicTextStyle?) -> BasicTextStyle? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return BasicTextStyle(dimension : updatedDimension(defaultStyle?.dimension,
                                                           newStyle: newStyle?.dimension),
                              flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                           newStyle: newStyle?.flexChild),
                              spacing: updatedSpacing(defaultStyle?.spacing,
                                                      newStyle: newStyle?.spacing),
                              background: updatedBackground(defaultStyle?.background,
                                                            newStyle: newStyle?.background),
                              text: updatedText(defaultStyle?.text, newStyle: newStyle?.text))
    }
    
    static func getUpdatedStyle(_ defaultStyle: RichTextStyle?,
                                newStyle: RichTextStyle?) -> RichTextStyle? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return RichTextStyle(dimension : updatedDimension(defaultStyle?.dimension,
                                                          newStyle: newStyle?.dimension),
                             flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                          newStyle: newStyle?.flexChild),
                             spacing: updatedSpacing(defaultStyle?.spacing,
                                                     newStyle: newStyle?.spacing),
                             background: updatedBackground(defaultStyle?.background,
                                                           newStyle: newStyle?.background),
                             text: updatedText(defaultStyle?.text, newStyle: newStyle?.text))
    }
    
    static func getUpdatedStyle(_ defaultStyle: StaticImageStyles?,
                                newStyle: StaticImageStyles?) -> StaticImageStyles? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return StaticImageStyles(background: updatedBackground(defaultStyle?.background,
                                                               newStyle: newStyle?.background),
                                 border: updatedBorder(defaultStyle?.border,
                                                       newStyle: newStyle?.border),
                                 dimension : updatedDimension(defaultStyle?.dimension,
                                                              newStyle: newStyle?.dimension),
                                 flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                              newStyle: newStyle?.flexChild),
                                 spacing: updatedSpacing(defaultStyle?.spacing,
                                                         newStyle: newStyle?.spacing))
    }
    
    static func getUpdatedStyle(_ defaultStyle: DataImageStyles?,
                                        newStyle: DataImageStyles?) -> DataImageStyles? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return DataImageStyles(background: updatedBackground(defaultStyle?.background,
                                                             newStyle: newStyle?.background),
                               border: updatedBorder(defaultStyle?.border,
                                                     newStyle: newStyle?.border),
                               dimension : updatedDimension(defaultStyle?.dimension,
                                                            newStyle: newStyle?.dimension),
                               flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                            newStyle: newStyle?.flexChild),
                               spacing: updatedSpacing(defaultStyle?.spacing,
                                                       newStyle: newStyle?.spacing))
    }
    
    static func getUpdatedStyle(_ defaultStyle: CloseButtonStyles?,
                                newStyle: CloseButtonStyles?) -> CloseButtonStyles? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return CloseButtonStyles(container: updatedContainer(defaultStyle?.container,
                                                             newStyle: newStyle?.container),
                                 background: updatedBackground(defaultStyle?.background,
                                                               newStyle: newStyle?.background),
                                 border: updatedBorder(defaultStyle?.border,
                                                       newStyle: newStyle?.border),
                                 dimension : updatedDimension(defaultStyle?.dimension,
                                                              newStyle: newStyle?.dimension),
                                 flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                              newStyle: newStyle?.flexChild),
                                 spacing: updatedSpacing(defaultStyle?.spacing,
                                                         newStyle: newStyle?.spacing))
    }
    
    static func getUpdatedStyle(_ defaultStyle: IndicatorStyles?,
                                        newStyle: IndicatorStyles?) -> IndicatorStyles? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return IndicatorStyles(container: updatedContainer(defaultStyle?.container,
                                                           newStyle: newStyle?.container),
                               background: updatedBackground(defaultStyle?.background,
                                                             newStyle: newStyle?.background),
                               border: updatedBorder(defaultStyle?.border,
                                                     newStyle: newStyle?.border),
                               dimension : updatedDimension(defaultStyle?.dimension,
                                                            newStyle: newStyle?.dimension),
                               flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                            newStyle: newStyle?.flexChild),
                               spacing: updatedSpacing(defaultStyle?.spacing,
                                                       newStyle: newStyle?.spacing),
                               text: updatedText(defaultStyle?.text, newStyle: newStyle?.text))
    }
    
    static func getUpdatedStyle(_ defaultStyle: StaticLinkStyles?,
                                newStyle: StaticLinkStyles?) -> StaticLinkStyles? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return StaticLinkStyles(container: updatedContainer(defaultStyle?.container,
                                                            newStyle: newStyle?.container),
                                background: updatedBackground(defaultStyle?.background,
                                                              newStyle: newStyle?.background),
                                border: updatedBorder(defaultStyle?.border,
                                                      newStyle: newStyle?.border),
                                dimension : updatedDimension(defaultStyle?.dimension,
                                                             newStyle: newStyle?.dimension),
                                flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                             newStyle: newStyle?.flexChild),
                                spacing: updatedSpacing(defaultStyle?.spacing,
                                                        newStyle: newStyle?.spacing))
    }
    
    static func getUpdatedStyle(_ defaultStyle: CreativeResponseStyles?,
                                newStyle: CreativeResponseStyles?) -> CreativeResponseStyles? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return CreativeResponseStyles(container: updatedContainer(defaultStyle?.container,
                                                                  newStyle: newStyle?.container),
                                      background: updatedBackground(defaultStyle?.background,
                                                                    newStyle: newStyle?.background),
                                      border: updatedBorder(defaultStyle?.border,
                                                            newStyle: newStyle?.border),
                                      dimension : updatedDimension(defaultStyle?.dimension,
                                                                   newStyle: newStyle?.dimension),
                                      flexChild : updatedFlexChild(defaultStyle?.flexChild,
                                                                   newStyle: newStyle?.flexChild),
                                      spacing: updatedSpacing(defaultStyle?.spacing,
                                                              newStyle: newStyle?.spacing))
    }
    
    //MARK: Styling properties
    static func updatedContainer(_ defaultStyle: ContainerStylingProperties?,
                                 newStyle: ContainerStylingProperties?) -> ContainerStylingProperties? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return ContainerStylingProperties(justifyContent: newStyle?.justifyContent ?? defaultStyle?.justifyContent,
                                          alignItems: newStyle?.alignItems ?? defaultStyle?.alignItems,
                                          shadow: updatedShadow(defaultStyle?.shadow, newStyle: newStyle?.shadow),
                                          overflow: newStyle?.overflow ?? defaultStyle?.overflow)
    }
    
    static func updatedBackground(_ defaultStyle: BackgroundStylingProperties?,
                                  newStyle: BackgroundStylingProperties?) -> BackgroundStylingProperties? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return BackgroundStylingProperties(backgroundColor: updatedColor(defaultStyle?.backgroundColor,
                                                                         newStyle: newStyle?.backgroundColor),
                                           backgroundImage: updatedBackgroundImage(defaultStyle?.backgroundImage,
                                                                                   newStyle: newStyle?.backgroundImage))
    }
    
    static func updatedDimension(_ defaultStyle: DimensionStylingProperties?,
                                 newStyle: DimensionStylingProperties?) -> DimensionStylingProperties? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return DimensionStylingProperties(minWidth: newStyle?.minWidth ?? defaultStyle?.minWidth,
                                          maxWidth: newStyle?.maxWidth ?? defaultStyle?.maxWidth,
                                          width: newStyle?.width ?? defaultStyle?.width,
                                          minHeight: newStyle?.minHeight ?? defaultStyle?.minHeight,
                                          maxHeight: newStyle?.maxHeight ?? defaultStyle?.maxHeight,
                                          height: newStyle?.height ?? defaultStyle?.height)
    }
    
    static func updatedFlexChild(_ defaultStyle: FlexChildStylingProperties?,
                                 newStyle: FlexChildStylingProperties?) -> FlexChildStylingProperties? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return FlexChildStylingProperties(weight: newStyle?.weight ?? defaultStyle?.weight,
                                          order: newStyle?.order ?? defaultStyle?.order,
                                          alignSelf: newStyle?.alignSelf ?? defaultStyle?.alignSelf)
    }
    
    static func updatedSpacing(_ defaultStyle: SpacingStylingProperties?,
                               newStyle: SpacingStylingProperties?) -> SpacingStylingProperties? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return SpacingStylingProperties(padding: newStyle?.padding ?? defaultStyle?.padding,
                                        margin: newStyle?.margin ?? defaultStyle?.margin,
                                        offset: newStyle?.offset ?? defaultStyle?.offset)
    }
    
    static func updatedBorder(_ defaultStyle: BorderStylingProperties?,
                              newStyle: BorderStylingProperties?) -> BorderStylingProperties? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return BorderStylingProperties(borderRadius: newStyle?.borderRadius ?? defaultStyle?.borderRadius,
                                       borderColor: updatedColor(defaultStyle?.borderColor,
                                                                 newStyle: newStyle?.borderColor),
                                       borderWidth: newStyle?.borderWidth ?? defaultStyle?.borderWidth,
                                       borderStyle: newStyle?.borderStyle ?? defaultStyle?.borderStyle)
    }
    
    static func updatedText(_ defaultStyle: TextStylingProperties?,
                            newStyle: TextStylingProperties?) -> TextStylingProperties? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return TextStylingProperties(textColor: updatedColor(defaultStyle?.textColor, newStyle: newStyle?.textColor),
                                     fontSize: newStyle?.fontSize ?? defaultStyle?.fontSize,
                                     fontFamily: newStyle?.fontFamily ?? defaultStyle?.fontFamily,
                                     fontWeight: newStyle?.fontWeight ?? defaultStyle?.fontWeight,
                                     lineHeight: newStyle?.lineHeight ?? defaultStyle?.lineHeight,
                                     horizontalTextAlign: newStyle?.horizontalTextAlign ?? defaultStyle?.horizontalTextAlign,
                                     baselineTextAlign: newStyle?.baselineTextAlign ?? defaultStyle?.baselineTextAlign,
                                     fontStyle: newStyle?.fontStyle ?? defaultStyle?.fontStyle,
                                     textTransform: newStyle?.textTransform ?? defaultStyle?.textTransform,
                                     letterSpacing: newStyle?.letterSpacing ?? defaultStyle?.letterSpacing,
                                     textDecoration: newStyle?.textDecoration ?? defaultStyle?.textDecoration,
                                     lineLimit: newStyle?.lineLimit ?? defaultStyle?.lineLimit)
    }
    
    //MARK: Styles
    static func updatedShadow(_ defaultStyle: Shadow?,
                              newStyle: Shadow?) -> Shadow? {
        guard let defaultStyle else { return nil }
        return Shadow(offsetX: newStyle?.offsetX ?? defaultStyle.offsetX,
                      offsetY: newStyle?.offsetY ?? defaultStyle.offsetY,
                      blurRadius: newStyle?.blurRadius ?? defaultStyle.blurRadius,
                      spreadRadius: newStyle?.spreadRadius ?? defaultStyle.spreadRadius,
                      color: updatedShadowColor(defaultStyle.color, newStyle: newStyle?.color))
    }
    
    static func updatedShadowColor(_ defaultStyle: ThemeColor,
                             newStyle: ThemeColor?) -> ThemeColor {
        return ThemeColor(light: newStyle?.light ?? defaultStyle.light,
                          dark: newStyle?.dark ?? defaultStyle.dark)
    }
    
    static func updatedColor(_ defaultStyle: ThemeColor?,
                             newStyle: ThemeColor?) -> ThemeColor? {
        guard defaultStyle != nil || newStyle != nil ||
                newStyle?.light != nil || defaultStyle?.light != nil else {return nil}
        return ThemeColor(light: (newStyle?.light ?? defaultStyle?.light) ?? "",
                          dark: newStyle?.dark ?? defaultStyle?.dark)
    }
    
    static func updatedBackgroundImage(_ defaultStyle: BackgroundImage?,
                                       newStyle: BackgroundImage?) -> BackgroundImage? {
        guard defaultStyle != nil || newStyle != nil,
                let updatedUrl = updatedUrl(defaultStyle?.url, newStyle: newStyle?.url) else {return nil}
        return BackgroundImage(url: updatedUrl,
                               position: newStyle?.position ?? defaultStyle?.position,
                               scale: newStyle?.scale ?? defaultStyle?.scale)
    }
    
    static func updatedUrl(_ defaultStyle: ThemeUrl?,
                           newStyle: ThemeUrl?) -> ThemeUrl? {
        guard defaultStyle != nil || newStyle != nil else { return nil }
        return ThemeUrl(light: (newStyle?.light ?? defaultStyle?.light) ?? "",
                        dark: newStyle?.dark ?? defaultStyle?.dark)
    }
    
}
