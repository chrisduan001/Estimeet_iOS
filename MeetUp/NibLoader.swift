//
//  NibLoader.swift
//  MeetUp
//
//  Created by Chris Duan on 24/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class NibLoader {
    static let sharedInstance = NibLoader()
    private init() {}
    
    func loadNibWithName(nibName: String, owner: AnyObject!, ofclass: AnyClass!) -> AnyObject! {
        let nibs = NSBundle.mainBundle().loadNibNamed(nibName, owner: owner, options: nil)
        
        for object in nibs! {
            if object.isKindOfClass(ofclass) {
                return object
            }
        }
        
        return nil;
    }
}
