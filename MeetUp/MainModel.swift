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
            let friends = idSet.map { dataHelper.getFriend($0)}.filter { $0 != nil }
            
            for friend in friends {
                sendSessionDataRequest(friend!)
            }
            
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
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        let geoCoordinate = userDefaults.getUserGeo()
        guard geoCoordinate != nil else {
            generateErrorMessage(ErrorFactory.ERROR_CODE_USER_GEO_UNAVAILABLE)
            return
        }
        //-1 get default mode
        let entity = RequestLocationEntity(userId: baseUser!.userId!,
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
                return
            }
            
            let locationModel = listItem!.items[0]
            self.dataHelper.storeSessionData(locationModel.distance,
                                             eta: locationModel.eta,
                                             travelMode: locationModel.travelMode,
                                             session: self.friendObj!.session!)
        }
    }
    
    override func onAuthError() {
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