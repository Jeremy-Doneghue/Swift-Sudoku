//
//  ViewController.swift
//  Sudoku
//
//  Created by Jeremy Doneghue on 21/11/16.
//  Copyright © 2016 Jeremy Doneghue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var game: sudokuBoard!
    @IBOutlet weak var keypad: numberPad!
    let timer = TimerView(frame: CGRect(x: 16, y: 25, width: 100, height: 20))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gsdb = GamestateDeliveryBoy()
        game.setGameStateDeliveryBoy(boy: gsdb!)
        keypad.setGameStateDeliveryBoy(boy: gsdb!)
        
        self.view.addSubview(timer)
        timer.start()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationWillEnterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        timer.stop()
    }
    
    @objc func applicationWillEnterForeground() {
        print("App back in focus!")
        timer.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Actions
    @IBAction func clearCellPressed(_ sender: UIButton) {
        game.clearSelectedCell()
    }

    @IBAction func solveButtonPress(_ sender: Any) {
        game.solve(numToSolve: 81)
    }
    
    @IBAction func menuButtonPress(_ sender: Any) {
        
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action = UIAlertAction(title: "New game...", style: UIAlertActionStyle.default) { action in
            self.game.resetGame()
            self.timer.reset()
        }
        let settings = UIAlertAction(title: "Settings...", style: UIAlertActionStyle.default) { action in
            let settingsVC = SettingsVC()
            settingsVC.previous = self
            self.present(settingsVC, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { action in
            print("Pressed")
        }
        menu.addAction(action)
        menu.addAction(settings)
        menu.addAction(cancel)
        
        self.present(menu, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings_segue" {
            print("going to settings")
        }
    }
    
}

