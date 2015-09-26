//
//  GraphView.swift
//  Calculator
//
//  Created by Nadir Muzaffar on 9/24/15.
//  Copyright © 2015 Nadir Muzaffar. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func evaluateProgramAt(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    var origin: CGPoint? = nil {
        didSet { setNeedsDisplay() }
    }
    
    private func resetOrigin() {
        origin = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    weak var graphViewDataSource: GraphViewDataSource?
    
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    override func drawRect(rect: CGRect) {
        if origin == nil {
            resetOrigin()
        }
        
        print("contentScaleFactor: \(contentScaleFactor)")
        
        let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
        axesDrawer.drawAxesInRect(bounds, origin: origin!, pointsPerUnit: scale)
        drawProgram()
    }
    
    private func drawProgram() {
        if let dataSource = graphViewDataSource {
            let graph = UIBezierPath()
        
            var movedToPoint = false
            
            for var i: CGFloat = 0; i <= bounds.width * contentScaleFactor; i++ {
                let origin = self.origin ?? CGPoint(x:0, y:0)
                
                let x = i/contentScaleFactor
                
                if let y = dataSource.evaluateProgramAt((x - origin.x)/scale) {
                    if !y.isNormal && !y.isZero {
                        continue
                    }
                    
                    if !movedToPoint {
                        graph.moveToPoint(CGPoint(x: x, y: origin.y - y*scale))
                        movedToPoint = true
                    }
                    else {
                        graph.addLineToPoint(CGPoint(x: x, y: origin.y - y*scale))
                    }
                }
            }
            
            UIColor.greenColor().setStroke()
            graph.stroke()
        }
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
}
