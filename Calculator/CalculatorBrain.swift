//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Nadir Muzaffar on 9/16/15.
//  Copyright © 2015 Nadir Muzaffar. All rights reserved.
//

import Foundation

class CalculatorBrain: CustomStringConvertible {
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case Constant(String, Double)
        case VariableOperand(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case Operand(let operand):
                    return "\(operand)"
                case Constant(let symbol, _):
                    return symbol
                case .VariableOperand(let variable):
                    return variable
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×") { $0 * $1 })
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+") { $0 + $1 })
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.Constant("π", M_PI))
    }
    
    var variableValues = [String:Double]()
    
    var program: AnyObject {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    }
                    else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(Op.Operand(operand))
                    }
                }
                
                opStack = newOpStack
            }
        }
    }
    
    var description: String {
        get {
            var result = toDescriptionString(opStack, isInitialCall: true)
            var descriptionString = ""
            
            if let desc = result.description {
                descriptionString = "\(desc)"
            }
            
            while !result.remainingOps.isEmpty {
                result = toDescriptionString(result.remainingOps, isInitialCall: true)
                
                if let desc = result.description {
                    descriptionString = desc + "," + descriptionString
                }
            }
            
            return descriptionString
        }
    }
    
    private func toDescriptionString(ops: [Op], isInitialCall: Bool = false) -> (description: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand == 0 ? "0" : "\(operand)", remainingOps)
            case .Constant(let symbol, _):
                return (symbol, remainingOps)
            case .VariableOperand(let symbol):
                return (symbol, remainingOps)
            case .UnaryOperation(let symbol, _):
                let result = toDescriptionString(remainingOps)
                
                if let description = result.description {
                    return ("\(symbol)(\(description))", result.remainingOps)
                }
                else {
                    return ("\(symbol)(?)", result.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let leftOperandResult = toDescriptionString(remainingOps)
                
                if  let leftDescription = leftOperandResult.description {
                    let rightOperandResult = toDescriptionString(leftOperandResult.remainingOps)
                    
                    var ret = ""
                    
                    if let rightDescription = rightOperandResult.description {
                        ret = "\(rightDescription) \(symbol) \(leftDescription)"
                    }
                    else {
                        ret = "? \(symbol) \(leftDescription)"
                    }
                    
                    if (!isInitialCall) {
                        ret = "(\(ret))"
                    }
                    
                    return (ret, rightOperandResult.remainingOps)
                }
                else {
                    let ret = isInitialCall ? "? \(symbol) ?" : "(? \(symbol) ?)"
                    return (ret, leftOperandResult.remainingOps)
                }
            }
        }
        
        return (nil, ops)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Constant(_, let value):
                return (value, remainingOps)
            case .VariableOperand(let variable):
                if let value = variableValues[variable] {
                    return (value, remainingOps)
                }
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let leftOperandEvaluation = evaluate(remainingOps)
                
                if let leftOperand = leftOperandEvaluation.result {
                    let rightOperandEvaluation = evaluate(leftOperandEvaluation.remainingOps)
                    
                    if let rightOperand = rightOperandEvaluation.result {
                        return (operation(leftOperand, rightOperand), rightOperandEvaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        
        return result
    }
    
    func pushOperand(symbol: String) -> Double? {
        if let op = knownOps[symbol] {
            opStack.append(op)
        }
        else {
            opStack.append(Op.VariableOperand(symbol))
        }
        
        return evaluate()
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
    
    func resetOperandsAndOperations() -> Double? {
        opStack.removeAll()
        return evaluate()
    }
    
    func resetVariableValues() -> Double? {
        variableValues.removeAll()
        return evaluate()
    }
    
}