//
//  SpreadsheetView+Layout.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/15/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import Foundation
import UIKit

extension SpreadsheetView {
    public override func layoutSubviews() {
        super.layoutSubviews()

        tableView.delegate = nil
        columnHeaderView.delegate = nil
        rowHeaderView.delegate = nil

        defer {
            tableView.delegate = self
            columnHeaderView.delegate = self
            rowHeaderView.delegate = self
        }

        reloadDataIfNeeded()

        if needsRedraw {
            layoutRowHeaderView()
            layoutColumnHeaderView()
            layoutTableView()
        }
        
        bottomLineTableView.frame = CGRect(x: tableView.frame.minX, y: tableView.frame.maxY-1, width: tableView.frame.width, height: 1)
        rightLineTableView.frame = CGRect(x: tableView.frame.maxX-1, y: tableView.frame.minY, width: 1, height: tableView.frame.height)
    }
    
    public func layoutColumnHeaderView() {
        columnHeaderView.isHidden = false
        guard let dataSource = dataSource else {
            return
        }
        backgroundColumnHeaderView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        columnHeaderView.frame.origin.y = rowHeaderView.frame.height
        columnHeaderView.frame.size.height = frame.height - rowHeaderView.frame.height
        let numRows = dataSource.numberOfRows(in: self);
        var heightContentSize: CGFloat = 0
        for index in 0...numRows-1 {
            if let cell = dataSource.spreadsheetView(self, cellForRowItemAt: IndexPath.init(row: index, section: 0)) {
                cell.frame.size.width = columnHeaderView.frame.width;
                cell.frame.size.height = dataSource.heightForColumHeader(in: self)
                cell.frame.origin.y = dataSource.heightForColumHeader(in: self) * CGFloat(index)
                
                let bottomLineView = UIView()
                bottomLineView.frame = CGRect(x: 0, y: cell.frame.maxY, width: cell.frame.width, height: 1)
                bottomLineView.backgroundColor = lineColor
                backgroundColumnHeaderView.insertSubview(bottomLineView, at: 1)
                backgroundColumnHeaderView.insertSubview(cell, at: 0)
                heightContentSize += cell.frame.size.height
                }
            }
        columnHeaderView.contentSize.height = heightContentSize
        backgroundColumnHeaderView.frame.size.width = columnHeaderView.frame.width
        backgroundColumnHeaderView.frame.size.height = heightContentSize
        backgroundColumnHeaderView.borderColor = lineColor
    }

    public func layoutRowHeaderView() {
        rowHeaderView.isHidden = false
        guard let dataSource = dataSource else {
            return
        }
        backgroundRowHeaderView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        rowHeaderView.frame.origin.x = columnHeaderView.frame.width
        rowHeaderView.frame.size.width = frame.width - columnHeaderView.frame.width
        
        let numColumn = dataSource.numberOfColumns(in: self);
        var widthContentSize: CGFloat = 0
        for index in 0...numColumn-1 {
            if let cell = dataSource.spreadsheetView(self, cellForColumItemAt: IndexPath.init(row: index, section: 0)) {
                cell.frame.size.width = dataSource.widthForRowHeader(in: self);
                cell.frame.size.height = rowHeaderView.frame.height
                cell.frame.origin.x = dataSource.widthForRowHeader(in: self) * CGFloat(index)
                cell.addBorder(toSide: .Right, withColor: lineColor.cgColor, andThickness: 1)
                print("RowHeaderItem: \(cell.frame)")
                backgroundRowHeaderView.insertSubview(cell, at: 0)
                widthContentSize += cell.frame.size.width
                let rightLineView = UIView()
                rightLineView.frame = CGRect(x: cell.frame.maxX, y: 0, width: 1, height: cell.frame.height)
                rightLineView.backgroundColor = lineColor
                backgroundRowHeaderView.insertSubview(rightLineView, at: 1)
                }
            }
        rowHeaderView.contentSize.width = widthContentSize
        backgroundRowHeaderView.frame.size.width = widthContentSize
        backgroundRowHeaderView.frame.size.height = rowHeaderView.frame.height
        backgroundRowHeaderView.borderColor = lineColor
    }

