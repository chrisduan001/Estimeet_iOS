//
//  ViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,
    NSFetchedResultsControllerDelegate, MainModelListener, SessionListener, GetNotificationListener,
    FriendSessionCellDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(onReceiveNotification), name: PushNotification.GENERAL_NOTIFICATION_KEY, object: nil)
        
        let headerImg = UIImage(named: "navigation_icon")
        self.navigationItem.titleView = UIImageView(image: headerImg)
        
        mainModel = ModelFactory.sharedInstance.provideMainModel(self)
        mainModel.setUpMainTableView()
        friendListModel = ModelFactory.sharedInstance.provideFriendListModel(nil)
        sessionModel = ModelFactory.sharedInstance.provideSessionModel(self)
        getNotificationModel = ModelFactory.sharedInstance.provideGetNotificationModel(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        sessionModel.checkSessionExpiration()
        getNotificationModel.getAllNotifications()
    }

    override func viewDidAppear(animated: Bool) {
        //this method will only run once on start up check if user has already logged in
        initialSetUp()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func onReceiveNotification(notification: NSNotification) {
        if notification.name == PushNotification.GENERAL_NOTIFICATION_KEY {
            getNotificationModel.getAllNotifications()
        }
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
    
    func onCreateNewSession(expireTimeInMilli: NSNumber) {
        
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
                                withTitle: getSectionHeaderName(section),
                                withHeight: ManageFriendTableViewCell.HEADER_HEIGHT,
                                textColor: UIColor().headerTextColor(),
                                backgroundColor: UIColor().sectionHeaderColor())
    }
    
    private func getSectionHeaderName(section: Int) -> String {
        //both friends and active session
        if fetchedResultsController.sections?.count > 1 {
            return NSLocalizedString(section == 0 ? GlobalString.cell_header_active : GlobalString.cell_header_friend,
                                     comment: "Friends / Active")
        } else { //else needs find out if the section is friend or active session
            if let friend = fetchedResultsController.fetchedObjects?.first as? Friend {
                return NSLocalizedString(friend.session == nil ? GlobalString.cell_header_friend : GlobalString.cell_header_active,
                                         comment: "Friends / Active")
            }
            
            return ""
        }
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
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? FriendSessionTableViewCell
        
        if cell == nil {
            let object = NibLoader.sharedInstance.loadNibWithName("FriendSessionCell", owner: nil, ofclass: FriendSessionTableViewCell.self)
            cell = object as? FriendSessionTableViewCell
        }
        
        if cell != nil {
            cell?.setDelegate(self)
            setUpCell(cell!, indexPath: indexPath)
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ManageFriendTableViewCell.CELL_HEIGHT
    }
    
    private func setUpCell(cell: FriendSessionTableViewCell, indexPath: NSIndexPath) {
        let friendObj = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        
        cell.indexPath = indexPath
        if let session = friendObj.session {
            cell.img_action.hidden = false
            switch session.sessionType! {
            case SessionFactory.sharedInstance.SENT_SESSION:
                setUpSentSessionView(cell, friend: friendObj)
                break
            case SessionFactory.sharedInstance.RECEIVED_SESSION:
                setUpReceivedSessionView(cell, friend: friendObj)
                break
            case SessionFactory.sharedInstance.ACTIVE_SESSION:
                setUpActiveSessionView(cell, friend: friendObj)
                break
            default: break
            }
        } else {
            cell.addView(cell.view_default)
            cell.friend_name.text = friendObj.userName
            cell.img_action.hidden = true
        }
        
        if friendObj.image != nil {
            cell.img_dp.image = UIImage(data: friendObj.image!)
        } else {
            ImageFactory.sharedInstance.loadImageFromUrl(cell.img_dp,
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
    
    private func setUpSentSessionView(cell: FriendSessionTableViewCell, friend: Friend) {
        cell.addView(cell.view_request_sent)
        cell.request_sent_name.text = friend.userName
        cell.request_sent_label.text = NSLocalizedString(GlobalString.sent_request_label, comment: "sent request label")
    }
    
    private func setUpReceivedSessionView(cell: FriendSessionTableViewCell, friend: Friend) {
        cell.addView(cell.view_session_request)
        cell.request_name.text = friend.userName
        cell.btn_accept.setTitle(NSLocalizedString(GlobalString.button_accept, comment: "accept button"), forState: .Normal)
        cell.btn_ignore.setTitle(NSLocalizedString(GlobalString.button_ignore, comment: "ignore button"), forState: .Normal)
    }
    
    private func setUpActiveSessionView(cell: FriendSessionTableViewCell, friend: Friend) {
        cell.addView(cell.view_distance_eta)
        if let sessionData = friend.session?.sessionData {
            let expireString = TravelInfoFactory.sharedInstance.isLocationDataExpired(friend.session!.dateUpdated!) ?NSLocalizedString(GlobalString.expired_string, comment: "expired") : ""
            
            cell.session_distance.text = "\(NSLocalizedString(GlobalString.travel_info_distance, comment: "distance")) \(TravelInfoFactory.sharedInstance.getDistanceString(sessionData.distance!.doubleValue))" + expireString
            
            cell.session_eta.text = "\(NSLocalizedString(GlobalString.travel_info_eta, comment: "eta")) \(TravelInfoFactory.sharedInstance.getEtaString(sessionData.eta!.integerValue))" + expireString
            cell.session_location.text = "Unknown"
        }
    }
    
    //MARK: TABLEVIEW ACTION
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
    
    func onCancelSession(indexPath: NSIndexPath) {
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
//            if let indexPath = indexPath {
//                let cell = tableView.cellForRowAtIndexPath(indexPath) as? ManageFriendTableViewCell
//                if cell != nil {
//                    setUpCell(cell!, indexPath: indexPath)
//                } else {
//                    print("null value found at \(indexPath.row)")
//                }
//            }
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
        
        //register push notification
        //todo..need refactor, maybe dynamically set rootview controller eg: at appdelegate if user==nil, set login vc as root
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.registerForPushNotifications(UIApplication.sharedApplication())
    }
    
    var isAnyFriends: Bool = false
    var user: User?
    
    var friendListModel: FriendListModel!
    var sessionModel: SessionModel!
    var getNotificationModel: GetNotificationModel!
    var mainModel: MainModel!
    
    private var fetchedResultsController: NSFetchedResultsController!
}











