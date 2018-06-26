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
    
    var lightsOnGesture: ToggleThemeGesture?
    var lightsOffGesture: ToggleThemeGesture?
    
    var theme = Themes.dark {
        didSet {
            self.view.backgroundColor = theme.backgroundColor
            game.theme = theme
            timer.theme = theme
            keypad.theme = theme
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gsdb = GamestateDeliveryBoy()
        game.setGameStateDeliveryBoy(boy: gsdb!)
        keypad.setGameStateDeliveryBoy(boy: gsdb!)
        game.theme = self.theme
        keypad.theme = self.theme
        
        self.view.backgroundColor = self.theme.backgroundColor
        
        timer.theme = self.theme
        self.view.addSubview(timer)
        timer.start()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.lightsOffGesture = ToggleThemeGesture(target: self, action: #selector(ViewController.lightsOff(_:)))
        self.lightsOffGesture!.activationDirection = .down
        game.addGestureRecognizer(self.lightsOffGesture!)
        
        self.lightsOnGesture = ToggleThemeGesture(target: self, action: #selector(ViewController.lightsOn(_:)))
        self.lightsOnGesture!.activationDirection = .up
        game.addGestureRecognizer(self.lightsOnGesture!)
    }
    
    @objc func lightsOff(_ sender:UITapGestureRecognizer) {
        if sender.state == .recognized {
            if self.theme != Themes.dark {
                print("Nox")
                self.theme = Themes.dark
                lightsOffGesture?.isEnabled = false
                lightsOnGesture?.isEnabled = true
            }
        }
    }
    @objc func lightsOn(_ sender:UITapGestureRecognizer) {
        if sender.state == .recognized {
            if self.theme != Themes.light {
                print("Lumos!")
                self.theme = Themes.light
                lightsOffGesture?.isEnabled = true
                lightsOnGesture?.isEnabled = false
            }
        }
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
        
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let action = UIAlertAction(title: "New game...", style: UIAlertAction.Style.default) { action in
            self.game.resetGame()
            self.timer.reset()
        }
        let settings = UIAlertAction(title: "Settings...", style: UIAlertAction.Style.default) { action in
            //let settingsVC = SettingsVC()
            //settingsVC.previous = self
            //self.present(settingsVC, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in
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

