//
//  CloseButtonComponent.swift
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
struct CloseButtonComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    @State var styleState: StyleState = .default
    @State var isHovered: Bool = false
    @State var isPressed: Bool = false
    @State var isDisabled: Bool = false
    
    var style: CloseButtonStyles? {
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
    let model: CloseButtonUIModel
    let baseDI: BaseDependencyInjection
    
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil
    
    @GestureState private var isPressingDown: Bool = false

    let parentVerticalAlignment: VerticalAlignment?
    let parentHorizontalAlignment: HorizontalAlignment?

    var parentBackgroundStyle: BackgroundStylingProperties?

    var passableBackgroundStyle: BackgroundStylingProperties? {
        backgroundStyle ?? parentBackgroundStyle
    }

    var verticalAlignmentOverride: VerticalAlignment? {
        return containerStyle?.justifyContent?.asVerticalAlignment.vertical
    }
    var horizontalAlignmentOverride: HorizontalAlignment? {
        return containerStyle?.alignItems?.asHorizontalAlignment.horizontal
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
            .onHover { isHovered in
                self.isHovered = isHovered
                updateStyleState()
            }
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
            // contentShape extends tappable area outside of children
            .contentShape(Rectangle())
            .onTapGesture{
                handleClose()
            }
            // consecutive gestures to track when long press is held vs released
            .gesture(LongPressGesture()
                .sequenced(before: LongPressGesture(minimumDuration: .infinity))
                .updating($isPressingDown) { value, state, _ in
                    switch value {
                    case .second(true, nil):
                        state = true
                    default:
                        break
                    }
                }
            )
            .onChange(of: isPressingDown) { value in
                if !value {
                    // handle link when long press is released
                    handleClose()
                }
            }
            .onLongPressGesture(perform: {
            }, onPressingChanged: { isPressed in
                self.isPressed = isPressed
                updateStyleState()
            })
    }
    
    func build() -> some View {
        createContainer()
    }
    
    func createContainer() -> some View {
        return HStack(alignment: rowPerpendicularAxisAlignment(alignItems: containerStyle?.alignItems), spacing: 0) {
            if let children = model.children {
                ForEach(children, id: \.self) { child in
                    LayoutSchemaComponent(parent: .row,
                                          layout: child,
                                          baseDI: baseDI,
                                          parentWidth: $parentWidth,
                                          parentHeight: $parentHeight,
                                          styleState: $styleState,
                                          parentVerticalAlignment: rowPerpendicularAxisAlignment(alignItems: containerStyle?.alignItems),
                                          parentHorizontalAlignment: rowPrimaryAxisAlignment(justifyContent: containerStyle?.justifyContent).asHorizontalType,
                                          parentBackgroundStyle: parentBackgroundStyle,
                                          expandsToContainerOnSelfAlign: shouldExpandToContainerOnSelfAlign())
                }
            }
        }
    }
    
    private func handleClose() {
        baseDI.eventProcessor.dismissOption = .closeButton
        baseDI.eventProcessor.sendDismissalEvent()

        let layoutType = baseDI.layoutType()

        switch layoutType {
        case .embeddedLayout:
            baseDI.actionCollection[DCUIComponent.unloadAction]()
        default:
            baseDI.actionCollection[DCUIComponent.closeAction]()
        }
    }
    
    // if height = fixed or percentage, we need to allow the children to expand. `expandsToContainerOnSelfAlign` will let them use maxHeight=.infinity
    //   since it will only take up its container's finite heigh
    // if height is not specified or fit, we can't use maxHeight=infinity since it will take up all the remaining space in the screen
    private func shouldExpandToContainerOnSelfAlign() -> Bool {
        guard let heightType = style?.dimension?.height else { return false }

        switch heightType {
        case .fixed, .percentage:
            return true
        default:
            return false
        }
    }
    
    private func updateStyleState() {
        if isDisabled {
            styleState = .disabled
        } else {
            if isPressed {
                styleState = .pressed
            } else if isHovered {
                styleState = .hovered
            } else {
                styleState = .default
            }
        }
    }
}
