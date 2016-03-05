//
//  ServiceHelper.swift
//  MeetUp
//
//  Created by Chris Duan on 2/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class ServiceHelper {
    static let BASE_URL = "https://estimeetprojapi.azurewebsites.net/"
    
    static let sharedInstance = ServiceHelper()
    private init() {} //prevents other from using init() initlizer, will throw error if do so
    
    func requestSampleData(completionHandler: (response: Response<User, NSError>) -> Void) {
        let sampleDataUri = ServiceHelper.BASE_URL + "api/signin/getsimpledata"
        Alamofire.request(.GET, sampleDataUri).responseObject {
            (response: Response<User, NSError>) in
            completionHandler(response: response)
        }
    }
}