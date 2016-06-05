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
    
    private var locationData: String!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: LocationServiceListener?) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    //MARK: CONTROLLER CALL
    func startTracking(trackingLength: NSNumber) {
        guard trackingLength.intValue > 0 else {
            AppDelegate.SESSION_TIME_TO_EXPIRE = nil
            return
        }
        
        SessionFactory.sharedInstance.setSessionTrackingExpireTime(trackingLength)
        checkPermissionAndMakeOneOffRequest()
        
        if !shouldStopContinousTracking() {
            makeContinousTracking()
        }
    }

    private func makeContinousTracking() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func shouldStopContinousTracking() -> Bool {
        return AppDelegate.SESSION_TIME_TO_EXPIRE == nil ||
            (NSDate.timeIntervalSinceReferenceDate() * 1000) > AppDelegate.SESSION_TIME_TO_EXPIRE!.doubleValue
    }
    
    private func checkPermissionAndMakeOneOffRequest() {
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
            listener!.onLocationDenied()
        }
    }
    
    private func permissionGranted() {
        if listener != nil {
            listener!.onLocationAuthorized()
        }
        
//        startLocationUpdate()
    }
    
    private func stopTrackingTimer() {
        AppDelegate.SESSION_TIME_TO_EXPIRE = nil
        
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
        
        if shouldStopContinousTracking() {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
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
    func onLocationDenied()
    func onSessionCompleted()
}