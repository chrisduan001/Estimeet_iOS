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
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        let entity = RequestLocationEntity(userId: baseUser!.userId!,
                                         friendId: friendObj.userId!.integerValue,
                                        friendUid: friendObj.userUId!,
                                        sessionId: friendObj.session!.sessionId!.integerValue,
                                       sessionLid: friendObj!.session!.sessionLId!,
                                       travelMode: -1,
                                          userGeo: "")
        
        serviceHelper.getTravelInfo(entity, token: baseUser!.token!) {
            response in
            print("get travel info response \(response.response)")
            let listItem = response.result.value
            guard !self.isAnyErrors(response.response!.statusCode, response: listItem) else {
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
}