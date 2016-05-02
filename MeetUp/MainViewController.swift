//
//  ViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,
    NSFetchedResultsControllerDelegate, MainModelListener, SessionListener{
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerImg = UIImage(named: "navigation_icon")
        self.navigationItem.titleView = UIImageView(image: headerImg)
        
        ModelFactory.sharedInstance.provideMainModel(self).setUpMainTableView()
        
        friendListModel = ModelFactory.sharedInstance.provideFriendListModel(nil)
        sessionModel = ModelFactory.sharedInstance.provideSessionModel(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        sessionModel.checkSessionExpiration()
    }

    override func viewDidAppear(animated: Bool) {
        //this method will only run once on start up check if user has already logged in
        initialSetUp()
    }
    
    //MARK: MODEL CALLBACK
    func setSessionFetchedResultsController(fetchedResultsController: NSFetchedResultsController) {
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("An exception occurred while fetch request")
        }
    }
    
    func onCheckSessionExpiration(result: Bool?) {
        
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
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewHeader.sharedInstance
            .getTableHeaderView(tableView,
                                withTitle: NSLocalizedString(GlobalString.table_recommend_friend,
                                    comment: "Recommend friend"),
                                withHeight: ManageFriendTableViewCell.HEADER_HEIGHT,
                                textColor: UIColor().headerTextColor(),
                                backgroundColor: UIColor().sectionHeaderColor())
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ManageFriendTableViewCell.HEADER_HEIGHT
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
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
        
        if cell != nil {
            setUpCell(cell!, indexPath: indexPath)
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ManageFriendTableViewCell.CELL_HEIGHT
    }
    
    private func setUpCell(cell: ManageFriendTableViewCell, indexPath: NSIndexPath) {
        let friendObj = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        cell.indexPath = indexPath
        cell.friendName.text = friendObj.userName
        
        if friendObj.image != nil {
            cell.friendDp.image = UIImage(data: friendObj.image!)
        } else {
            ImageFactory.sharedInstance.loadImageFromUrl(cell.friendDp,
                                                         fromUrl: NSURL(string:friendObj.imageUri!)!,
                                                         placeHolder: nil,
                                                         completionHandler: { (image, error, cacheType, imageURL) in
                                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                                                                guard image != nil else {
                                                                    return
                                                                }
                                                                self.friendListModel.saveFriendImage(friendObj, imgData: UIImagePNGRepresentation(image!)!)
                                                            }
            })
        }
    }
    
    //MARK: TABLEVIEW SWIPE ACTION
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let sendRequest = UITableViewRowAction(style: .Normal, title: "Send Estimeet") { (action, index) in
            self.sessionModel.sendSessionRequest(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Friend)
        }
        
        sendRequest.backgroundColor = UIColor().primaryColor()
        
        return [sendRequest]
    }
    
    //MARK: NSFETCHED RESULT DELEGATE
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break
        case .Update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as? ManageFriendTableViewCell
                if cell != nil {
                    setUpCell(cell!, indexPath: indexPath)
                } else {
                    print("null value found at \(indexPath.row)")
                }
            }
            break
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch type {
        case .Insert:
            tableView.insertSections(indexSet, withRowAnimation: .None)
            break
        case .Delete:
            tableView.deleteSections(indexSet, withRowAnimation: .None)
            break
        default:
            break
        }
    }
    
    //MARK: INIT SET UP
    private func initialSetUp() {
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
    
    var isAnyFriends: Bool = false
    var user: User?
    
    var friendListModel: FriendListModel!
    var sessionModel: SessionModel!
    
    private var fetchedResultsController: NSFetchedResultsController!
}











