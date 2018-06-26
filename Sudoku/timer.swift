//
//  timer.swift
//  Paper Games
//
//  Created by Jeremy Doneghue on 19/02/18.
//  Copyright © 2018 Jeremy Doneghue. All rights reserved.
//

import UIKit
import Foundation

class TimerView: UIView {
    
    var theme = Themes.light {
        didSet {
            timerText.textColor = theme.textColor
        }
    }
    
    var timerText = UILabel()
    var seconds = 0
    var myTimer: Timer!
    var isTimerRunning = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        timerText.text = "00:00:00"
        timerText.frame = frame
        timerText.textColor = UIColor.black //theme.textColor
        self.addSubview(timerText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timerText.frame = self.bounds
    }
    
    @objc func incrementTimer() {
        seconds += 1
        timerText.text = secondsToHoursMins(seconds)
    }
    
    // Turn seconds to formatted string h:m:s
    func secondsToHoursMins(_ seconds: Int) -> String {
        let hours = Int(seconds / 3600)
        let mins = Int(seconds / 60 % 60)
        let secs = seconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, mins, secs)
    }
    
    func invalidateTimer() {
        myTimer.invalidate()
    }
    
    func start() {
        myTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                       target: self,
                                       selector: #selector(incrementTimer),
                                       userInfo: nil,
                                       repeats: true)
    }
    
    func stop() {
        myTimer.invalidate()
    }
    
    func reset() {
        invalidateTimer()
        seconds = 0
        timerText.text = "00:00:00"
    }
}