    func layoutTableView() {
        guard let dataSource = dataSource else {
            return
        }
        let numColums = dataSource.numberOfColumns(in: self)
        let numRows = dataSource.numberOfRows(in: self)
        tableView.frame.origin.x = columnHeaderView.frame.width
        tableView.frame.origin.y = rowHeaderView.frame.height
        tableView.frame.size.width = frame.width - columnHeaderView.frame.width
        tableView.frame.size.height = frame.height - rowHeaderView.frame.height
        
        layoutTableViewBackground()
        layoutContentTableView()
        
        tableView.contentSize.width = widthColumn * CGFloat(numColums)
        tableView.contentSize.height = heightRow * CGFloat(numRows)
    }
    
    private func layoutContentTableView() {
        guard let dataSource = dataSource else {
            return
        }
        let numColums = dataSource.numberOfColumns(in: self)
        let numRows = dataSource.numberOfRows(in: self)
        contentTableView.subviews.forEach({ (view) in
            view.removeFromSuperview()
        })
        dictItemView.removeAll()
        contentTableView.frame.size.width = CGFloat(numColums) * widthColumn
        contentTableView.frame.size.height = CGFloat(numRows) * heightRow
        
        for section in 0...numColums-1 {
            for item in 0...numRows-1 {
                var itemFrame: CGRect = .zero
                itemFrame.origin.x = CGFloat(section) * widthColumn
                itemFrame.origin.y = CGFloat(item) * heightRow
                itemFrame.size = CGSize(width: widthColumn, height: heightRow)
                
                if let itemView = dataSource.spreadsheetView(self, cellForItemAt: IndexPath(item: item, section: section)) {
                    itemView.frame = itemFrame
                    contentTableView.insertSubview(itemView, at: 0)
                    
                    // add gesture
                    let holdDragRecognizer = DragGestureRecognizer()
                    holdDragRecognizer.addTarget(self, action: #selector(dragRecognizer(recognizer:)))
                    itemView.addGestureRecognizer(holdDragRecognizer)
                    
                    dictItemView[NSCoder.string(for: itemFrame)] = itemView
                } else {
                    dictItemView.updateValue(nil, forKey: NSCoder.string(for: itemFrame))
                }
            }
        }
        
    }
    
    private func layoutTableViewBackground() {
        guard let dataSource = dataSource else {
            return
        }
        let numColums = dataSource.numberOfColumns(in: self)
        let numRows = dataSource.numberOfRows(in: self)
        let widthLineRow = widthColumn * CGFloat(numColums)
        let heightLineColum = heightRow * CGFloat(numRows)
        
        backgroundTableView.frame.size.width = CGFloat(numColums) * widthColumn
        backgroundTableView.frame.size.height = CGFloat(numRows) * heightRow
        backgroundTableView.subviews.forEach({ (view) in
            view.removeFromSuperview()
        })
        backgroundTableView.insertSubview(itemHighlightView, at: 1)
        // add line grid colums
        for index in 1...numColums {
            let lineColum = UIView()
            lineColum.backgroundColor = lineColor
            lineColum.frame = CGRect(x: widthColumn * CGFloat(index), y: 0, width: 1, height: heightLineColum)
            backgroundTableView.insertSubview(lineColum, at: 0)
        }
        
        // add line grid rows
        for index in 1...numRows {
            let lineColum = UIView()
            lineColum.backgroundColor = lineColor
            lineColum.frame = CGRect(x: 0, y: heightRow * CGFloat(index), width: widthLineRow, height: 1)
            backgroundTableView.insertSubview(lineColum, at: 0)
        }
        itemHighlightView.frame.size.width = widthColumn
        itemHighlightView.frame.size.height = heightRow
    }
}
