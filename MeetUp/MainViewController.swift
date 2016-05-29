//
//  ViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,
    NSFetchedResultsControllerDelegate, MainModelListener, SessionListener, GetNotificationListener,
    FriendSessionCellDelegate, LocationServiceListener{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    //MARK: LIFECYCLE    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //push notification received observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(onReceiveNotification), name: PushNotification.GENERAL_NOTIFICATION_KEY, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onReceiveNoSessionNotification), name: PushNotification.NO_SESSION_KEY, object: nil)
        
        //app delegate observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(onReceiveLifecycleNotification), name: AppDelegate.LIFE_CYCLE_NOTIFICATION, object: nil)
        
        let headerImg = UIImage(named: "navigation_icon")
        self.navigationItem.titleView = UIImageView(image: headerImg)
        
        setDefaultToolbarItem()
        
        //models
        mainModel = ModelFactory.sharedInstance.provideMainModel(self)
        mainModel.setUpMainTableView()
        friendListModel = ModelFactory.sharedInstance.provideFriendListModel(nil)
        sessionModel = ModelFactory.sharedInstance.provideSessionModel(self)
        getNotificationModel = ModelFactory.sharedInstance.provideGetNotificationModel(self)
        locationServiceModel = ModelFactory.sharedInstance.provideLocationServicemodel(self)
    }

    override func viewWillAppear(animated: Bool) {
        onResume()
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
    
    @objc private func onReceiveNoSessionNotification() {
        setDefaultToolbarItem()
    }
    
    @objc private func onReceiveLifecycleNotification(notification: NSNotification) {
        if notification.name == AppDelegate.LIFE_CYCLE_NOTIFICATION {
            onResume()
        }
    }
    
    private func onResume() {
        print("on resume called")
        sessionModel.checkSessionExpiration()
        getNotificationModel.getAllNotifications()
    }
    
    //MARK: TOOLBAR
    private func setDefaultToolbarItem() {
        let barButtonItem1 = UIBarButtonItem(image: UIImage(named: "navigation_icon"), style: .Plain, target: self, action: #selector(MainViewController.onManageFriend(_:)))
        barButtonItem1.tintColor = UIColor().primaryColor()
        let flexiSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let barButtonItem2 = UIBarButtonItem(image: UIImage(named: "navigation_icon"), style: .Plain, target: self, action: #selector(MainViewController.onManageProfile(_:)))
        barButtonItem2.tintColor = UIColor().primaryColor()
        
        let toolbarItems: [UIBarButtonItem] = [barButtonItem1, flexiSpace, barButtonItem2]
        toolbar.setItems(toolbarItems, animated: true)
    }
    
    private func setTravelModeToolbar() {
        guard toolbar.items?.count < 6 else {
            //travel mode toolbar already set
            return
        }
        
        let flexiSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let barButtonItem1 = UIBarButtonItem(image: UIImage(named: "ic_directions_walk_green"), style: .Plain, target: self, action: #selector(MainViewController.onWalkingSelected))
        let barButtonItem2 = UIBarButtonItem(image: UIImage(named: "ic_directions_car_green"), style: .Plain, target: self, action: #selector(MainViewController.onDrivingSelected))
        let barButtonItem3 = UIBarButtonItem(image: UIImage(named: "ic_directions_bus_green"), style: .Plain, target: self, action: #selector(MainViewController.onTransitSelected))
        let barButtonItem4 = UIBarButtonItem(image: UIImage(named: "ic_directions_bike_green"), style: .Plain, target: self, action: #selector(MainViewController.onBikeSelected))
        
        let toolbarItems: [UIBarButtonItem] = [barButtonItem1, flexiSpace, barButtonItem2, flexiSpace, barButtonItem3, flexiSpace, barButtonItem4]
        toolbar.setItems(toolbarItems, animated: true)
        resetToolbarSelection()
        mainModel.getTravelMode()
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
    
    func onCheckSessionExpiration(timeToExpire: NSNumber?) {
        var expireTime = timeToExpire
        if expireTime == nil {
            setDefaultToolbarItem()
            expireTime = -1
        } else {
            setTravelModeToolbar()
        }
        
        locationServiceModel.startTracking(expireTime!)
    }
    
    //called when the only session was ignored
    func onNoSessionsAvailable() {
        setDefaultToolbarItem()
    }
    
    func onCreateNewSession(dateCreated: NSNumber) {
        locationServiceModel.startTracking(dateCreated)
    }
    
    func onSessionCompleted() {
        sessionModel.checkSessionExpiration()
    }
    
    func onLocationAuthorized() {
        if selectedFriend != nil {
            sessionModel.sendSessionRequest(selectedFriend!)
            selectedFriend = nil
        }
    }
    
    func onGetTravelMode(travelMode: Int) {
        switch travelMode {
        case TRAVEL_MODE.WALKING.rawValue:
            onWalkingSelected()
            break
        case TRAVEL_MODE.DRIVING.rawValue:
            onDrivingSelected()
            break
        case TRAVEL_MODE.TRANSIT.rawValue:
            onTransitSelected()
            break
        case TRAVEL_MODE.BIKE.rawValue:
            onBikeSelected()
            break
        default: break
        }
    }
    
    //MARK: TOOLBAR BUTTON CLICK EVENT
    func onManageFriend(sender: UIBarButtonItem) {
        Navigator.sharedInstance.navigateToFriendList(self)
    }
    
    func onManageProfile(sender: UIBarButtonItem) {
        Navigator.sharedInstance.navigateToManageProfile(self, user: user!)
    }
    
    func onWalkingSelected() {
        print("walking selected")
        resetToolbarSelection()
        toolbar.items![0].tintColor = UIColor.lightGrayColor()
        
        mainModel.setTravelMode(TRAVEL_MODE.WALKING.rawValue)
    }
    
    func onDrivingSelected() {
        print("driving selected")
        resetToolbarSelection()
        toolbar.items![2].tintColor = UIColor.lightGrayColor()
        
        mainModel.setTravelMode(TRAVEL_MODE.DRIVING.rawValue)
    }
    
    func onTransitSelected() {
        print("transit selected")
        resetToolbarSelection()
        toolbar.items![4].tintColor = UIColor.lightGrayColor()
        
        mainModel.setTravelMode(TRAVEL_MODE.TRANSIT.rawValue)
    }
    
    func onBikeSelected() {
        print("Bike selected")
        resetToolbarSelection()
        toolbar.items![6].tintColor = UIColor.lightGrayColor()
        
        mainModel.setTravelMode(TRAVEL_MODE.BIKE.rawValue)
    }
    
    func resetToolbarSelection() {
        for toolbarItems in toolbar.items! {
            toolbarItems.tintColor = UIColor().primaryColor()
        }
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
            setupDefaultSessionView(cell, friend: friendObj)
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
    
    private func setupDefaultSessionView(cell: FriendSessionTableViewCell, friend: Friend) {
        cell.addView(cell.view_default)
        cell.friend_name.text = friend.userName
        cell.img_action.hidden = true
    }
    
    private func setUpSentSessionView(cell: FriendSessionTableViewCell, friend: Friend) {
        cell.addView(cell.view_request_sent)
        cell.request_sent_name.text = friend.userName
        cell.request_sent_label.text = NSLocalizedString(GlobalString.sent_request_label, comment: "sent request label")
        cell.img_action.hidden = false
    }
    
    private func setUpReceivedSessionView(cell: FriendSessionTableViewCell, friend: Friend) {
        cell.addView(cell.view_session_request)
        cell.request_name.text = friend.userName
        cell.btn_accept.setTitle(NSLocalizedString(GlobalString.button_accept, comment: "accept button"), forState: .Normal)
        cell.btn_ignore.setTitle(NSLocalizedString(GlobalString.button_ignore, comment: "ignore button"), forState: .Normal)
        cell.img_action.hidden = false
    }
    
    private func setUpActiveSessionView(cell: FriendSessionTableViewCell, friend: Friend) {
        if let sessionData = friend.session?.sessionData {
            cell.addView(cell.view_distance_eta)
            let expireString = TravelInfoFactory.sharedInstance.isLocationDataExpired(friend.dateUpdated!) ?NSLocalizedString(GlobalString.expired_string, comment: "expired") : ""
            
            cell.session_distance.text = "\(NSLocalizedString(GlobalString.travel_info_distance, comment: "distance")) \(TravelInfoFactory.sharedInstance.getDistanceString(sessionData.distance!.doubleValue))" + expireString
            
            cell.session_eta.text = "\(NSLocalizedString(GlobalString.travel_info_eta, comment: "eta")) \(TravelInfoFactory.sharedInstance.getEtaString(sessionData.eta!.integerValue))" + expireString
            cell.session_location.text = "Location: Unknown"
        } else {
            setupDefaultSessionView(cell, friend: friend)
        }
        cell.img_action.hidden = false
        
        addCircularProgressView(cell)
    }
    
    private func addCircularProgressView(cell: FriendSessionTableViewCell) {
        cell.addCircularProgress()

        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MainViewController.setCircularProgressValue), userInfo: cell, repeats: true)
    }

    @objc private func setCircularProgressValue(timer: NSTimer) {
        let cell = timer.userInfo as! FriendSessionTableViewCell
        cell.circularProgressView.setNeedsDisplay()
    }
    
    //MARK: TABLEVIEW ACTION
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        if friend.session != nil && friend.session!.sessionType! != SessionFactory.sharedInstance.ACTIVE_SESSION {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        
        var sendRequest: UITableViewRowAction
        if friend.session == nil {
            sendRequest = UITableViewRowAction(style: .Normal, title: "Send Estimeet") { (action, index) in
                //check if the location service is available and then request the current location and store location to user defaults
                self.selectedFriend = friend
                
                //start tracking with default time + 1, if user not respond to the request, stop tracking
                self.locationServiceModel.startTracking(TimeConverter.sharedInstance.convertToMilliseconds(TimeType.MINUTES, value: SessionFactory.sharedInstance.DEFAULT_EXPIRE_TIME + 1))
                self.setTravelModeToolbar()
            }
            
        } else {
            //get distance and eta
            sendRequest = UITableViewRowAction(style: .Normal, title: "Request Estimeet") { (action, index) in
                self.mainModel.sendSessionDataRequest(friend)
                self.tableView.editing = false
            }
        }

        sendRequest.backgroundColor = UIColor().primaryColor()
        
        return [sendRequest]
    }
    
    func onCancelSession(indexPath: NSIndexPath) {
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        
        guard friend.session != nil else {
            return
        }
        sessionModel.cancelSession(friend)
    }
    
    func onSessionAccepted(indexPath: NSIndexPath) {
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        sessionModel.acceptNewSession(friend)
    }
    
    func onSessionIgnored(indexPath: NSIndexPath) {
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        sessionModel.removeSessionFromDb(friend)
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
                let cell = tableView.cellForRowAtIndexPath(indexPath) as? FriendSessionTableViewCell
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
        user = ModelFactory.sharedInstance.provideUserDefaults().getUserFromDefaults()
        
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
    var locationServiceModel: LocationServiceModel!
    
    var selectedFriend: Friend?
    
    private var locationManager: CLLocationManager!
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    private enum TRAVEL_MODE: Int {
        case WALKING, DRIVING, TRANSIT, BIKE
    }
}











