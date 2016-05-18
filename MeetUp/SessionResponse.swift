//
//  SessionResponse.swift
//  MeetUp
//
//  Created by Chris Duan on 18/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class SessionResponse: BaseResponse {
    var sessionId: Int!
    var sessionLId: String!
    var sessionLidNum: NSNumber!
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override init() {
        super.init()
    }
    
    init(sessionId: Int, sessionLId: String) {
        self.sessionId = sessionId
        self.sessionLId = sessionLId
        super.init()
    }
    
    override func mapping(map: Map) {
        sessionId           <- map["SessionId"]
        sessionLidNum       <- map["SessionLId"]
        
        sessionLId = "\(sessionLidNum)"
    }
}