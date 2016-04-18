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
    
    static func generateErrorWithCode(errorCode: Int) -> String {
        let errorMessage: String
        
        switch errorCode {
        case ERROR_CODE_DATA_INCONSISTENCY:
            errorMessage = NSLocalizedString(GlobalString.error_fetal, comment: "fetal error")
            break
        case ERROR_CODE_DATA_INSERT:
            errorMessage = NSLocalizedString(GlobalString.error_insert_data, comment: "insert data error")
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