//
//  DragGestureRecognizer.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/16/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import UIKit

var kSpeedMultiplier: CGFloat = 0.2

class DragGestureRecognizer: UIGestureRecognizer {
    var minimumPressDuration: TimeInterval = 0.0
    var minimumMovement: CGFloat = 0
    var maximumMovement: CFloat = 0
    var frame: CGRect?
    {
        get {
            if let view = self.view {
                return view.bounds
            }
            return .zero
        }
        set {}
    }
    var scrollView: UIScrollView?
    {
        get {
            return enclosingScrollView()
        }
        set {}
    }
    var allowVerticalScrolling: Bool = false
    var allowHorizontalScrolling: Bool = false
    var autoScrollInsets: UIEdgeInsets = .zero
    
    // private
    private var translationInWindow = CGPoint.zero
    private var amountScrolled = CGPoint.zero
    private var scrollSpeed = CGPoint.zero
    private var startLocation = CGPoint.zero
    private var startContentOffset = CGPoint.zero
    private var holding = false
    private var scrolling = false
    private var holdTimer: Timer?
    private var displayLink: CADisplayLink?
    private var nextDeltaTimeZero = false
    private var previousTimestamp: CFTimeInterval = 0

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        allowHorizontalScrolling = true
        allowVerticalScrolling = true
        minimumPressDuration = 0.5
        minimumMovement = 0
        maximumMovement = 10
        autoScrollInsets = UIEdgeInsets(top: 44, left: 44, bottom: 44, right: 44)
    }

    func translation(in view: UIView?) -> CGPoint {
        let totalTranslationInWindow = CGPoint(
            x: translationInWindow.x + amountScrolled.x,
            y: translationInWindow.y + amountScrolled.y)
        var totalTranslationInView = view?.convert(totalTranslationInWindow, from: nil)
        let totalTranslationOfView = view?.convert(CGPoint.zero, from: nil)
        totalTranslationInView = CGPoint(
            x: (totalTranslationInView?.x ?? 0.0) - (totalTranslationOfView?.x ?? 0.0),
            y: (totalTranslationInView?.y ?? 0.0) - (totalTranslationOfView?.y ?? 0.0))
        return totalTranslationInView ?? CGPoint.zero
    }

    func enclosingScrollView() -> UIScrollView? {
        var view = self.view?.superview
        while (view != nil) {
            if view is UIScrollView {
                return view as? UIScrollView
            }
            view = view?.superview
        }
        return nil
    }

    @objc func holdTimerFired(_ timer: Timer?) {
        holding = false
        if canBeginGesture() {
            state = UIGestureRecognizer.State.began
        }
    }

    func canBeginGesture() -> Bool {
        let distance = CGFloat(sqrt(translationInWindow.x * translationInWindow.x + translationInWindow.y * translationInWindow.y))
        return distance >= minimumMovement && state == .possible
    }

    // MARK: - Resetting
    func tearDown() {
        endScrolling()
        holdTimer?.invalidate()
    }

    override func reset() {
        holding = false
        scrolling = false
        translationInWindow = CGPoint.zero
        amountScrolled = CGPoint.zero
        scrollSpeed = CGPoint.zero
    }

    // MARK: - Auto Scrolling
    func beginScrolling() {
        if !scrolling {
            scrolling = true
            nextDeltaTimeZero = true
            previousTimestamp = 0.0
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdate(sender:)))
            displayLink?.add(to: RunLoop.main, forMode: .common)
        }
    }

    func endScrolling() {
        if scrolling {
            scrollSpeed = CGPoint.zero
            displayLink?.invalidate()
            scrolling = false
        }
    }
    
    @objc func displayLinkUpdate(sender: CADisplayLink?) {
        // Figure out the delta time since the last update, then call the update method with that delta.

        let currentTime = displayLink?.timestamp

        var deltaTime: CFTimeInterval
        if nextDeltaTimeZero {
            nextDeltaTimeZero = false
            deltaTime = 0
        } else {
            deltaTime = currentTime! - previousTimestamp
        }
        previousTimestamp = currentTime!

        update(withDelta: deltaTime)
    }
    
    func update(withDelta deltaTime: CFTimeInterval) {
        guard let scrollView = self.scrollView else { return }
        let contentSize = scrollView.contentSize
        let bounds = scrollView.bounds
        let contentInset = scrollView.contentInset

        let maximumContentOffset = CGPoint(
            x: contentSize.width - bounds.size.width + contentInset.right,
            y: contentSize.height - bounds.size.height + contentInset.bottom)
        let minimumContentOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)

        let maximumAmountScrolled = CGPoint(
            x: maximumContentOffset.x - startContentOffset.x,
            y: maximumContentOffset.y - startContentOffset.y)
        let minimumAmountScrolled = CGPoint(
            x: minimumContentOffset.x - startContentOffset.x,
            y: minimumContentOffset.y - startContentOffset.y)

        amountScrolled = CGPoint(
            x: CGFloat(amountScrolled.x + scrollSpeed.x * CGFloat(deltaTime)),
            y: CGFloat(amountScrolled.y + scrollSpeed.y * CGFloat(deltaTime)))

        amountScrolled = CGPoint(
            x: CGFloat(max(minimumAmountScrolled.x, min(maximumAmountScrolled.x, amountScrolled.x))),
            y: CGFloat(max(minimumAmountScrolled.y, min(maximumAmountScrolled.y, amountScrolled.y))))

        let offsetX: CGFloat = startContentOffset.x + amountScrolled.x
        let offsetY: CGFloat = startContentOffset.y + amountScrolled.y
        let offset = CGPoint(x: offsetX, y: offsetY)
        if !scrollView.contentOffset.equalTo(offset) {
            scrollView.contentOffset = offset
            state = UIGestureRecognizer.State.changed
        }
    }
    
    // MARK: - Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let count = event.touches(for: self)?.count ?? 0
        if count != 1 {
            state = UIGestureRecognizer.State.failed
            return
        }

        let touch = touches.first
        let location = touch?.location(in: view)
        if frame!.contains(location ?? CGPoint.zero) == false {
            if let touch = touch {
                ignore(touch, for: event)
            }
            return
        }
        if let startLocation = touch?.location(in: nil) {
            self.startLocation = startLocation
        }
        startContentOffset = scrollView!.contentOffset

        holding = true
        holdTimer = Timer.scheduledTimer(
            timeInterval: minimumPressDuration,
            target: self,
            selector: #selector(holdTimerFired(_:)),
            userInfo: nil,
            repeats: false)
        RunLoop.current.add(holdTimer!, forMode: .common)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        // Update the total translation since the beginning of the gesture (since starting to handle touches, not since state == began)
        guard let touch = touches.first else { return }
        let location = touch.location(in: nil)
        let translation = CGPoint(x: (location.x) - startLocation.x, y: (location.y) - startLocation.y)
        translationInWindow = translation

        // If we're currently still waiting for minimumPressDuration to elapse, check that we didn't move too much. Fail if we did.
        if holding {
            let distance = CGFloat(sqrt(translationInWindow.x * translationInWindow.x + translationInWindow.y * translationInWindow.y))
            if distance > CGFloat(maximumMovement) {
                tearDown()
                state = UIGestureRecognizer.State.failed
            }
        } else {
            // We now waited long enough.
            if state == .possible {
                // If didn't yet begin the gesture, check if we can now (moved the minimumMovement required) and begin if possible.
                if canBeginGesture() {
                    state = UIGestureRecognizer.State.began
                }
            } else {
                // This is the main part, that runs during the gesture.
                // First we need to figure out if we're inside the main area (that doesn't auto-scroll) of the scrollView.
                guard let scrollView = self.scrollView else { return }
                let contentInset = scrollView.contentInset
                let frame = scrollView.frame
                let locationInSuper = touch.location(in: scrollView.superview)
                var insideRect = frame.inset(by: contentInset)
                insideRect = insideRect.inset(by: autoScrollInsets)
                let isInside = insideRect.contains(locationInSuper)

                if isInside {
                    // If we're inside, just reset the state to notify the gesture targets about the change in translation.
                    endScrolling()
                    state = UIGestureRecognizer.State.changed
                } else {
                    // If we're in the auto-scroll area, update the scrolling speed and make sure we have a displayLink running.
                    // The displayLink will take care of scrolling the scrollView and updating the translation.
                    var speedY: CGFloat = 0
                    var speedX: CGFloat = 0
                    if allowVerticalScrolling {
                        speedY = CGFloat(min(0, locationInSuper.y - (frame.origin.y + contentInset.top + autoScrollInsets.top)) + max(0, locationInSuper.y - (frame.origin.y + frame.size.height - contentInset.bottom - autoScrollInsets.bottom)))
                    }
                    if allowHorizontalScrolling {
                        speedX = CGFloat(min(0, locationInSuper.x - (frame.origin.x + contentInset.left + autoScrollInsets.left)) + max(0, locationInSuper.x - (frame.origin.x + frame.size.width - contentInset.right - autoScrollInsets.right)))
                    }
                    scrollSpeed = CGPoint(x: speedX * kSpeedMultiplier * 60, y: speedY * kSpeedMultiplier * 60)
                    beginScrolling()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        tearDown()
        if state == .began || state == .changed {
            state = UIGestureRecognizer.State.ended
        } else {
            state = UIGestureRecognizer.State.failed
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        tearDown()
        if state == .began || state == .changed {
            state = UIGestureRecognizer.State.cancelled
        } else {
            state = UIGestureRecognizer.State.failed
        }
    }

    override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let scrollView = self.scrollView else { return false }
        if otherGestureRecognizer == scrollView.pinchGestureRecognizer {
            return true
        }
        if otherGestureRecognizer == scrollView.panGestureRecognizer {
            return true
        }
        return false
    }


}
