//
//  ContactListModel.swift
//  MeetUp
//
//  Created by Chris Duan on 8/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ContactsUI

class ContactListModel {
    
    let store = CNContactStore()
    
    func getContactList() -> String {
        var contactList = ""
        
        switch CNContactStore.authorizationStatusForEntityType(.Contacts) {
        case .Authorized:
            contactList = self.getAllContacts()
            break
        case .NotDetermined:
            store.requestAccessForEntityType(.Contacts) { suceed, err in
                guard err == nil && suceed else {
                    return
                }
            }
            contactList = getAllContacts()
            break
        default:
            break
        }
        
        return contactList
    }
    
    private func getAllContacts() -> String {
        var contactList = ""
        let toFetch = [CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: toFetch)
        
        do{
            try store.enumerateContactsWithFetchRequest(request) {
                contact, stop in
                if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
                    for phoneNumber in contact.phoneNumbers {
                        let a = phoneNumber.value as! CNPhoneNumber
                        contactList += contactList.isEmpty ? a.stringValue : ",\(a.stringValue)"
                        a.stringValue
                    }
                }
            }
        } catch {
            FabricLogger.sharedInstance.logError("CatchedException: Error while get contacts", className: String(ContactListModel), code: 0, userInfo: nil)
        }
        
        return contactList
    }
}