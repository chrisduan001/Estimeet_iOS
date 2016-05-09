//
//  TravelInfoFactory.swift
//  MeetUp
//
//  Created by Chris Duan on 9/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class TravelInfoFactory {
    static let sharedInstance = TravelInfoFactory()
    private init() {}
    
    func getEtaString(seconds: Int) -> String {
        let timeUnitMinutes = NSLocalizedString(GlobalString.time_unit_minutes, comment: "minutes")
        let timeUnitHours = NSLocalizedString(GlobalString.time_unit_hours, comment: "hours")
        let minutes = TimeConverter.sharedInstance.convertFromSecondsToMinutes(seconds)
        
        if minutes <= 60 {
            return ("\(minutes) \(timeUnitMinutes))")
        } else {
            let hours = minutes /  60
            let remainder = minutes % 60
            
            return ("\(hours) \(timeUnitHours) \(remainder) \(minutes)")
        }
    }
    
    func getDistanceString(distance: Double) -> String {
        let distanceUnit = NSLocalizedString(GlobalString.distance_unit_km, comment: "KM")
        //round to 2 decimal point
        return ("\(round((distance * 1000) * 100) / 100) \(distanceUnit)")
    }
    
    func isLocationDataExpired(dateUpdated: NSNumber) -> Bool {
        return CLongLong(NSDate.timeIntervalSinceReferenceDate() * 1000) - dateUpdated.longLongValue > ACTIVE_SESSION_EXPIRE_MILLIS
    }
    
    private let ACTIVE_SESSION_EXPIRE_MILLIS = 180000
}