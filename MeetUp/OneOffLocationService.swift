//
//  OneOffLocationService.swift
//  MeetUp
//
//  Created by Chris Duan on 6/06/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class OneOffLocationService: LocationServiceModel {
    
    func makeOneOffLocationRequest() {
        makeLocationRequest()
    }
    
    func makeRequestWithBackgroundTask() {
        PushNotification.sharedInstance.bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            self.makeLocationRequest()
        }
    }
    
    private func makeLocationRequest() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.distanceFilter = 100.0
        self.locationManager.startUpdatingLocation()
    }
    
    override func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        locationManager.stopUpdatingLocation()
        super.locationManager(manager, didUpdateToLocation: newLocation, fromLocation: oldLocation)
    }
    
    private func stopOneOffTracking() {
        if locationManager != nil {
            locationManager.stopUpdatingLocation()
            locationManager = nil
        }
    }
}