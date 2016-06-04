//
//  ErrorFactory.swift
//  MeetUp
//
//  Created by Chris Duan on 17/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class ErrorFactory {
    private static let ERROR_CODE_DATA_INCONSISTENCY = 100
    private static let ERROR_CODE_DATA_INSERT = 600
    
    static let ERROR_CODE_USER_GEO_UNAVAILABLE = 710
    static let ERROR_SESSION_EXPIRED = 701
    static let ERROR_CODE_SESSION_FRIEND_GEO_EXPIRED = 702
    
    static let GENERIC_ERROR_MESSAGE = 1000
    static let ERROR_NETWORK = 2013
    
    static func generateErrorWithCode(errorCode: Int) -> String {
        let errorMessage: String
        
        switch errorCode {
        case ERROR_CODE_DATA_INCONSISTENCY:
            errorMessage = NSLocalizedString(GlobalString.error_fetal, comment: "fetal error")
            break
        case ERROR_CODE_DATA_INSERT:
            errorMessage = NSLocalizedString(GlobalString.error_insert_data, comment: "insert data error")
            break
        case ERROR_CODE_USER_GEO_UNAVAILABLE:
            errorMessage = NSLocalizedString(GlobalString.user_geo_unavailable, comment: "unable to get location error")
            break
        case ERROR_SESSION_EXPIRED:
            errorMessage = NSLocalizedString(GlobalString.error_session_exp, comment: "session expired error")
            break
        case ERROR_CODE_SESSION_FRIEND_GEO_EXPIRED:
            errorMessage = NSLocalizedString(GlobalString.friend_location_expire, comment: "friend didn't update their location")
            break
        case GENERIC_ERROR_MESSAGE:
            errorMessage = generateGenericErrorMessage()
            break
        case ERROR_NETWORK:
            errorMessage = NSLocalizedString(GlobalString.error_network, comment: "network error")
            break
        default:
            errorMessage = generateGenericErrorMessage()
            break
        }
        return errorMessage
    }
    
    static func generateGenericErrorMessage() -> String {
        return NSLocalizedString(GlobalString.error_generic, comment: "generic error")
    }
}