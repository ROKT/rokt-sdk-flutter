//
//  AlignSelfModifier.swift
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
struct AlignSelfModifier {
    private enum Constant {
        static let defaultAlignment = Alignment.center
    }

    let alignSelf: FlexChildFlexPosition?

    let parent: ComponentParent
    let parentHeight: CGFloat?
    let parentWidth: CGFloat?
    
    let parentRowAlignment: VerticalAlignment?
    let parentColumnAlignment: HorizontalAlignment?

    let wrapperAlignment: Alignment
    let frameMaxWidth: CGFloat?
    let frameMaxHeight: CGFloat?

    let rowAlignmentOverride: VerticalAlignment?
    let columnAlignmentOverride: HorizontalAlignment?

    let expandsToContainerOnSelfAlign: Bool

    init(
        alignSelf: FlexChildFlexPosition?,
        parent: ComponentParent,
        parentHeight: CGFloat?,
        parentWidth: CGFloat?,
        parentRowAlignment: VerticalAlignment? = nil,
        parentColumnAlignment: HorizontalAlignment? = nil,
        rowAlignmentOverride: VerticalAlignment? = nil,
        columnAlignmentOverride: HorizontalAlignment? = nil,
        expandsToContainerOnSelfAlign: Bool = false
    ) {
        self.alignSelf = alignSelf
        self.parent = parent
        self.parentHeight = parentHeight
        self.parentWidth = parentWidth
        self.parentRowAlignment = parentRowAlignment
        self.parentColumnAlignment = parentColumnAlignment
        self.rowAlignmentOverride = rowAlignmentOverride
        self.columnAlignmentOverride = columnAlignmentOverride
        self.expandsToContainerOnSelfAlign = expandsToContainerOnSelfAlign

        self.wrapperAlignment = AlignSelfModifier.getWrapperAlignment(
            alignSelf: alignSelf,
            parent: parent,
            parentRowAlignment: parentRowAlignment,
            parentColumnAlignment: parentColumnAlignment,
            rowAlignmentOverride: rowAlignmentOverride,
            columnAlignmentOverride: columnAlignmentOverride
        ) ?? Constant.defaultAlignment
        self.frameMaxWidth = AlignSelfModifier.getFrameMaxWidth(
            alignSelf: alignSelf,
            parent: parent
        )
        self.frameMaxHeight = AlignSelfModifier.getFrameMaxHeight(
            alignSelf: alignSelf,
            parent: parent,
            expandsToContainerOnSelfAlign: expandsToContainerOnSelfAlign
        )
    }

    private static func getWrapperAlignment(
        alignSelf: FlexChildFlexPosition?,
        parent: ComponentParent,
        parentRowAlignment: VerticalAlignment?,
        parentColumnAlignment: HorizontalAlignment?,
        rowAlignmentOverride: VerticalAlignment? = nil,
        columnAlignmentOverride: HorizontalAlignment? = nil
    ) -> Alignment? {
        switch parent {
        case .row:
            if let rowAlignmentOverride {
                return rowAlignmentOverride.asRowAlignment
            } else {
                return alignSelf?.asRowAlignment ?? parentRowAlignment?.asRowAlignment
            }
        case .column:
            if let columnAlignmentOverride {
                return columnAlignmentOverride.asColumnAlignment
            } else {
                return alignSelf?.asColumnAlignment ?? parentColumnAlignment?.asColumnAlignment
            }
        case .root:
            return .center
        }
    }
    
    private static func getFrameMaxWidth(alignSelf: FlexChildFlexPosition?,
                                    parent: ComponentParent) -> CGFloat? {
        guard !(alignSelf == nil || alignSelf == .stretch) else {
            return nil
        }
        switch parent {
        case .column:
            return .infinity
        default:
            return nil
        }
    }
    
    private static func getFrameMaxHeight(alignSelf: FlexChildFlexPosition?,
                                     parent: ComponentParent,
                                     expandsToContainerOnSelfAlign: Bool) -> CGFloat? {
        guard !(alignSelf == nil || alignSelf == .stretch) else {
            return nil
        }
        switch parent {
        case .row:
            return .infinity
        case .column:
            if expandsToContainerOnSelfAlign {
                return .infinity
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

@available(iOS 13, *)
extension VerticalAlignment {
    var asRowAlignment: Alignment {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .center:
            return .center
        default:
            return .center
        }
    }
}

@available(iOS 13, *)
extension HorizontalAlignment {
    var asColumnAlignment: Alignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        case .center:
            return .center
        default:
            return .center
        }
    }
}

@available(iOS 13, *)
extension FlexChildFlexPosition {
    var asRowAlignment: Alignment {
        switch self {
        case .flexStart:
            return .top
        case .flexEnd:
            return .bottom
        case .center, .stretch:
            return .center
        }
    }

    var asColumnAlignment: Alignment {
        switch self {
        case .flexStart:
            return .leading
        case .flexEnd:
            return .trailing
        case .center, .stretch:
            return .center
        }
    }
}
