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
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.graphViewDataSource = self
            
            if let config = defaults.objectForKey("GraphView.Configuration") as? [String:CGFloat] {
                if let scale = config["scale"] {
                    graphView.scale = scale
                }
                
                if let originTranslationX = config["originTranslationX"] {
                    graphView.originTranslation.x = originTranslationX
                }
                
                if let originTranslationY = config["originTranslationY"] {
                    graphView.originTranslation.y = originTranslationY
                }
            }
            
        }
    }
    
    @IBAction func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            defaults.setObject(graphViewConfiguration, forKey: "GraphView.Configuration")
            defaults.synchronize()
            fallthrough
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
            defaults.setObject(graphViewConfiguration, forKey: "GraphView.Configuration")
            defaults.synchronize()
        default: break
        }
    }
    
    @IBAction func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            graphView.scale *= gesture.scale
            gesture.scale = 1
        }
        
        switch gesture.state {
        case .Changed:
            graphView.scale *= gesture.scale
            gesture.scale = 1
        case .Ended:
            defaults.setObject(graphViewConfiguration, forKey: "GraphView.Configuration")
            defaults.synchronize()
        default: break
        }
    }
    
    var graphViewConfiguration: AnyObject {
        get {
            
            var config = [String:CGFloat]()
            config["scale"] = graphView.scale
            config["originTranslationX"] = graphView.originTranslation.x
            config["originTranslationY"] = graphView.originTranslation.y
            return config
        }
        set {
            if let config = newValue as? [String:CGFloat] {
                if let scale = config["scale"] {
                    graphView.scale = scale
                }
                
                if let originTranslationX = config["originTranslationX"] {
                    graphView.originTranslation.x = originTranslationX
                }
                
                if let originTranslationY = config["originTranslationY"] {
                    graphView.originTranslation.y = originTranslationY
                }
            }
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
