//
//  MapMarks.swift
//  Estimeet
//
//  Created by Chris Duan on 10/09/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import MapKit

class MapMark: MKPointAnnotation {
    let image: NSData
    init(image: NSData) {
        self.image = image
        super.init()
    }
}