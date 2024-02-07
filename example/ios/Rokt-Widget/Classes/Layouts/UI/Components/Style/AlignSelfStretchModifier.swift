//
//  AlignSelfStretchModifier.swift
//  Pods
//
//  Created by Emmanuel Tugado on 3/5/2023.
//

import SwiftUI

@available(iOS 15, *)
struct AlignSelfStretchModifier {
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

    init(
        alignSelf: FlexChildFlexPosition?,
        parent: ComponentParent,
        parentHeight: CGFloat?,
        parentWidth: CGFloat?,
        parentRowAlignment: VerticalAlignment?,
        parentColumnAlignment: HorizontalAlignment?,
        rowAlignmentOverride: VerticalAlignment? = nil,
        columnAlignmentOverride: HorizontalAlignment? = nil
    ) {
        self.alignSelf = alignSelf
        self.parent = parent
        self.parentHeight = parentHeight
        self.parentWidth = parentWidth
        self.parentRowAlignment = parentRowAlignment
        self.parentColumnAlignment = parentColumnAlignment
        self.rowAlignmentOverride = rowAlignmentOverride
        self.columnAlignmentOverride = columnAlignmentOverride

        self.wrapperAlignment = AlignSelfStretchModifier.getWrapperAlignment(
            parent: parent,
            parentRowAlignment: parentRowAlignment,
            parentColumnAlignment: parentColumnAlignment,
            rowAlignmentOverride: rowAlignmentOverride,
            columnAlignmentOverride: columnAlignmentOverride
        ) ?? Constant.defaultAlignment
        self.frameMaxWidth = AlignSelfStretchModifier.getFrameMaxWidth(
            alignSelf: alignSelf,
            parent: parent
        )
        self.frameMaxHeight = AlignSelfStretchModifier.getFrameMaxHeight(
            alignSelf: alignSelf,
            parent: parent
        )
    }

    private static func getWrapperAlignment(
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
                return parentRowAlignment?.asRowAlignment
            }
        case .column:
            if let columnAlignmentOverride {
                return columnAlignmentOverride.asColumnAlignment
            } else {
                return parentColumnAlignment?.asColumnAlignment
            }
        case .root:
            return .center
        }
    }
    private static func getFrameMaxWidth(alignSelf: FlexChildFlexPosition?,
                                         parent: ComponentParent) -> CGFloat? {
        guard alignSelf == .stretch else {
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
                                          parent: ComponentParent) -> CGFloat? {
        guard alignSelf == .stretch else {
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
