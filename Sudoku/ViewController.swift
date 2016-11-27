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
        // Dispose of any resources that can be recreated.
    }


}

