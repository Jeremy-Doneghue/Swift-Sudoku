//
//  sudokuBoard.swift
//  Sudoku
//
//  Created by Jeremy Doneghue on 21/11/16.
//  Copyright © 2016 Jeremy Doneghue. All rights reserved.
//

import UIKit

class sudokuBoard: UIView {
    
    // MARK: Properties
    
    var gsdb: GamestateDeliveryBoy = GamestateDeliveryBoy()!
    
    func setGameStateDeliveryBoy(boy: GamestateDeliveryBoy) {
        self.gsdb = boy
        self.gsdb.setSudokuBoardRef(sb: self)
    }
    
    var gameReady = false
    var isReady: Bool {
        get { return gameReady }
    }
    
    var buttonSelected = false
    var selected: Bool {
        get { return buttonSelected }
    }
    
    let fontSize: CGFloat = 26
    
    let sampleGame: String = "604000023|207308610|008906700|040502130|900000500|500074290|102009360|069000070|430617900"
    //let sampleGame: String = "604000|207308|008906|040502|900000|500074|102009|069000|430617" //six x six matrix
    
    var values = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
    var innerRectangles = [[CGRect?]](repeating: [CGRect?](repeating: nil, count: 9), count: 9)

    var buttonWidth: CGFloat = 0
    var buttonHeight: CGFloat = 0
    let outerLineWidth: CGFloat = 6
    let innerBoxLineWidth: CGFloat = 1
    
    let sudokuSize: CGFloat = 9
    
    var _WIDTH: CGFloat = 0
    var _HEIGHT: CGFloat = 0
    
    var mostRecentCellTap: (x: Int, y: Int) = (-1, -1)
    
    // MARK: Initialisation
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonWidth = self.bounds.width / sudokuSize
        buttonHeight = self.bounds.height / sudokuSize
        
        _WIDTH = self.bounds.width
        _HEIGHT = self.bounds.height
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(sudokuBoard.viewIsTapped(_:)))
        self.addGestureRecognizer(gesture)
        
        parseGame(game: sampleGame)
        gameReady = true
    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor.black.cgColor)
        
        //Highlight cell
        if mostRecentCellTap != (-1, -1) {
            ctx?.setFillColor(UIColor.gray.cgColor)
            ctx?.fill(innerRectangles[mostRecentCellTap.x][mostRecentCellTap.y]!)
        }
        
        //outer rectangle
        let outerRect = CGRect(x: 0, y: 0, width: _WIDTH, height: _HEIGHT)
        ctx?.setLineWidth(outerLineWidth)
        ctx?.stroke(outerRect)
        
        //inner rectangles
        ctx?.setLineWidth(innerBoxLineWidth)
        for column in 0..<innerRectangles.count {
            for row in 0..<innerRectangles.count {
                innerRectangles[column][row] = CGRect(x: CGFloat(column) * buttonWidth, y: CGFloat(row) * buttonHeight, width: buttonWidth, height: buttonHeight)
                ctx?.stroke(innerRectangles[column][row]!)
            }
        }
        
        //TicTacToe dividers
        for column in 1...3 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: buttonWidth * CGFloat(3 * column), y: 0))
            path.addLine(to: CGPoint(x: buttonWidth * CGFloat(3 * column), y: _HEIGHT))
            path.close()
            path.lineWidth = outerLineWidth / 2
            path.stroke()
        }
        for row in 1...3 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: buttonHeight * CGFloat(3 * row)))
            path.addLine(to: CGPoint(x: _WIDTH, y: buttonHeight * CGFloat(3 * row)))
            path.close()
            path.lineWidth = outerLineWidth / 2
            path.stroke()
        }
        
        // Render text
        var numStr: String = "0"
        for column in 0..<values.count {
            for row in 0..<values.count {
                
                if values[column][row] != 0{
                    numStr = String(values[column][row])
                    drawText(rect: innerRectangles[column][row]!, text: numStr, font: UIFont.systemFont(ofSize: fontSize))
                }
            }
        }
    }
    
    func drawText(rect: CGRect, text: String, font: UIFont) {
        
        //set text color to white
        let textColor: UIColor = UIColor.black
        
        // set the line spacing to 6
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.center
        
        // set the Obliqueness to 0
        let skew = 0
        
        let attributes: NSDictionary = [
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paraStyle,
            NSObliquenessAttributeName: skew,
            NSFontAttributeName: font
        ]
        
        text.draw(in: rect, withAttributes: (attributes as! [String : Any]))
    }
    
    // MARK: Numbers
    
    func seedNumbers() {
        
        for column in 0..<values.count {
            for row in 0..<values.count {
                values[column][row] = Int(arc4random_uniform(10))
            }
        }
        //print(values)
    }
    
    /*
     * Parse in values from a string in the format 82.4..12.| x 9 - where . = blank
     */
    func parseGame(game: String) {
        
        let lines: [String] = game.components(separatedBy: "|")
        print(lines)
        
        //check each line contains the correct number of characters
        var valid = true
        for line in lines {
            if line.characters.count != Int(sudokuSize) {
                valid = false
            }
        }
        
        if valid {
            print("valid")
            
            for i in 0..<Int(sudokuSize) {
                let rowChars = [Character](lines[i].characters)
                
                for j in 0..<Int(sudokuSize) {
                    
                    values[j][i] = Int("\(rowChars[j])")!
                }
            }
        }
    }
    
    // MARK: Interaction
    
    func viewIsTapped(_ sender:UITapGestureRecognizer) {
        let location = sender.location(in: self)
        //print("tap \(location)")
        
        var cellX: CGFloat = 0
        var cellY: CGFloat = 0
        var xCellIndex = 0
        var yCellIndex = 0
        
        while cellX < location.x {
            cellX += buttonWidth
            xCellIndex += 1
        }
        while cellY < location.y {
            cellY += buttonWidth
            yCellIndex += 1
        }
        
        mostRecentCellTap = (x: xCellIndex - 1, y: yCellIndex - 1)
        print("You tapped cell at: \(xCellIndex), \(yCellIndex)")
        
        // update GamestateDeliveryBoy
        gsdb.setSudokuBoxSelected(state: true)
        
        print("numpad ready: \(gsdb.selectedStates().0) sudoku ready: \(gsdb.selectedStates().1)")
        
        if (gsdb.getReady()) {
            setValueAtHighlightedCell(value: gsdb.getNumberToPass())
            gsdb.reset()
        }
        
        self.setNeedsDisplay()
    }
    
    public func setValueInCell(cell: (Int, Int), value: Int) {
        
        if gameReady && value <= Int(sudokuSize){
            values[cell.0][cell.1] = value
            self.reset()
            self.setNeedsDisplay()
        }
        else { print("setValueInCell: Game is not initialised yet (or you passed in a value larger than the sudoku game size (usually 9))") }
    }
    
    public func setValueAtHighlightedCell(value: Int) {
        
        if gameReady && value <= Int(sudokuSize) {
            values[mostRecentCellTap.0][mostRecentCellTap.1] = value
            self.reset()
            self.setNeedsDisplay()
        }
        else { print("setValueAtHighlightedCell: Game is not initialised yet (or you passed in a value larger than the sudoku game size (usually 9))") }
    }
    
    public func reset() {
        self.mostRecentCellTap = (-1, -1)
        gsdb.setSudokuBoxSelected(state: false)
    }
}
