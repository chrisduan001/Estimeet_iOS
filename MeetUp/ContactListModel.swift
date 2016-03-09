//
//  ContactListModel.swift
//  MeetUp
//
//  Created by Chris Duan on 8/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import AddressBook

class ContactListModel {
    
    func getContactList() {
        
        let addressBook = ABAddressBookCreateWithOptions(nil,nil)?.takeRetainedValue()
        
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            granted, error in
            guard let people = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue() as? NSArray else {
                return
            }
            
            
        }
        
    }
}