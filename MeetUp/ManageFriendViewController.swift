//
//  ManageFriendViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 24/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class ManageFriendViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, FriendListListener {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.topItem?.title = "Main"
        
        friendListModel = ModelFactory.sharedInstance.provideFriendListModel(self)
    }
    
    override func viewWillAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CALLBACK
    func onGetFriendList(friends: [FriendEntity]?) {
        endActivityIndicator()
        
        guard friends != nil else {
            return
        }
        
        if friends!.count <= 0 {
            friendListModel.makeNetworkRequest()
            startActivityIndicator()
        } else {
            friendList = friends!
            self.tableView.reloadData()
        }
    }
    
    //MARK: TABLE VIEW
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "identifier"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        }

        return cell!
    }
    
    //MARK: VARIABLE
    var friendList = [FriendEntity]()
    var friendListModel: FriendListModel!
}
