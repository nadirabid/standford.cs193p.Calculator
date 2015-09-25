//
//  ViewController.swift
//  Calculator
//
//  Created by Nadir Muzaffar on 9/15/15.
//  Copyright (c) 2015 Nadir Muzaffar. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var historyDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            display.text = display.text! + sender.currentTitle!
        }
        else {
            display.text = sender.currentTitle!
            userIsInTheMiddleOfTyping = true
        }
        
        historyValue = brain.description
    }
    
    @IBAction func backspaceOrUndo() {
        if (userIsInTheMiddleOfTyping) {
            if let displayText = display.text where displayText.characters.count > 1 {
                display.text = displayText.substringToIndex(displayText.endIndex.predecessor())
                userIsInTheMiddleOfTyping = true
            }
            else {
                display.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
        else {
            displayValue = brain.undoLastOp()
        }
        
        historyValue = brain.description
    }

    @IBAction func enterPi() {
        displayValue = brain.pushOperand("π")
    }
    
    @IBAction func enterM() {
        displayValue = brain.pushOperand("M")
    }
    
    @IBAction func setMToDisplayValue() {
        if let value = displayValue {
            brain.variableValues["M"] = value
            displayValue = brain.evaluate()
        }
        
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func addDecimalPoint() {
        if display.text?.rangeOfString(".") == nil {
            display.text = display.text! + "."
        }
        
        userIsInTheMiddleOfTyping = true
    }

    @IBAction func clear() {
        if (userIsInTheMiddleOfTyping) {
            enter()
        }
        
        brain.resetOperandsAndOperations()
        displayValue = brain.resetVariableValues()
        historyValue = brain.description
    }
    
    @IBAction func operate(sender: UIButton) {
        if (userIsInTheMiddleOfTyping) {
            enter()
        }
        
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTyping = false
        
        if let displayVal = displayValue {
            displayValue = brain.pushOperand(displayVal)
        }
    }
    
    var historyValue: String? {
        get {
            return historyDisplay.text
        }
        set {
            if let val = newValue where val != "" {
                historyDisplay.text = val
            }
            else {
                historyDisplay.text = " "
            }
        }
    }
    
    var displayValue: Double? {
        get {
            if let val = NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return val
            }
            
            return nil
        }
        set {
            if let val = newValue where val != 0 {
                display.text = "\(val)"
            }
            else if let val = newValue where val == 0 {
                display.text = "0"
            }
            else {
                display.text = " "
            }
            
            userIsInTheMiddleOfTyping = false
            historyValue = "= \(brain.description)"
        }
    }
}