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
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, listener: MainModelListener) {
        self.listener = listener
        self.dataHelper = dataHelper
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func setUpMainTableView() {
        listener.setSessionFetchedResultsController(dataHelper.getSessionFetchedResults())
    }
    
    
}

protocol MainModelListener: BaseListener {
    func setSessionFetchedResultsController(fetchedResultsController: NSFetchedResultsController)
}