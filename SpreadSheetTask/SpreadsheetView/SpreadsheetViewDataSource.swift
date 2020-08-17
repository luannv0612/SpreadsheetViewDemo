//
//  SpreadsheetViewDataSource.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/15/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import UIKit

public protocol SpreadsheetViewDataSource: class {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int
    
    func heightForColumHeader(in spreadsheetView: SpreadsheetView) -> CGFloat
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForColumItemAt indexPath: IndexPath) -> UIView?

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int
    
    func widthForRowHeader(in spreadsheetView: SpreadsheetView) -> CGFloat
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForRowItemAt indexPath: IndexPath) -> UIView?

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> UIView?
}
