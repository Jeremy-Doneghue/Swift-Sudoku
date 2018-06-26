//
//  ToggleThemeGesture.swift
//  Sudoku
//
//  Created by Jeremy Doneghue on 26/06/18.
//  Copyright © 2018 Jeremy Doneghue. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class ToggleThemeGesture: UIGestureRecognizer {
    
    enum ActivationDirection {
        case up
        case down
    }
    
    var activationDirection: ActivationDirection = .down
    
    var touchOne : UITouch? = nil
    var touchOneInitialPoint : CGPoint = CGPoint.zero
    
    var touchTwo : UITouch? = nil
    var touchTwoInitialPoint : CGPoint = CGPoint.zero
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        if touches.count != 2 {
            self.state = .failed
            print("Failed in step 1: touches: \(touches.count)")
            return
        }
        
        let touchArray = touches.map({
            (value: UITouch) -> UITouch in
            return value
        })
        if self.touchOne == nil && self.touchTwo == nil {
            self.touchOne = touchArray[0]
            self.touchOneInitialPoint = (self.touchOne?.location(in: self.view))!
            self.touchTwo = touchArray[1]
            self.touchTwoInitialPoint = (self.touchTwo?.location(in: self.view))!
        } else {
            // Ignore all but the first touch.
            for touch in touches {
                if touch != self.touchOne || touch != self.touchTwo {
                    self.ignore(touch, for: event)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if let t1 = self.touchOne, let t2 = self.touchTwo {
            if touches.contains(t1) && touches.contains(t2) {
                
                let touchOneNewPoint = (t1.location(in: self.view))
                let touchTwoNewPoint = (t2.location(in: self.view))
                
                // If the new location is in the wrong direction
                if !newPointsInRightDirection(t1p: touchOneInitialPoint,
                                             t2p: touchTwoInitialPoint,
                                             t1np: touchOneNewPoint,
                                             t2np: touchTwoNewPoint)
                {
                    self.state = .failed
                    print("step 2 failed: opposite of activation direction: \(activationDirection)")
                }
            }
        }
        else {
            self.state = .failed
            print("step 2 failed: different touches")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        if let t1 = self.touchOne, let t2 = self.touchTwo {
            if touches.contains(t1) && touches.contains(t2) {
                
                let touchOneNewPoint = (t1.location(in: self.view))
                let touchTwoNewPoint = (t2.location(in: self.view))
                
                // If the new location is above the start, fail
                if newPointsInRightDirection(t1p: touchOneInitialPoint,
                                             t2p: touchTwoInitialPoint,
                                             t1np: touchOneNewPoint,
                                             t2np: touchTwoNewPoint)
                {
                    self.state = .recognized
                }
                else {
                    self.state = .failed
                    print("step 3 failed: not below")
                }
            }
        }
        else {
            self.state = .failed
            print("step 3 failed: different touches")
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.touchOneInitialPoint = CGPoint.zero
        self.touchTwoInitialPoint = CGPoint.zero
        self.touchOne = nil
        self.touchTwo = nil
        self.state = .cancelled
    }
    
    override func reset() {
        super.reset()
        self.touchOneInitialPoint = CGPoint.zero
        self.touchTwoInitialPoint = CGPoint.zero
        self.touchOne = nil
        self.touchTwo = nil
    }
    
    private func newPointsInRightDirection(t1p: CGPoint, t2p: CGPoint, t1np: CGPoint, t2np: CGPoint) -> Bool {
        
        if self.activationDirection == .up {
            if t1p.y > t1np.y && t2p.y > t2np.y {
                return true
            }
        }
        else if self.activationDirection == .down {
            if t1p.y < t1np.y && t2p.y < t2np.y {
                return true
            }
        }
        return false
    }
}
