//
//  BaseResponse.swift
//  MeetUp
//
//  Created by Chris Duan on 3/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseResponse: Mappable {
    private var errorCode: Int?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        errorCode <- map["errorCode"]
    }
    
    func getErrorMessage() -> String {
        guard errorCode == 0 else {
            //TODO: put proper error message here
            return "An error has occurred"
        }
        
        return ""
    }
}