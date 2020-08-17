//
//  LayoutEngine.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/15/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import Foundation
import UIKit

struct LayoutProperties {
    let numberOfColumns: Int
    let numberOfRows: Int
    let columnWidth: CGFloat
    let rowHeight: CGFloat
    let columnWidthCache: [CGFloat]
    let rowHeightCache: [CGFloat]

    init(numberOfColumns: Int = 0, numberOfRows: Int = 0,
         columnWidth: CGFloat = 0, rowHeight: CGFloat = 0,
         columnWidthCache: [CGFloat] = [], rowHeightCache: [CGFloat] = []) {
        self.numberOfColumns = numberOfColumns
        self.numberOfRows = numberOfRows
        self.columnWidth = columnWidth
        self.rowHeight = rowHeight
        self.columnWidthCache = columnWidthCache
        self.rowHeightCache = rowHeightCache
    }
}

struct LayoutAttributes {
    let startColumn: Int
    let startRow: Int
    let numberOfColumns: Int
    let numberOfRows: Int
    let columnCount: Int
    let rowCount: Int
    let insets: CGPoint
}

enum RectEdge {
    case top(left: CGFloat, right: CGFloat)
    case bottom(left: CGFloat, right: CGFloat)
    case left(top: CGFloat, bottom: CGFloat)
    case right(top: CGFloat, bottom: CGFloat)
}

struct GridLayout {
    let gridWidth: CGFloat
    let gridColor: UIColor
    let origin: CGPoint
    let length: CGFloat
    let edge: RectEdge
    let priority: CGFloat
}
