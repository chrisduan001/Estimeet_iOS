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
    
    private var locationData: String!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: LocationServiceListener?) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    //MARK: CONTROLLER CALL
    func startTracking(trackingLength: NSNumber) {
        guard trackingLength.intValue > 0 else {
            AppDelegate.SESSION_TIME_TO_EXPIRE = nil
            stopTimer()
            return
        }
        
        SessionFactory.sharedInstance.setSessionTrackingExpireTime(trackingLength)
        makeContinuousTracking()
        
        stopTimer()
        trackTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(LocationServiceModel.makeContinuousTracking), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        if trackTimer != nil {
            trackTimer.invalidate()
            trackTimer = nil
        }
    }
    
    //timer method
    func makeContinuousTracking() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if AppDelegate.SESSION_TIME_TO_EXPIRE == nil ||
                (NSDate.timeIntervalSinceReferenceDate() * 1000) > AppDelegate.SESSION_TIME_TO_EXPIRE!.doubleValue {
                self.stopTrackingTimer()
                
                print("Tracking timer stopped")
            } else {
                print("Get location")
                self.getCurrentLocation()
            }
        }
    }
    
    private func getCurrentLocation() {
        if locationManager == nil {
            locationManager = CLLocationManager()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10.0
        
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
        
        if listener != nil {
            listener?.onSessionCompleted()
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
        locationData = "\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude)"
        userDefaults.saveUserGeo(locationData)
        //send geo data to server
        makeNetworkRequest()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error occurred while get location")
    }
    
    private func startLocationUpdate() {
        locationManager.startUpdatingLocation()
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.sendGeoData(locationData, userUid: baseUser!.userUId!, travelMode: userDefaults.getTravelMode(), token: baseUser!.token!, notificationModel: NotificationEntity(senderId: baseUser!.userId!, receiverId: 0, receiverUId: "")) { _ in }
    }
    
    override func onAuthError() {
        self.stopTrackingTimer()
    }
    
    override func onError(message: String) {}
}

protocol LocationServiceListener: BaseListener {
    func onLocationAuthorized()
    func onSessionCompleted()
}