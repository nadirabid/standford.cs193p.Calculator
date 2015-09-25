//
//  GraphViewController.swift
//  Calculator
//
//  Created by Nadir Muzaffar on 9/24/15.
//  Copyright © 2015 Nadir Muzaffar. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "scale:"))
        }
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            graphView.scale *= gesture.scale
            print(graphView.scale)
            gesture.scale = 1
        }
    }
}
