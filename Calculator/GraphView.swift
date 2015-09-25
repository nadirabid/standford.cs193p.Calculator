//
//  GraphView.swift
//  Calculator
//
//  Created by Nadir Muzaffar on 9/24/15.
//  Copyright © 2015 Nadir Muzaffar. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    var origin: CGPoint {
        return CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    override func drawRect(rect: CGRect) {
        let axesDrawer = AxesDrawer(contentScaleFactor: CGFloat(scale))
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
    }
    
}
