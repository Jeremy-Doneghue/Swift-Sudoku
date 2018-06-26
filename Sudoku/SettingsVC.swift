//
//  SettingsVC.swift
//  Sudoku
//
//  Created by Jeremy Doneghue on 19/06/18.
//  Copyright © 2018 Jeremy Doneghue. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    var previous: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("yeah?")
        let b = UIButton(type: .system)
        b.setTitle("Go back", for: UIControl.State.normal)
        self.view.addSubview(b)
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        b.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = b.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = b.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let widthConstraint = b.widthAnchor.constraint(equalToConstant: 100)
        let heightConstraint = b.heightAnchor.constraint(equalToConstant: 100)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        b.addTarget(self, action: #selector(SettingsVC.buttonAction(_:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func buttonAction(_ sender:UIButton!) {
        self.present(previous, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
