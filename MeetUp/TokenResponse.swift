//
//  TokenResponse.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class TokenResponse: Mappable{
    var accessToken: String!
    var tokenType: String!
    var expiresIn: CLong!
    
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        accessToken     <- map["access_token"]
        tokenType       <- map["token_type"]
        expiresIn       <- map["expires_in"]
    }
}