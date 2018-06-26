//
//  numberPad.swift
//  Sudoku
//
//  Created by Jeremy Doneghue on 22/11/16.
//  Copyright © 2016 Jeremy Doneghue. All rights reserved.
//

import UIKit

class numberPad: UIView {

    // MARK: Properties
    
    var gsdb: GamestateDeliveryBoy = GamestateDeliveryBoy()!
    var _WIDTH: CGFloat = 0
    var _HEIGHT: CGFloat = 0
    
    var buttonWidth: CGFloat = 0
    var buttonHeight: CGFloat = 0
    
    var numpadDigitBoundingBoxes: [CGRect] = [CGRect()]
    var numpadButtonBoxes: [CGRect] = [CGRect()]
    var mostRecentNumpadButtonPressed: Int = -1
    
    let lineWidth: CGFloat = 0.5
    
    var buttonSelected = false
    var selected: Bool {
        get { return buttonSelected }
    }
    
    func setGameStateDeliveryBoy(boy: GamestateDeliveryBoy) {
        self.gsdb = boy
        self.gsdb.setNumberPad(np: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _WIDTH = self.bounds.width
        _HEIGHT = self.bounds.height
        
        buttonWidth = self.bounds.width / 3
        buttonHeight = self.bounds.height / 3
        
        let width12th = _WIDTH / 12
        let height12th = _HEIGHT / 12
        let width6th = _WIDTH / 6
        let height6th = _HEIGHT / 6
        let width3rd = _WIDTH / 3
        let height3rd = _HEIGHT / 3
        
        numpadDigitBoundingBoxes = [
            
            CGRect(x: width12th,     y: height12th,     width: width6th, height: height6th), //1
            CGRect(x: width12th * 5, y: height12th,     width: width6th, height: height6th), //2
            CGRect(x: width12th * 9, y: height12th,     width: width6th, height: height6th), //3
            
            CGRect(x: width12th,     y: height12th * 5, width: width6th, height: height6th), //4
            CGRect(x: width12th * 5, y: height12th * 5, width: width6th, height: height6th), //5
            CGRect(x: width12th * 9, y: height12th * 5, width: width6th, height: height6th), //6
            
            CGRect(x: width12th,     y: height12th * 9, width: width6th, height: height6th), //7
            CGRect(x: width12th * 5, y: height12th * 9, width: width6th, height: height6th), //8           
            CGRect(x: width12th * 9, y: height12th * 9, width: width6th, height: height6th), //9
        ]
        
        numpadButtonBoxes = [
        
            CGRect(x: 0,            y: 0,             width: width3rd, height: height3rd), //1
            CGRect(x: width3rd,     y: 0,             width: width3rd, height: height3rd), //2
            CGRect(x: width3rd * 2, y: 0,             width: width3rd, height: height3rd), //3
            
            CGRect(x: 0,            y: height3rd,     width: width3rd, height: height3rd), //4
            CGRect(x: width3rd,     y: height3rd,     width: width3rd, height: height3rd), //5
            CGRect(x: width3rd * 2, y: height3rd,     width: width3rd, height: height3rd), //6
            
            CGRect(x: 0,            y: height3rd * 2, width: width3rd, height: height3rd), //7
            CGRect(x: width3rd,     y: height3rd * 2, width: width3rd, height: height3rd), //8
            CGRect(x: width3rd * 2, y: height3rd * 2, width: width3rd, height: height3rd)  //9
        ]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sudokuBoard.viewIsTapped(_:)))
        self.addGestureRecognizer(tap)
    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(lineWidth)
        
        if mostRecentNumpadButtonPressed != -1 {
            ctx?.setFillColor(UIColor.gray.cgColor)
            ctx?.fill(numpadButtonBoxes[mostRecentNumpadButtonPressed - 1])
        }
        
        // Draw the outer boxes
        for rect in numpadButtonBoxes {
            ctx?.stroke(rect)
        }
        
        var i = 1
        for rect in numpadDigitBoundingBoxes {
            //ctx?.stroke(rect) draw bounding boxes
            drawText(rect: rect, text: String(i), font: UIFont.systemFont(ofSize: 30))
            i += 1
        }        
    }
    
    
    /*
     *  Render some text in a rectangle with the defined attributes
     */
    func drawText (rect: CGRect, text: String, font: UIFont) {
        
        //set text color to black
        let textColor: UIColor = UIColor.black
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.center
        
        // set the Obliqueness to 0
        let skew = 0
        
        let attributes: NSDictionary = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paraStyle,
            convertFromNSAttributedStringKey(NSAttributedString.Key.obliqueness): skew,
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font
        ]
        
        text.draw(in: rect, withAttributes: convertToOptionalNSAttributedStringKeyDictionary((attributes as! [String : Any])))
    }
    
    /*
     *  Return the number of the button underneath a certain point on the numpad
     */
    private func getButtonCellIndex(location: CGPoint) -> Int {
        
        var cellX: CGFloat = 0
        var cellY: CGFloat = 0
        var xCellIndex = 0
        var yCellIndex = 0
        
        while cellX < location.x {
            cellX += buttonWidth
            xCellIndex += 1
        }
        while cellY < location.y {
            cellY += buttonHeight
            yCellIndex += 1
        }
        
        let numpadButtonValues: [[Int]] = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9]
        ]
        
        return numpadButtonValues[yCellIndex - 1][xCellIndex - 1]
    }
    
    @objc func viewIsTapped(_ sender:UITapGestureRecognizer) {
        let location = sender.location(in: self)
        
        mostRecentNumpadButtonPressed = getButtonCellIndex(location: location)
        
        //print(mostRecentNumpadButtonPressed)
        //print(location)
        
        //update gamestateDeliveryBoy
        gsdb.setNumberToPass(value: mostRecentNumpadButtonPressed)
        gsdb.setKeypadNumberSelected(state: true)
        print("numpad ready: \(gsdb.selectedStates().0) sudoku ready: \(gsdb.selectedStates().1)")
        
        if gsdb.getReady() {
            gsdb.setValueAtHighlightedSudokuCell()
            self.reset()
        }
        
        self.setNeedsDisplay()
    }
    
    /*
     *  Reset the keypad so that no button is selected
     */
    public func reset() {
        mostRecentNumpadButtonPressed = -1
        gsdb.setKeypadNumberSelected(state: false)
        self.setNeedsDisplay()
    }
 

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
