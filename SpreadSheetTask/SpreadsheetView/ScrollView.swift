//
//  ScrollView.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/15/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import Foundation
import UIKit

final class ScrollView: UIScrollView, UIGestureRecognizerDelegate {
    var columnRecords = [CGFloat]()
    var rowRecords = [CGFloat]()

    typealias TouchHandler = (_ touches: Set<UITouch>, _ event: UIEvent?) -> Void
    var touchesBegan: TouchHandler?
    var touchesEnded: TouchHandler?
    var touchesCancelled: TouchHandler?
    
    var layoutAttributes = LayoutAttributes(startColumn: 0, startRow: 0, numberOfColumns: 0, numberOfRows: 0, columnCount: 0, rowCount: 0, insets: .zero)

    var state = State()
    struct State {
        var frame = CGRect.zero
        var contentSize = CGSize.zero
        var contentOffset = CGPoint.zero
    }

    var hasDisplayedContent: Bool {
        return columnRecords.count > 0 || rowRecords.count > 0
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer
    }

    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        return hasDisplayedContent
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesBegan?(touches, event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesEnded?(touches, event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesCancelled?(touches, event)
    }
}
