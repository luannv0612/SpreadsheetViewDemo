//
//  SpreadsheetView+UIScrollViewDelegate.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/15/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import Foundation
import UIKit

extension SpreadsheetView : UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        rowHeaderView.delegate = nil
        columnHeaderView.delegate = nil
        tableView.delegate = nil
        defer {
            rowHeaderView.delegate = self
            columnHeaderView.delegate = self
            tableView.delegate = self
        }
//        if tableView.contentOffset.x < 0 && !stickyColumnHeader {
//            let offset = tableView.contentOffset.x * -1
//            columnHeaderView.frame.origin.x = offset
//        } else {
//            columnHeaderView.frame.origin.x = 0
//        }
//        if tableView.contentOffset.y < 0 && !stickyRowHeader {
//            let offset = tableView.contentOffset.y * -1
//            rowHeaderView.frame.origin.y = offset
//        } else {
//            rowHeaderView.frame.origin.y = 0
//        }
        
        if (tableView.contentOffset.x < 0) {
            tableView.contentOffset.x = 0
        }
        if (tableView.contentOffset.y < 0) {
            tableView.contentOffset.y = 0
        }
        
        if (tableView.contentOffset.x > contentTableView.frame.width) {
            tableView.contentOffset.x = contentTableView.frame.width
        }
        if (tableView.contentOffset.y > contentTableView.frame.height) {
            tableView.contentOffset.y = contentTableView.frame.height
        }
        
        rowHeaderView.contentOffset.x = tableView.contentOffset.x
        columnHeaderView.contentOffset.y = tableView.contentOffset.y
//        print("tableView Offset: \(tableView.contentOffset)")

        setNeedsLayout()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        guard let indexPath = pendingSelectionIndexPath else {
//            return
//        }
//        cellsForItem(at: indexPath).forEach { $0.setSelected(true, animated: true) }
//        delegate?.spreadsheetView(self, didSelectItemAt: indexPath)
//        pendingSelectionIndexPath = nil
    }

    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
//        resetScrollViewFrame()
    }
}
