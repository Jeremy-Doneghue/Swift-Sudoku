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
    
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var clearCellButton: UIButton!
    
    let timer = TimerView(frame: CGRect(x: 16, y: 25, width: 100, height: 20))
    
    var lightsOnGesture: ToggleThemeGesture?
    var lightsOffGesture: ToggleThemeGesture?
    
    var scanningWasSucessful = "yes"
    
    var theme = Themes.black {
        didSet {
            updateTheme(to: theme)
        }
    }
    
    private func updateTheme(to theme: ThemeDescription) {
        
        // Subviews
        game.theme = theme
        timer.theme = theme
        keypad.theme = theme
        
        // Buttons
        hintButton.setTitleColor(theme.buttonColor, for: .normal)
        menuButton.setTitleColor(theme.buttonColor, for: .normal)
        clearCellButton.setTitleColor(theme.buttonColor, for: .normal)
        
        self.view.backgroundColor = theme.backgroundColor
        
        // Save the updated theme to userdefaults
        let userDefaults = UserDefaults.standard
        userDefaults.set(theme.name, forKey: "theme")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gsdb = GamestateDeliveryBoy()
        game.setGameStateDeliveryBoy(boy: gsdb!)
        keypad.setGameStateDeliveryBoy(boy: gsdb!)
        
        game.newGame(gameDescription: game.sampleGame)

        self.view.addSubview(timer)
        timer.start()
        
        // Add observers for app going into background
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Add theme switch gestures
        self.lightsOffGesture = ToggleThemeGesture(target: self, action: #selector(ViewController.lightsOff(_:)))
        self.lightsOffGesture!.activationDirection = .down
        game.addGestureRecognizer(self.lightsOffGesture!)
        
        self.lightsOnGesture = ToggleThemeGesture(target: self, action: #selector(ViewController.lightsOn(_:)))
        self.lightsOnGesture!.activationDirection = .up
        game.addGestureRecognizer(self.lightsOnGesture!)
        
        // Load theme from userdefaults
        let userDefaults = UserDefaults.standard
        if let storedTheme = userDefaults.string(forKey: "theme") {
            if let found = Themes.getThemeByName(name: storedTheme) {
                self.theme = found
            }
        }
        else {
            userDefaults.set(Themes.light.name, forKey: "theme")
            self.theme = Themes.light
        }
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
//            self.game.resetGame()
//            self.timer.reset()
            self.prepareNewGame()
        }
        let settings = UIAlertAction(title: "Settings...", style: UIAlertAction.Style.default) { action in
            
            self.performSegue(withIdentifier: "settingsSegue", sender: self)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in
            print("Pressed")
        }
        menu.addAction(action)
        menu.addAction(settings)
        menu.addAction(cancel)
        
        self.present(menu, animated: true)
    }
    
    private func prepareNewGame() {
        
        let menu = UIAlertController(title: "New Game", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let easy = UIAlertAction(title: "Easy", style: UIAlertAction.Style.default) { action in
            print("Easy-E")
            let easyGame = "007040283|000570900|021080050|603090700|908305400|000700008|700050030|000167802|160208500"
            self.game.newGame(gameDescription: easyGame)
            self.timer.reset()
            self.timer.start()
        }
        let medium = UIAlertAction(title: "Medium", style: UIAlertAction.Style.default) { action in
            print("Medium")
            let mediumGame = "098325000|450700008|700410000|980000200|000900410|100050000|000002745|073009600|064070032"
            self.game.newGame(gameDescription: mediumGame)
            self.timer.reset()
            self.timer.start()
        }
        let hard = UIAlertAction(title: "Hard", style: UIAlertAction.Style.default) { action in
            print("Hard")
            let hardGame = "103092000|205700190|000003000|900000040|030027000|000050207|000280050|000000030|040000976"
            self.game.newGame(gameDescription: hardGame)
            self.timer.reset()
            self.timer.start()
        }
        var scan: UIAlertAction?
        if #available(iOS 11, *) {
            scan = UIAlertAction(title: "Scan from paper...", style: UIAlertAction.Style.default) { action in
                self.performSegue(withIdentifier: "segueToScanner", sender: self)
                self.timer.stop()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { action in
            print("Cancelled")
        }
        menu.addAction(easy)
        menu.addAction(medium)
        menu.addAction(hard)
        if scan != nil { menu.addAction(scan!) }
        menu.addAction(cancel)
        
        self.present(menu, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            print("going to scanner")
        }
    }
    
    @IBAction func unwindFromSettings(segue: UIStoryboardSegue) {
        print("Returned from settings. Does anything need to happen? Probably not.")
    }
    
    @IBAction func unwindFromScanner(segue: UIStoryboardSegue) {
        print("Returned from scanner")
    }
}

