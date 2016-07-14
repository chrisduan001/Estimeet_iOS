//
//  SearchView.swift
//  MeetUp
//
//  Created by Chris Duan on 12/07/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class SearchView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private var searchResult: [UserFromSearch]!
    private var requestedId: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setTableData(result: [UserFromSearch]) {
        searchResult = result
        tableView.reloadData()
        
        hideActivityIndicator()
    }
    
    //will check local db to see if request is successful
    func requestFinished(isSuccessful successful: Bool) {
        hideActivityIndicator()
        
        if !successful {
            if let user = (searchResult.filter { user in user.userId == requestedId }).first {
                user.isFriend = false
            }
            
            tableView.reloadData()
        }
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = searchResult where list.count > 0{
            return list.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "identifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ManageFriendTableViewCell
        
        if cell == nil {
            let object = NibLoader.sharedInstance.loadNibWithName("ManageFriendCell", owner: nil, ofclass: ManageFriendTableViewCell.self)
            cell = object as? ManageFriendTableViewCell
        }
        
        if let viewCell = cell {
            setUpCell(viewCell, indexPath: indexPath)
        }
        
        return cell!
    }
    
    private func setUpCell(cell: ManageFriendTableViewCell, indexPath: NSIndexPath) {
        
    }
}

protocol SearchViewDelegate: class {
    func addFriend(user: User)
}
