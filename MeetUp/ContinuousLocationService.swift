//
//  ContinuousLocationService.swift
//  MeetUp
//
//  Created by Chris Duan on 6/06/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import CoreLocation

class ContinuousLocationService: LocationServiceModel {
    
    func startContinuousTracking(trackingLength: NSNumber) {
        guard trackingLength.intValue > 0 else {
            AppDelegate.SESSION_TIME_TO_EXPIRE = nil
            stopContinuousTracking()
            return
        }
        
        SessionFactory.sharedInstance.setSessionTrackingExpireTime(trackingLength)
        
        if locationManager == nil {
            locationManager = CLLocationManager()
        }
        
        checkLocationPermission()
        
        if !shouldStopContinousTracking() {
            makeContinousTracking()
        } else {
            stopContinuousTracking()
        }
    }
    
    private func stopContinuousTracking() {
        if locationManager != nil {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.delegate = nil
            locationManager = nil
        }
    }
    
    private func makeContinousTracking() {
        if locationManager == nil {
            locationManager = CLLocationManager()
        }
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    override func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if shouldStopContinousTracking() {
            stopContinuousTracking()
        }
        
        super.locationManager(manager, didUpdateToLocation: newLocation, fromLocation: oldLocation)
    }
}