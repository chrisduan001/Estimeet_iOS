//
//  LocationServiceModel.swift
//  MeetUp
//
//  Created by Chris Duan on 12/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationServiceModel: BaseModel, CLLocationManagerDelegate {
    weak var listener: LocationServiceListener?
    
    private var locationManager: CLLocationManager!
    
    private var trackTimer: NSTimer!
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: LocationServiceListener?) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    //MARK: CONTROLLER CALL
    func getCurrentLocation() {
        if locationManager == nil {
            locationManager = CLLocationManager()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        if CLLocationManager.authorizationStatus() == .Denied {
            onPermissionDenied()
            return
        }
        
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            permissionGranted()
            return
        }
        
        if locationManager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization)) {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func startTracking(expireTimeInMillis: NSNumber) {
        AppDelegate.SESSION_TIME_TO_EXPIRE = NSDate.timeIntervalSinceReferenceDate() + expireTimeInMillis.doubleValue
        
        if trackTimer != nil {
            trackTimer.invalidate()
        }
        trackTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(LocationServiceModel.makeContinuousTracking), userInfo: nil, repeats: true)
    }
    
    //timer method
    func makeContinuousTracking() {
        if AppDelegate.SESSION_TIME_TO_EXPIRE == nil ||
            NSDate.timeIntervalSinceReferenceDate() > AppDelegate.SESSION_TIME_TO_EXPIRE!.doubleValue {
            stopTrackingTimer()
            
            print("Tracking timer stopped")
        } else {
            print("Get location")
            getCurrentLocation()
        }
    }
    
    private func onPermissionDenied() {
        AppDelegate.SESSION_TIME_TO_EXPIRE = nil
        if listener != nil {
            listener!.onError(ErrorFactory.generateErrorWithCode(ErrorFactory.ERROR_LOCATION_SERVICE))
        }
    }
    
    private func permissionGranted() {
        if listener != nil {
            listener!.onLocationAuthorized()
        }
        
        startLocationUpdate()
    }
    
    private func stopTrackingTimer() {
        AppDelegate.SESSION_TIME_TO_EXPIRE = nil
        if trackTimer != nil {
            trackTimer.invalidate()
            trackTimer = nil
        }
    }
    
    //MARK: LOCATION MANAGER DELEGATE
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Restricted, .Denied:
            onPermissionDenied()
            break
        case .AuthorizedAlways:
            permissionGranted()
            break
        default: break
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        userDefaults.saveUserGeo("\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
    }
    
    private func startLocationUpdate() {
        locationManager.startUpdatingLocation()
    }
}

protocol LocationServiceListener: BaseListener {
    func onLocationAuthorized()
}