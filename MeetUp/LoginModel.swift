//
//  LoginModel.swift
//  MeetUp
//
//  Created by Chris Duan on 25/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class LoginModel: BaseModel {
    let listener: ServiceListener
    
    init(serviceHelper: ServiceHelper, listener: ServiceListener) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper)
    }
    
    func requestSampleData() {
        serviceHelper.requestSampleData {
            response in
            if self.checkErrors((response.response?.statusCode)!, listener: self.listener) {
                let user = response.result.value
                print(user)
                
                guard let errorMessage = user?.getErrorMessage() where !errorMessage.isEmpty else {
                    self.listener.onGetSampleData(user!)
                    return
                }
                self.listener.onError(errorMessage)
            }
        }
    }
    
    func getData() -> String {
        return "AA"
    }
}

protocol ServiceListener: BaseListener {
    func onGetSampleData(user: User)
}