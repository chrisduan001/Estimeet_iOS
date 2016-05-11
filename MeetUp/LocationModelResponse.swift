//
//  LocationModelResponse.swift
//  MeetUp
//
//  Created by Chris Duan on 10/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class LocationModelResponse: BaseResponse {
    var distance: Int!
    var eta: Int!
    var travelMode: Int!
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override init() {
        super.init()
    }
    
    init(distance: Int, eta: Int, travelMode: Int) {
        self.distance = distance
        self.eta = eta
        self.travelMode = travelMode
        
        super.init()
    }
    
    override func mapping(map: Map) {
        distance        <- map["distance"]
        eta             <- map["eta"]
        travelMode      <- map["travelMode"]
    }
}