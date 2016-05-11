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
    
    static let ERROR_LOCATION_SERVICE = 800
    
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
        case ERROR_LOCATION_SERVICE:
            errorMessage = NSLocalizedString(GlobalString.user_location_failed, comment: "Location service error")
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