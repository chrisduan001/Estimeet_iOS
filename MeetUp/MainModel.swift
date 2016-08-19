//
//  MainModel.swift
//  MeetUp
//
//  Created by Chris Duan on 28/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class MainModel: BaseModel {
    unowned let listener: MainModelListener
    private let dataHelper: DataHelper
    
    private var friendObj: Friend!
    private var pendingLocationRequest: [Friend]?
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, listener: MainModelListener) {
        self.listener = listener
        self.dataHelper = dataHelper
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func setUpMainTableView() {
        listener.setSessionFetchedResultsController(dataHelper.getSessionFetchedResults())
    }
    
    func sendSessionDataRequest(friendObj: Friend) {
        self.friendObj = friendObj
        makeNetworkRequest()
    }
    
    func requestPendingFriendSessionData() {
        //friend id will be set in user default when received friend location became availble push notification
        if let ids = userDefaults.getFriendLocationAvailableId() {
            let trimmedId = ids.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            guard !trimmedId.isEmpty else {
                return
            }
            let idArray: [Int] = trimmedId.componentsSeparatedByString(" ").map { Int($0)! }
            let idSet = Set(idArray)
            let friends = idSet.map { dataHelper.getFriend($0)}.filter { $0 != nil }.map { $0! }
            
            //request location data should be done one at the time
            //request multiple user's location data at the same time is not supported
            pendingLocationRequest = friends
            sendRequestAndRemoveFriend()
            
            //reset user default
            userDefaults.setFriendLocationAvailableId(nil)
        }
    }
    
    func setTravelMode(travelMode: Int) {
        userDefaults.saveTravelMode(travelMode)
    }
    
    func getTravelMode() {
        listener.onGetTravelMode(userDefaults.getTravelMode())
    }
    
    private func onRequestLocationDataCompleted() {
        sendRequestAndRemoveFriend()
    }
    
    private func sendRequestAndRemoveFriend() {
        if var requestList = pendingLocationRequest {
            guard requestList.count > 0 else {
                pendingLocationRequest = nil
                return
            }
            sendSessionDataRequest(requestList[0])
            
            requestList.removeFirst()
            if requestList.count <= 0 {
                pendingLocationRequest = nil
            }
        }
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        let geoCoordinate = userDefaults.getUserGeo()
        guard geoCoordinate != nil else {
            generateErrorMessage(ErrorFactory.ERROR_CODE_USER_GEO_UNAVAILABLE)
            return
        }
        //-1 get default mode
        let entity = RequestLocationEntity(userId: baseUser!.userId!,
                                          userUid: baseUser!.userUId!,
                                         friendId: friendObj.userId!.integerValue,
                                        friendUid: friendObj.userUId!,
                                        sessionId: friendObj.session!.sessionId!.integerValue,
                                       sessionLid: friendObj!.session!.sessionLId!,
                                       travelMode: -1,
                                          userGeo: geoCoordinate!)
        
        serviceHelper.getTravelInfo(entity, token: baseUser!.token!) {
            response in
            print("get travel info response \(response.response)")
            let listItem = response.result.value
            
            if listItem != nil && listItem?.errorCode == ErrorFactory.ERROR_SESSION_EXPIRED {
                SessionFactory.sharedInstance.deleteFriendSession(self.dataHelper, friend: self.friendObj)
                SessionFactory.sharedInstance.checkSession(self.dataHelper)
            }
            guard !self.isAnyErrors(response) else {
                self.onRequestLocationDataCompleted()
                return
            }
            
            if listItem!.items.count <= 0 {
                //latest location updates not found, push notification has been sent to friend and requested to upload the geo location
                //this method records the time that the request was sent
                //if not get location updates, will need to show user that their friend's either doesn't have connection or location updates was turned off
                SessionFactory.sharedInstance.setTimeOnWaitingLocationUpdate(self.dataHelper, session: self.friendObj!.session)
            } else {
                let locationModel = listItem!.items[0]
                self.dataHelper.storeSessionData(locationModel.distance,
                                                 eta: locationModel.eta,
                                                 travelMode: locationModel.travelMode,
                                                 location: locationModel.location,
                                                 geoCoordinate: locationModel.geoCoordinate,
                                                 session: self.friendObj!.session)
            }
            self.onRequestLocationDataCompleted()
        }
    }
    
    override func onAuthError() {
        super.onAuthError()
        listener.onAuthFail()
    }
    
    override func onError(message: String) {
        listener.onError(message)
    }
}

protocol MainModelListener: BaseListener {
    func setSessionFetchedResultsController(fetchedResultsController: NSFetchedResultsController)
    func onGetTravelMode(travelMode: Int)
}