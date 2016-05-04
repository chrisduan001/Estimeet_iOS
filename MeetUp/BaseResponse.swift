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
    var errorCode: Int?
    
    required init?(_ map: Map) {
        
    }
    
    init() {}
    
    func mapping(map: Map) {
        errorCode <- map["errorCode"]
    }

    func getErrorMessage() -> String {
        guard errorCode == 0 else {
            return ErrorFactory.generateErrorWithCode(errorCode!)
        }
        
        return ""
    }
}