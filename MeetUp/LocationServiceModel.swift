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
    enum NetworkRequestType {
        case SendGeo
        case NotifyUpdate
    }
    
    var locationManager: CLLocationManager!
    var requestType: NetworkRequestType?
    var tagToNotify: String?
    var receiverId: Int?
    weak var listener: LocationServiceListener?
    
    private var locationData: String!
    
    required init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: LocationServiceListener?) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }

    //MARK: CALLED BY SUBCLASS
    func checkLocationPermission() {
        if CLLocationManager.authorizationStatus() == .Denied {
            onPermissionDenied()
            return
        }
        
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            permissionGranted()
            return
        }
        
        if locationManager == nil {
            locationManager = CLLocationManager()
        }
        if locationManager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization)) {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func shouldStopContinousTracking() -> Bool {
        return AppDelegate.SESSION_TIME_TO_EXPIRE == nil ||
            (NSDate.timeIntervalSinceReferenceDate() * 1000) > AppDelegate.SESSION_TIME_TO_EXPIRE!.doubleValue
    }
    
    //MARK:PERMISSSION RESULT
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
        
        if requestType == nil {
            //default request type
            requestType = .SendGeo
        }
        //send geo data to server
        makeNetworkRequest()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error occurred while get location")
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        if requestType! == .NotifyUpdate && receiverId != nil{
            let notification = NotificationEntity(senderId: baseUser!.userId!, receiverId: receiverId!, receiverUId: tagToNotify!)
            serviceHelper.sendGeoDataWithNotify(notification, userUid: baseUser!.userUId!, geoData: locationData, travelMode: userDefaults.getTravelMode(), token: baseUser!.token!)
        } else {
            serviceHelper.sendGeoData(locationData, userUid: baseUser!.userUId!, travelMode: userDefaults.getTravelMode(), token: baseUser!.token!, notificationModel: NotificationEntity(senderId: baseUser!.userId!, receiverId: 0, receiverUId: "")) { _ in }
        }
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