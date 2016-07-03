//
//  MeetUpAttributedString.swift
//  MeetUp
//
//  Created by Chris Duan on 3/07/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class MeetUpAttributedString {
    static let sharedInstance = MeetUpAttributedString()
    private init() {}
    
    enum CustomFontTypeface {
        case regular, medium, semiBold
    }
    
    func getCustomFontAttributedString(text: String, size: CGFloat, typeface: CustomFontTypeface) -> NSAttributedString {
        let attributeText = NSMutableAttributedString(string: text)
        attributeText.addAttribute(NSFontAttributeName, value: getCustomFont(typeface, size: size), range: NSMakeRange(0, text.characters.count))
        
        return attributeText
    }
    
    func getCustomFont(typeface: CustomFontTypeface, size: CGFloat) -> UIFont {
        switch typeface {
        case .medium:
            return UIFont(name: "Omnes-Medium", size: size)!
        case .regular:
            return UIFont(name: "Omnes-Regular", size: size)!
        case .semiBold:
            return UIFont(name: "Omnes-Semibold", size: size)!
        }
    }
}