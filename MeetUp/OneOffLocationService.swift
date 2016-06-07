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
    private var timer: NSTimer!
    private var currentTime: NSDate = NSDate()
    
    //MARK: PUBLIC METHOD CALL
    //called when location was requested via push and there is active session
    func makeOneOffLocationRequest() {
        startBackgroundService()
    }
    
    //called when app went to background
    func makeRequestWithTimer() {
        guard !shouldStopContinousTracking() else {
            return
        }
        startBackgroundService()
        initTimer()
    }
    
    private func startBackgroundService() {
        PushNotification.sharedInstance.bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            self.stopTimer()
            self.makeLocationRequest()
        }
    }
    
    //MARK: TIMER
    private func initTimer() {
        timer = NSTimer(timeInterval: 30.0, target: self, selector: #selector(OneOffLocationService.onTimerTicked), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    @objc private func onTimerTicked() {
        shouldStopContinousTracking() ? stopTimer() : makeLocationRequest()
    }
    
    private func stopTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    //MARK: LOCATION LOGIC
    private func makeLocationRequest() {
        //location just got requested
        print("time since now: \(currentTime.timeIntervalSinceNow)")
        guard abs(currentTime.timeIntervalSinceNow) > 5.0 else {
            return
        }
        
        if self.locationManager == nil {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            self.locationManager.distanceFilter = 100.0
        }
        
        currentTime = NSDate()
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