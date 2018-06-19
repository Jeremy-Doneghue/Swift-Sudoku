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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gsdb = GamestateDeliveryBoy()
        game.setGameStateDeliveryBoy(boy: gsdb!)
        keypad.setGameStateDeliveryBoy(boy: gsdb!)
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
        }
        let settings = UIAlertAction(title: "Settings...", style: UIAlertActionStyle.default) { action in
            self.performSegue(withIdentifier: "settings_segue", sender: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { action in
            print("Pressed")
        }
        menu.addAction(action)
        menu.addAction(settings)
        menu.addAction(cancel)
        
        self.present(menu, animated: true)
    }
    
}

