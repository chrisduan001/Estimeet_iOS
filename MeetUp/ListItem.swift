//
//  ListItem.swift
//  MeetUp
//
//  Created by Chris Duan on 23/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class ListItem<T: Mappable>: BaseResponse {
    var items: [T]!
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        items     <- map["GenericItems"]
        super.mapping(map)
    }
}