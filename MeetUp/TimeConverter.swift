//
//  TimeConverter.swift
//  MeetUp
//
//  Created by Chris Duan on 1/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

enum TimeType {
    case MINUTES
    case SECONDS
    case HOURS
}
class TimeConverter {
    static let sharedInstance = TimeConverter()
    private init() {}
    
    func convertToMilliseconds(type: TimeType, value: Double) -> NSNumber {
        switch type {
        case .MINUTES:
            return value * 60000
        case .HOURS:
            return value * 3600000
        case .SECONDS:
            return value * 1000
        }
    }
    
    func convertFromSecondsToMinutes(value: Int) -> Int {
        return value / 60
    }
}