//
//  KDCircularProgress.swift
//  KDCircularProgress
//
//  Created by Kaan Dedeoglu on 1/14/15.
//  Copyright (c) 2015 Kaan Dedeoglu. All rights reserved.
//

import UIKit

let π: CGFloat = CGFloat(M_PI)
@IBDesignable class CircularProgress: UIView {
    @IBInspectable var progress: CGFloat = 0
    
    override func drawRect(rect: CGRect) {
        drawRingFittingInsideView()
    }
    
    private func drawRingFittingInsideView() {
        let halfSize:CGFloat = min(bounds.size.width/2, bounds.size.height/2)
        let center: CGPoint = CGPoint(x:halfSize,y:halfSize)

        let fullCircle = UIBezierPath(
            arcCenter: center,
            radius: CGFloat(halfSize/2),
            startAngle: CGFloat(0),
            endAngle: π * 2,
            clockwise: true)
        
        fullCircle.lineWidth = halfSize
        UIColor().primaryColor().setStroke()
        fullCircle.stroke()
        
        let startAngle = 3 * π / 2
        let endAngle = (3 * π / 2) + (progress * 2) * π
        
        let path = UIBezierPath(arcCenter: CGPoint(x:halfSize,y:halfSize),
                                radius: CGFloat(halfSize/2),
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        path.lineWidth = halfSize
        UIColor.whiteColor().setStroke()
        path.stroke()

    }
}