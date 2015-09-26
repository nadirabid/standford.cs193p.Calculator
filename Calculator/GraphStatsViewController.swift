//
//  GraphStatsViewController.swift
//  Calculator
//
//  Created by Nadir Muzaffar on 9/26/15.
//  Copyright © 2015 Nadir Muzaffar. All rights reserved.
//

import UIKit

class GraphStatsViewController: UIViewController {

    @IBOutlet weak var minY: UITextView! {
        didSet {
            minY.text = "MinY: \(minYText)"
        }
    }
    
    @IBOutlet weak var maxY: UITextView! {
        didSet {
            maxY.text = "MaxY: \(maxYText)"
        }
    }
    
    var minYText: String = "" {
        didSet {
            minY?.text = "MinY: \(minYText)"
        }
    }
    
    var maxYText: String = "" {
        didSet {
            maxY?.text = "MaxY: \(maxYText)"
        }
    }
}
