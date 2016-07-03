//
//  RoundedButton.swift
//  MeetUp
//
//  Created by Chris Duan on 5/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable
    var cornerRadius: CGFloat = 8 {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable
    var roundColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor = UIColor.darkGrayColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat = 2 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutRoundRectLayer()
    }
    
    private var roundRectLayer: CAShapeLayer?
    
    private func layoutRoundRectLayer() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).CGPath
        shapeLayer.fillColor = roundColor.CGColor
        //shadow
        shapeLayer.shadowColor = shadowColor.CGColor
        shapeLayer.shadowPath = shapeLayer.path
        shapeLayer.shadowOpacity = 0.0
        shapeLayer.shadowRadius = 2
        shapeLayer.shadowOffset = CGSizeMake(2.0, 2.0)
        self.layer.insertSublayer(shapeLayer, atIndex: 0)
        self.roundRectLayer = shapeLayer
    }
}