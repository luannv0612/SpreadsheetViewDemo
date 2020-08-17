//
//  SpreadsheetView.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/15/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import UIKit

public class SpreadsheetView: UIView {

    public weak var dataSource: SpreadsheetViewDataSource? {
        didSet {
//            resetTouchHandlers(to: [tableView, columnHeaderView, rowHeaderView, cornerView])
            widthColumn = (self.dataSource?.widthForRowHeader(in: self))!
            heightRow = (self.dataSource?.heightForColumHeader(in: self))!
            setNeedsReload()
        }
    }
    
    public var backgroundView: UIView? {
        willSet {
            backgroundView?.removeFromSuperview()
        }
        didSet {
            if let backgroundView = backgroundView {
                backgroundView.frame = bounds
                backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                guard #available(iOS 11.0, *) else {
                    super.insertSubview(backgroundView, at: 0)
                    return
                }
            }
        }
    }
    
    #if swift(>=3.2)
    @available(iOS 11.0, *)
    public override func safeAreaInsetsDidChange() {
        if let backgroundView = backgroundView {
            backgroundView.removeFromSuperview()
            super.insertSubview(backgroundView, at: 0)
        }
    }
    #endif
    var startCenter: CGPoint = .zero
    var startRect: CGRect = .zero
    var itemViewMoveFakeOriginalRect: CGRect = .zero
    var itemViewMoveFake: UIView?
    var widthColumn: CGFloat = 0
    var heightRow: CGFloat = 0
    
    public var stickyRowHeader: Bool = false
    public var stickyColumnHeader: Bool = false
    
    public var hasCheckFocus: Bool = false
    
    public var lineColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)
    
    private var needsReload = true
    public var needsRedraw = true
    
    public var numberOfColumns: Int {
        return layoutProperties.numberOfColumns
    }
    public var numberOfRows: Int {
        return layoutProperties.numberOfRows
    }
    
    var layoutProperties = LayoutProperties()
    var dictItemView = Dictionary<String, AnyObject?>()
    
    let rootView = UIScrollView()
    let columnHeaderView = UIScrollView()
    let rowHeaderView = UIScrollView()
    let tableView = UIScrollView()
    let backgroundTableView = UIView()
    let backgroundColumnHeaderView = UIView()
    let backgroundRowHeaderView = UIView()
    let contentTableView = UIView()
    let itemHighlightView = UIView()
    let bottomLineTableView = UIView()
    let rightLineTableView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        rootView.frame = bounds
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootView.showsHorizontalScrollIndicator = false
        rootView.showsVerticalScrollIndicator = false
        rootView.delegate = self
//        rootView.clipsToBounds = false
        super.addSubview(rootView)
        
        tableView.frame = bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.autoresizesSubviews = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        
        bottomLineTableView.backgroundColor = lineColor
        rightLineTableView.backgroundColor = lineColor
        rootView.insertSubview(bottomLineTableView, at: 0)
        rootView.insertSubview(rightLineTableView, at: 0)
//        tableView.borderColor = lineColor
//        tableView.clipsToBounds = false
        
        backgroundTableView.frame = tableView.bounds
        backgroundTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundTableView.autoresizesSubviews = false
        tableView.insertSubview(backgroundTableView, at: 1)
        backgroundTableView.backgroundColor = .clear
        
        contentTableView.frame = tableView.bounds
        contentTableView.backgroundColor = .clear
        contentTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentTableView.autoresizesSubviews = false
        tableView.insertSubview(contentTableView, at: 2)

        columnHeaderView.frame = bounds
        columnHeaderView.frame.size.width = 60
        columnHeaderView.autoresizingMask = [.flexibleHeight]
        columnHeaderView.autoresizesSubviews = false
        columnHeaderView.showsHorizontalScrollIndicator = false
        columnHeaderView.showsVerticalScrollIndicator = false
        columnHeaderView.isHidden = true
        columnHeaderView.delegate = self
        backgroundColumnHeaderView.backgroundColor = .clear
        columnHeaderView.insertSubview(backgroundColumnHeaderView, at: 0)
//        columnHeaderView.clipsToBounds = false
        columnHeaderView.borderColor = lineColor
//        columnHeaderView.addBorder(toSide: .Top, withColor: lineColor.cgColor, andThickness: 1)
//        columnHeaderView.addBorder(toSide: .Left, withColor: lineColor.cgColor, andThickness: 1)
//        columnHeaderView.addBorder(toSide: .Right, withColor: lineColor.cgColor, andThickness: 1)

        rowHeaderView.frame = bounds
        rowHeaderView.frame.size.height = 60
        rowHeaderView.autoresizingMask = [.flexibleWidth]
        rowHeaderView.autoresizesSubviews = false
        rowHeaderView.showsHorizontalScrollIndicator = false
        rowHeaderView.showsVerticalScrollIndicator = false
        rowHeaderView.isHidden = true
        rowHeaderView.delegate = self
        backgroundRowHeaderView.backgroundColor = .clear
        rowHeaderView.insertSubview(backgroundRowHeaderView, at: 0)
//        rowHeaderView.clipsToBounds = false
        rowHeaderView.borderColor = lineColor
        
        rootView.insertSubview(tableView, at: 0)
        rootView.insertSubview(columnHeaderView, at: 1)
        rootView.insertSubview(rowHeaderView, at: 1)
        
        [tableView, columnHeaderView, rowHeaderView].forEach {
//            addGestureRecognizer($0.panGestureRecognizer)
            #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                $0.contentInsetAdjustmentBehavior = .never
            }
            #endif
        }
    }
    
    public func reloadData() {
        needsReload = false
        setNeedsLayout()
//        layoutTableView()
//        layoutRowHeaderView()
//        layoutColumnHeaderView()
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.needsRedraw = false
        }
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        self.layoutRowHeaderView()
    }

    func reloadDataIfNeeded() {
        if needsReload {
            reloadData()
        }
    }

    private func setNeedsReload() {
        needsReload = true
        needsRedraw = true
        setNeedsLayout()
    }

}
