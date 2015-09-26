//
//  GraphViewController.swift
//  Calculator
//
//  Created by Nadir Muzaffar on 9/24/15.
//  Copyright © 2015 Nadir Muzaffar. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource, UIPopoverPresentationControllerDelegate {
    private var brain = CalculatorBrain()
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.graphViewDataSource = self
        }
    }
    
    @IBAction func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(graphView)
            graphView.originTranslation = CGPoint(x: graphView.originTranslation.x + translation.x, y: graphView.originTranslation.y + translation.y)
            gesture.setTranslation(CGPointZero, inView: graphView)
        default: break
        }
    }
    
    @IBAction func panTo(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Changed: fallthrough
        case .Ended:
            if gesture.numberOfTapsRequired == 2 {
                let tapLocation = gesture.locationInView(graphView)
                graphView.originTranslation = CGPoint(x: tapLocation.x - graphView.bounds.width/2, y: tapLocation.y - graphView.bounds.height/2)
            }
        default: break
        }
    }
    
    @IBAction func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            graphView.scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    var program: AnyObject {
        get {
            return brain.program
        }
        
        set {
            brain.program = newValue
            title = brain.description
        }
    }
    
    func evaluateProgramAt(x: CGFloat) -> CGFloat? {
        let previousValueOfM = brain.variableValues["M"]
        brain.variableValues["M"] = Double(x)
            
        let result = brain.evaluate()
            
        brain.variableValues["M"] = previousValueOfM
            
        if let y = result {
            return CGFloat(y)
        }
        
        return nil
    }
    
    private struct Stats {
        static let SegueIdentifier = "Show Graph Stats"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Stats.SegueIdentifier:
                if let graphStatsViewController = segue.destinationViewController as? GraphStatsViewController {
                    if let popoverPresentationController = graphStatsViewController.popoverPresentationController {
                        popoverPresentationController.delegate = self
                    }
                    
                    graphStatsViewController.minYText = "\(graphView.minY)"
                    graphStatsViewController.maxYText = "\(graphView.maxY)"
                }
            default: break
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}
