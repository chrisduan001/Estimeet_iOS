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
    func makeOneOffLocationRequest(id: Int, tag: String) {
        startBackgroundService(id, tag: tag)
    }
    
    //called when app went to background or come to foreground
    func makeRequestWithTimer(isAppActive: Bool) {
        stopTimer()
        guard !shouldStopContinousTracking() else {
            return
        }
        
        if !isAppActive {
           startBackgroundService(nil, tag: "")
        } else {
            //make initial request, then start timer
            makeLocationRequest()
        }
        //timer will run for 3 minutes and then location will only updated on request
        initTimer()
    }
    
    private func startBackgroundService(id: Int?, tag: String) {
        PushNotification.sharedInstance.bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            self.setUpRequestType(id, tag: tag)
            self.stopTimer()
            self.makeLocationRequest()
        }
    }
    
    private func setUpRequestType(id: Int?, tag: String) {
        if id != nil {
            receiverId = id
            tagToNotify = tag
            requestType = .NotifyUpdate
        } else {
            receiverId = nil
            tagToNotify = ""
            requestType = .SendGeo
        }
    }
    
    //MARK: TIMER
    private func initTimer() {
        timer = NSTimer(timeInterval: 30.0, target: self, selector: #selector(OneOffLocationService.onTimerTicked), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    @objc private func onTimerTicked() {
        //todo..disabled for testing
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
        let isLocationExpired = abs(currentTime.timeIntervalSinceNow) > 5.0
        print("Is location expired: \(isLocationExpired)")
        if isLocationExpired {
            if self.locationManager == nil {
                self.locationManager = CLLocationManager()
                self.locationManager.delegate = self
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.locationManager.distanceFilter = 100.0
            }
            
            currentTime = NSDate()
            self.locationManager.startUpdatingLocation()
        }
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