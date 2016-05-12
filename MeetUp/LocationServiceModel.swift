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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Restricted, .Denied:
            onPermissionDenied()
            break
        case .AuthorizedAlways:
            locationManager.startUpdatingLocation()
            permissionGranted()
            break
        default: break
        }
    }
    
    func startTracking() {
        trackTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(LocationServiceModel.timerMethod), userInfo: nil, repeats: true)
    }
    
    func timerMethod() {
    }
    
    func onPermissionDenied() {
        if listener != nil {
            listener!.onError(ErrorFactory.generateErrorWithCode(ErrorFactory.ERROR_LOCATION_SERVICE))
        }
    }
    
    func permissionGranted() {
        if listener != nil {
            listener!.onLocationAuthorized()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        userDefaults.saveUserGeo("\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
    }
}

protocol LocationServiceListener: BaseListener {
    func onLocationAuthorized()
}