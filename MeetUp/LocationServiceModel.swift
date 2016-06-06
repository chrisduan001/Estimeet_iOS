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
    
    var locationManager: CLLocationManager!

    private var locationData: String!
    
    required init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: LocationServiceListener?) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }

    //used by sub class
    func checkLocationPermission() {
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
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error occurred while get location")
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.sendGeoData(locationData, userUid: baseUser!.userUId!, travelMode: userDefaults.getTravelMode(), token: baseUser!.token!, notificationModel: NotificationEntity(senderId: baseUser!.userId!, receiverId: 0, receiverUId: "")) { _ in }
    }
    
    override func onAuthError() {
        self.stopTracking()
    }
    
    //called when auth error
    private func stopTracking() {
        AppDelegate.SESSION_TIME_TO_EXPIRE = nil
        if listener != nil {
            listener?.onSessionCompleted()
        }
    }
    
    override func onError(message: String) {}
}

protocol LocationServiceListener: BaseListener {
    func onLocationAuthorized()
    func onLocationDenied()
    func onSessionCompleted()
}