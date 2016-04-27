//
//  ViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,
    NSFetchedResultsControllerDelegate{
    
    var isAnyFriends: Bool = false
    
    var user: User?
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerImg = UIImage(named: "navigation_icon")
        self.navigationItem.titleView = UIImageView(image: headerImg)
    }
    
    override func viewDidAppear(animated: Bool) {
        if user == nil {
            user = MeetUpUserDefaults.sharedInstance.getUserFromDefaults()
        }
        
        guard user != nil && !(user?.userName?.isEmpty)! else{
            if user == nil {
                Navigator.sharedInstance.navigateToLogin(self)
            } else {
                Navigator.sharedInstance.navigateToProfilePage(self)
            }
            return
        }
        
        if isAnyFriends {
            Navigator.sharedInstance.navigateToFriendList(self)
        }
    }
    
    //MARK: BUTTON CLICK EVENT
    @IBAction func onManageFriend(sender: UIBarButtonItem) {
        Navigator.sharedInstance.navigateToFriendList(self)
    }
    
    @IBAction func onManageProfile(sender: UIBarButtonItem) {
        Navigator.sharedInstance.navigateToManageProfile(self, user: user!)
    }
    
    //MARK: TABLEVIEW
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let identifier = "identifier"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ManageFriendTableViewCell
        
        return cell!
    }
    
}











