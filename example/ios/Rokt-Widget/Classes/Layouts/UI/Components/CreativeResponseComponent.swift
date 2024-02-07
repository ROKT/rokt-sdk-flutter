//
//  CreativeResponseComponent.swift
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
struct CreativeResponseComponent: View {
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    let parent: ComponentParent
    let viewModel: CreativeResponseViewModel
    
    @Binding var parentWidth: CGFloat?
    @Binding var parentHeight: CGFloat?
    @State private var availableWidth: CGFloat? = nil
    @State private var availableHeight: CGFloat? = nil
    
    init(
        parent: ComponentParent,
        model: CreativeResponseUIModel,
        baseDI: BaseDependencyInjection,
        parentWidth: Binding<CGFloat?>,
        parentHeight: Binding<CGFloat?>,
        parentVerticalAlignment: VerticalAlignment?,
        parentHorizontalAlignment: HorizontalAlignment?,
        parentBackgroundStyle: BackgroundStylingProperties?
    ) {
        self.parent = parent
        self.viewModel = CreativeResponseViewModel(model: model,
                                           baseDI: baseDI)
        _parentWidth = parentWidth
        _parentHeight = parentHeight

        self.parentVerticalAlignment = parentVerticalAlignment
        self.parentHorizontalAlignment = parentHorizontalAlignment
        self.parentBackgroundStyle = parentBackgroundStyle
    }
    
    @State var styleState: StyleState = .default
    @State var isHovered: Bool = false
    @State var isPressed: Bool = false
    @State var isDisabled: Bool = false
    
    var style: CreativeResponseStyles? {
        switch styleState {
        case .hovered :
            return viewModel.model.hoveredStyle
        case .pressed :
            return viewModel.model.pressedStyle
        case .disabled :
            return viewModel.model.disabledStyle
        default:
            return viewModel.model.defaultStyle
        }
    }

    var containerStyle: ContainerStylingProperties? { style?.container }
    var dimensionStyle: DimensionStylingProperties? { style?.dimension }
    var flexStyle: FlexChildStylingProperties? { style?.flexChild }
    var borderStyle: BorderStylingProperties? { style?.border }
    var spacingStyle: SpacingStylingProperties? { style?.spacing }
    var backgroundStyle: BackgroundStylingProperties? { style?.background }

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
            .readSize { size in
                availableWidth = size.width
                availableHeight = size.height
            }
            .buttonStyle(StateButtonStyle(onStateChanged: { isPressed in
                self.isPressed = isPressed
                updateStyleState()
            }))
    }
    
    func build() -> some View {
        Button(action: {
            viewModel.sendSignalResponseEvent()
            
            if let url = viewModel.getOfferUrl() {
                LinkHandler.creativeLinkHandler(url: url,
                                                viewModel: viewModel,
                                                callback: self)
            } else {
                viewModel.goToNextOffer()
            }
        }, label: {
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
                .contentShape(Rectangle())
        })
    }
    
    func createContainer() -> some View {
        return HStack(alignment: rowPerpendicularAxisAlignment(alignItems: containerStyle?.alignItems), spacing: 0) {
            if let children = viewModel.model.children {
                ForEach(children, id: \.self) { child in
                    LayoutSchemaComponent(parent: .column,
                                          layout: child,
                                          baseDI: viewModel.baseDI,
                                          parentWidth: $availableWidth,
                                          parentHeight: $availableHeight,
                                          styleState: $styleState,
                                          parentVerticalAlignment: rowPerpendicularAxisAlignment(alignItems: containerStyle?.alignItems),
                                          parentHorizontalAlignment: rowPrimaryAxisAlignment(justifyContent: containerStyle?.justifyContent).asHorizontalType,
                                          parentBackgroundStyle: passableBackgroundStyle,
                                          expandsToContainerOnSelfAlign: shouldExpandToContainerOnSelfAlign())
                }
            }
        }
    }

    // if height = fixed or percentage, we need to allow the children to expand. `expandsToContainerOnSelfAlign` will let them use maxHeight=.infinity
    //   since it will only take up its container's finite heigh
    // if height is not specified or fit, we can't use maxHeight=infinity since it will take up all the remaining space in the screen
    private func shouldExpandToContainerOnSelfAlign() -> Bool {
        guard let heightType = viewModel.model.defaultStyle?.dimension?.height else { return false }

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

@available(iOS 15, *)
extension CreativeResponseComponent: RoktWebViewCallback {
    func onWebViewClosed() {
        viewModel.goToNextOffer()
    }
}

@available(iOS 15, *)
struct StateButtonStyle: ButtonStyle {
    var onStateChanged: (Bool) -> Void
    func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .onChange(of: configuration.isPressed) { isChanded in
                    onStateChanged(isChanded)
                }
        }
}
