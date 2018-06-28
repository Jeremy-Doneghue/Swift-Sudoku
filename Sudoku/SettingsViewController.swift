//
//  ScannerViewController.swift
//  Sudoku
//
//  Created by Jeremy Doneghue on 28/06/18.
//  Copyright © 2018 Jeremy Doneghue. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func goBackButtonTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "backFromSettings", sender: self)
    }
}
