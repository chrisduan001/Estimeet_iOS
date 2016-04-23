//
//  TokenResponse.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class TokenResponse: BaseResponse{
    var accessToken: String!
    var tokenType: String!
    var expiresIn: CLong!
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override init() {
        super.init()
    }
    
    init(accessToken: String, tokenType: String, expiresIn: CLong) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        super.init()
    }
    
    override func mapping(map: Map) {
        accessToken     <- map["access_token"]
        tokenType       <- map["token_type"]
        expiresIn       <- map["expires_in"]
        super.mapping(map)
    }
}