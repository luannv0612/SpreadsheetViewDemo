//
//  SpreadsheetView+DragItemView.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/16/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import Foundation
import UIKit

extension SpreadsheetView {
    @objc func dragRecognizer(recognizer: DragGestureRecognizer) {
        guard let view = recognizer.view else { return }
        if (recognizer.state == .began) {
            startCenter = view.center
            startRect = view.frame
            hasCheckFocus = false
            view.superview?.bringSubviewToFront(view)
            UIView.animate(withDuration: 0.2) {
                view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                view.alpha = 0.8
            }
        } else if (recognizer.state == .changed) {
            let translation = recognizer.translation(in: contentTableView)
            let center = CGPoint(x: startCenter.x + translation.x, y: startCenter.y + translation.y)
            view.center = center
            if (!startRect.contains(center) || hasCheckFocus) {
                hasCheckFocus = true
                
                if itemViewMoveFakeOriginalRect != .zero, !itemViewMoveFakeOriginalRect.contains(center), let view = itemViewMoveFake {
                    // move item fake to original frame
                    updateViewToRect(view: view, rect: itemViewMoveFakeOriginalRect)
                    itemViewMoveFakeOriginalRect = .zero
                }
                
                // find rect and bold round
                let positionView: (rect: CGRect, view: UIView?) = findItemViewByPoint(centerPoint: center)
                itemHighlightView.center = positionView.rect.center
                itemHighlightView.borderColor = UIColor(hex: "2F6BFF")!
                
                if let existItemView = positionView.view, positionView.rect != startRect {
                    // check top existItemView is empty
                    let topPosition: (isMove: Bool, rect: CGRect, view: UIView?) = moveExistItemViewToTop(existItemView: existItemView)
                    if (topPosition.isMove && topPosition.view == nil) {
                        itemViewMoveFakeOriginalRect = existItemView.frame
                        itemViewMoveFake = existItemView
                        updateViewToRect(view: existItemView, rect: topPosition.rect)
                    } else {
                        // check bottom existItemView is empty
                        let bottomPosition: (isMove: Bool, rect: CGRect, view: UIView?) = moveExistItemViewToBottom(existItemView: existItemView)
                        if (bottomPosition.isMove && bottomPosition.view == nil) {
                            itemViewMoveFakeOriginalRect = existItemView.frame
                            itemViewMoveFake = existItemView
                            updateViewToRect(view: existItemView, rect: bottomPosition.rect)
                        } else {
                            itemViewMoveFakeOriginalRect = existItemView.frame
                            itemViewMoveFake = existItemView
                            updateViewToRect(view: existItemView, rect: startRect)
                        }
                    }
                }
            }
        } else if (recognizer.state == .ended || recognizer.state == .cancelled) {
            itemViewMoveFakeOriginalRect = .zero
            if (!startRect.contains(view.center)) {
                dragRecognizerEndWithNewFrame(view: view)
                dictItemView.updateValue(nil, forKey: NSCoder.string(for: startRect))
            } else {
                updateViewToRect(view: view, rect: startRect)
            }
            
            UIView.animate(withDuration: 0.2) {
                view.transform = .identity
                view.alpha = 1.0
                self.itemHighlightView.borderColor = .clear
            }
        }else if (recognizer.state == .failed) {
            itemHighlightView.borderColor = .clear
            itemViewMoveFakeOriginalRect = .zero
        }
    }
    
    func updateViewToRect(view: UIView, rect: CGRect) {
        print("updateViewToRect(view: UIView, rect: CGRect) START")
        
        let positionView: (rect: CGRect, view: UIView?) = findItemViewByPoint(centerPoint: view.frame.center)
        let key = NSCoder.string(for: positionView.rect)
        print("Remove In Key: \(key)")
        dictItemView.updateValue(nil, forKey: key)
        
        // Update value
        let positionNewRect: (rect: CGRect, view: UIView?) = findItemViewByPoint(centerPoint: rect.center)
        let newKey = NSCoder.string(for: positionNewRect.rect)
        dictItemView[newKey] = view
        print("Updated In Key: \(newKey)")
        view.center = rect.center
        print("updateViewToRect(view: UIView, rect: CGRect) END")
    }
    
    func moveExistItemViewToTop(existItemView: UIView) -> (Bool, CGRect, UIView?) {
        if existItemView.frame.minY > 0 {
            let pointTop = CGPoint(x: existItemView.frame.midX, y: existItemView.frame.minY - existItemView.frame.height/2)
            let positionView: (rect: CGRect, view: UIView?) = findItemViewByPoint(centerPoint: pointTop)
            return (true, positionView.rect, positionView.view)
        }
        return (false, .zero, nil)
    }
    
    func moveExistItemViewToBottom(existItemView: UIView) -> (Bool, CGRect, UIView?) {
        if existItemView.frame.maxY < contentTableView.frame.maxY {
            let pointBottom = CGPoint(x: existItemView.frame.midX, y: existItemView.frame.maxY + existItemView.frame.height/2)
            let positionView: (rect: CGRect, view: UIView?) = findItemViewByPoint(centerPoint: pointBottom)
            return (true, positionView.rect, positionView.view)
        }
        return (false, .zero, nil)
    }
    
    func findItemViewByPoint(centerPoint: CGPoint) -> (CGRect, UIView?) {
        print("findItemViewByPoint(centerPoint: CGPoint) START")
        var result: (CGRect, UIView?) = (CGRect.zero, nil)
        var center = centerPoint
        center.x = (centerPoint.x > 0.0) ? centerPoint.x: widthColumn / 2
        center.y = (centerPoint.y > 0.0) ? centerPoint.y: heightRow / 2
        
        center.x = (centerPoint.x < contentTableView.frame.width) ? center.x: contentTableView.frame.width - widthColumn / 2
        center.y = (centerPoint.y < contentTableView.frame.height) ? center.y: contentTableView.frame.height - heightRow / 2
        print("==>>>>Point: \(center)")
        dictItemView.keys.forEach { (rectKey) in
            let rectItem = NSCoder.cgRect(for: rectKey)
            print("==>>>>Rect: \(rectKey)")
            if rectItem.contains(center) {
                result = (rectItem, dictItemView[rectKey]) as! (CGRect, UIView?)
                return
            }
        }
        print("findItemViewByPoint(centerPoint: CGPoint) END")
        print("Result: \(result)")
        return result
    }
    
    func dragRecognizerEndWithNewFrame(view: UIView) {
        let positionNew: (rect: CGRect, view: UIView?) = findItemViewByPoint(centerPoint: view.center)
        if let findView = positionNew.view {
            updateViewToRect(view: findView, rect: startRect)
        }
        updateViewToRect(view: view, rect: positionNew.rect)
    }
}
