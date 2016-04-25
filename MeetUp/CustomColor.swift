//
//  CustomColor.swift
//  MeetUp
//
//  Created by Chris Duan on 5/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

extension UIColor {
    public func primaryColor() -> UIColor {
        return UIColorFromHex("#77A500")
    }
    
    public func sectionHeaderColor() -> UIColor {
        return UIColorFromHex("#cccccc")
    }
    
    public func headerTextColor() -> UIColor {
        return UIColorFromHex("#4d4d4d")
    }
    
    private func UIColorFromHex(hex: String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}