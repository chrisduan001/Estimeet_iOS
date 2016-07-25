//
//  ViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import CoreLocation
import Crashlytics

class MainViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,
    NSFetchedResultsControllerDelegate, MainModelListener, SessionListener, GetNotificationListener,
    FriendSessionCellDelegate, LocationServiceListener {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var travelModeToolbar: UIView!
    
    @IBOutlet var travel_mode_walk: UIImageView!
    @IBOutlet var travel_mode_car: UIImageView!
    @IBOutlet var travel_mode_bus: UIImageView!
    @IBOutlet var travel_mode_bike: UIImageView!
    
    @IBOutlet weak var travelModeToolbarHeightContraint: NSLayoutConstraint!
    
    @IBOutlet var noFriendView: UIView!
    
    private var travelModeToolbarDefaultHeight: CGFloat!
    
    var locationManager: CLLocationManager!
    
    //MARK: LIFECYCLE & View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FabricLogger.sharedInstance.setUserInfo()
        
        //push notification received observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(onReceiveNotification), name: PushNotification.GENERAL_NOTIFICATION_KEY, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onReceiveNoSessionNotification), name: PushNotification.NO_SESSION_KEY, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onFriendLocationAvailable), name: PushNotification.FRIEND_LOCATION_AVAILABLE_KEY, object: nil)
        
        //app delegate observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onReceiveLifecycleNotification), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        let headerImg = UIImage(named: "home_logo")
        self.navigationItem.titleView = UIImageView(image: headerImg)
        
        travelModeToolbarDefaultHeight = travelModeToolbar.frame.size.height
        
        //models
        mainModel = ModelFactory.sharedInstance.provideMainModel(self)
        mainModel.setUpMainTableView()
        sessionModel = ModelFactory.sharedInstance.provideSessionModel(self)
        getNotificationModel = ModelFactory.sharedInstance.provideGetNotificationModel(self)
        
        //register push notification
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.registerForPushNotifications(UIApplication.sharedApplication())
        
        checkLocationPermission()
    }

    override func viewWillAppear(animated: Bool) {
        onResume()
    }

    private func addNoFriendView() {
        noFriendView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - toolbar.frame.height)
        view.addSubview(noFriendView)
        noFriendView.bringSubviewToFront(noFriendView)
    }
    
    private func removeNoFriendView() {
        noFriendView.removeFromSuperview()
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
        removeTravelModeToolbar()
    }
    
    @objc private func onReceiveLifecycleNotification() {
        onResume()
    }
    
    @objc private func onFriendLocationAvailable() {
        mainModel.requestPendingFriendSessionData()
    }
    
    private func onResume() {
        print("on resume called")
        sessionModel.checkSessionExpiration()
        
        if UIApplication.sharedApplication().applicationState == .Active {
            getNotificationModel.getAllNotifications()
            mainModel.requestPendingFriendSessionData()
        }
    }
    
    //MARK: MODEL CALLBACK
    func setSessionFetchedResultsController(fetchedResultsController: NSFetchedResultsController) {
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            FabricLogger.sharedInstance.logError("CatchedException: An exception occurred while fetch request", className: String(MainViewController), code: 0, userInfo: nil)
        }
    }
    
    override func onAuthFail() {
        super.onAuthFail()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onCheckSessionExpiration(timeToExpire: Int?) {
        var expireTime = timeToExpire
        if expireTime == nil {
            removeTravelModeToolbar()
            expireTime = -1
        } else {
            setTravelModeToolbarVisible()
        }
        
        continuousLocationService.startContinuousTracking(NSNumber(integer: expireTime!))
    }
    
    func onNoSessionsAvailable() {
        removeTravelModeToolbar()
    }
    
    func onCreateNewSession(expiresInMillis: NSNumber) {
        continuousLocationService.startContinuousTracking(expiresInMillis)
    }
    
    func onSessionCompleted() {
        sessionModel.checkSessionExpiration()
    }
    
    func onLocationAuthorized() {
        //check if location permission granted when trying to send request 
        //or request user's location
        
        //selected frine == nil when mainvc shows up and check if user has correct permission
        if selectedFriend != nil {
            self.setTravelModeToolbarVisible()
            sessionModel.sendSessionRequest(selectedFriend!)
            selectedFriend = nil
        }
    }
    
    func onLocationDenied() {
        onErrorWithSettings(NSLocalizedString(GlobalString.error_permission_title, comment: "Permission denied title"), message: NSLocalizedString(GlobalString.user_location_failed, comment: "Location denied"))
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
    @IBAction func manageFriendClicked(sender: UIBarButtonItem) {
        onManageFriend()
    }
    
    @IBAction func manageProfileClicked(sender: UIBarButtonItem) {
        onManageProfile(sender)
    }
    
    @IBAction func walkTapped(sender: UITapGestureRecognizer) {
        onWalkingSelected()
    }
    
    @IBAction func carTapped(sender: UITapGestureRecognizer) {
        onDrivingSelected()
    }
    
    @IBAction func busTapped(sender: UITapGestureRecognizer) {
        onTransitSelected()
    }
    
    @IBAction func bikeTapped(sender: UITapGestureRecognizer) {
        onBikeSelected()
    }
    
    @IBAction func onAddFriendsClicked(sender: UIButton) {
        onManageFriend()
    }
    
    private func onManageFriend() {
        Navigator.sharedInstance.navigateToFriendList(self)
    }
    
    private func onManageProfile(sender: UIBarButtonItem) {
        Navigator.sharedInstance.navigateToManageProfile(self)
    }
    
    private func onWalkingSelected() {
        print("walking selected")
        resetToolbarSelection()
        travel_mode_walk.image = getUIImageNamed("ic_directions_walk_selected")
        mainModel.setTravelMode(TRAVEL_MODE.WALKING.rawValue)
    }
    
    private func onDrivingSelected() {
        print("driving selected")
        resetToolbarSelection()
        travel_mode_car.image = getUIImageNamed("ic_directions_car_selected")
        
        mainModel.setTravelMode(TRAVEL_MODE.DRIVING.rawValue)
    }
    
    private func onTransitSelected() {
        print("transit selected")
        resetToolbarSelection()
        travel_mode_bus.image = getUIImageNamed("ic_directions_bus_selected")
        
        mainModel.setTravelMode(TRAVEL_MODE.TRANSIT.rawValue)
    }
    
    private func onBikeSelected() {
        print("Bike selected")
        resetToolbarSelection()
        travel_mode_bike.image = getUIImageNamed("ic_directions_bike_selected")
        
        mainModel.setTravelMode(TRAVEL_MODE.BIKE.rawValue)
    }
    
    private func resetToolbarSelection() {
        travel_mode_walk.image = getUIImageNamed("ic_directions_walk")
        travel_mode_car.image = getUIImageNamed("ic_directions_car")
        travel_mode_bus.image = getUIImageNamed("ic_directions_bus")
        travel_mode_bike.image = getUIImageNamed("ic_directions_bike")
    }
    
    private func getUIImageNamed(name: String) -> UIImage {
        return UIImage(named: name)!
    }
    
    //MARK: TRAVEL MODE TOOLBAR 
    private func setTravelModeToolbarVisible() {
        guard travelModeToolbarHeightContraint.constant == 0 else {
            return
        }
        travelModeToolbarHeightContraint.constant = travelModeToolbarDefaultHeight
        resetToolbarSelection()
        mainModel.getTravelMode()
    }
    
    private func removeTravelModeToolbar() {
        travelModeToolbarHeightContraint.constant = 0
    }
    
    //MARK: OTHER LOGIC
    private func checkBAFAvailability() -> Bool {
        if UIApplication.sharedApplication().backgroundRefreshStatus != .Available {
            onErrorWithSettings(NSLocalizedString(GlobalString.error_permission_title, comment: "title"), message: NSLocalizedString(GlobalString.error_baf, comment: "BAF Unavailable"))
            return false
        }
        
        return true
    }
    
    //MARK: TABLEVIEW
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections where sections.count > 0 {
            removeNoFriendView()
            return sections.count
        }
        
        addNoFriendView()
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
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cellWillEndDisplay = cell as? FriendSessionTableViewCell {
            cellWillEndDisplay.stopTimer()
        }
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
        
        cell.setCellIndexPath(indexPath)
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
    
    //view for session data not obtained, and request is sent
    private func setupRequestedSessionView(cell: FriendSessionTableViewCell, friend: Friend, requestExpired: Bool) {
        setupDefaultSessionView(cell, friend: friend)
        cell.friend_name.text = friend.userName! + (requestExpired ? " (Location failed)" : " (Requested)")
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
            if sessionData.distance != nil && sessionData.eta != nil{
                setupLocationDataCell(cell, dateUpdated: friend.dateUpdated!, sessionData: sessionData)
            } else {
                //session distance and eta value is not available
                //todo..need to set up a proper design for this
                setupRequestedSessionView(cell, friend: friend, requestExpired: isWaitingForFriendLocationExpired(sessionData) )
            }
            
        } else {
            setupDefaultSessionView(cell, friend: friend)
        }
        cell.img_action.hidden = false
        
        addCircularProgressView(cell)
    }
    
    private func setupLocationDataCell(cell: FriendSessionTableViewCell, dateUpdated: NSNumber, sessionData: SessionData) {
        cell.addView(cell.view_distance_eta)
        
        //todo..find a proper design for message that showing friend's location is not available
        let expireString = TravelInfoFactory.sharedInstance.isLocationDataExpired(dateUpdated) ?
        isWaitingForFriendLocationExpired(sessionData) ? "Location failed" :
            NSLocalizedString(GlobalString.expired_string, comment: "expired") : ""
        
        cell.session_distance.text = "\(NSLocalizedString(GlobalString.travel_info_distance, comment: "distance")) \(TravelInfoFactory.sharedInstance.getDistanceString(sessionData.distance!.doubleValue))" + expireString
        
        cell.session_eta.text = "\(NSLocalizedString(GlobalString.travel_info_eta, comment: "eta")) \(TravelInfoFactory.sharedInstance.getEtaString(sessionData.eta!.integerValue))" + expireString
        cell.session_location.text = "\(NSLocalizedString(GlobalString.travel_info_location, comment: "location")) \(sessionData.location!)" + expireString
    }
    
    private func isWaitingForFriendLocationExpired(sessionData: SessionData) -> Bool {
        let timeToWaitForFriendLocationUpdate = 180.0 //3 minutes
        if let waitingTime = sessionData.timeOnWaitingUpdate {
            if (NSDate.timeIntervalSinceReferenceDate() - waitingTime.doubleValue) > timeToWaitForFriendLocationUpdate {
                return true
            }
        }
        
        return false
    }
    
    private func addCircularProgressView(cell: FriendSessionTableViewCell) {
        cell.addCircularProgress()
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
            sendRequest = UITableViewRowAction(style: .Normal, title: NSLocalizedString(GlobalString.action_send_estimeet, comment: "Send Estimeet")) { (action, index) in
                //check background app refresh
                guard self.checkBAFAvailability() else {
                    return
                }
                //check if the location service is available and then request the current location and store location to user defaults
                self.selectedFriend = friend
                
                //start tracking with default time + 1, if user not respond to the request, stop tracking
                self.continuousLocationService.startContinuousTracking(TimeConverter.sharedInstance.convertToMilliseconds(TimeType.MINUTES, value: SessionFactory.sharedInstance.DEFAULT_EXPIRE_TIME + 1))
            }
            
        } else {
            //get distance and eta
            sendRequest = UITableViewRowAction(style: .Normal, title: NSLocalizedString(GlobalString.action_refresh, comment: "Refresh")) { (action, index) in
                self.mainModel.sendSessionDataRequest(friend)
                self.tableView.editing = false
            }
        }
        
        UIButton.appearance().setAttributedTitle(MeetUpAttributedString.sharedInstance.getCustomFontAttributedString(sendRequest.title!, size: 17.0, typeface: MeetUpAttributedString.CustomFontTypeface.semiBold), forState: .Normal)
        
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
        guard checkBAFAvailability() else {
            return
        }
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        sessionModel.acceptNewSession(friend)
    }
    
    func onSessionIgnored(indexPath: NSIndexPath) {
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friend
        sessionModel.removeSessionFromDb(friend)
    }
    
    func onCellTimerTicked(cell: FriendSessionTableViewCell) {
        let friend = fetchedResultsController.objectAtIndexPath(cell.getCellIndexPath()) as! Friend
        
        guard let session = friend.session else {
            cell.stopTimer()
            return
        }
        
        let timePassed = NSDate.timeIntervalSinceReferenceDate() * 1000 - session.dateCreated!.doubleValue
        let totalTime = session.expireInMillis!.doubleValue
        if timePassed < totalTime {
            let progress = timePassed / totalTime
            cell.setCellSessionProgress(CGFloat(progress))
            cell.circularProgressView.progress = CGFloat(progress)
            cell.circularProgressView.setNeedsDisplay()
        } else {
            cell.stopTimer()
        }
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
    
    //MARK: LOCATION PERMISSION
    private func checkLocationPermission() {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager = CLLocationManager()
            locationManager.requestAlwaysAuthorization()
        }
    }

    var sessionModel: SessionModel!
    var getNotificationModel: GetNotificationModel!
    var mainModel: MainModel!
    
    lazy var friendListModel: FriendListModel = {
        return ModelFactory.sharedInstance.provideFriendListModel(nil)
    }()
    
    lazy var continuousLocationService: ContinuousLocationService = {
        [unowned self] in
        return ModelFactory.sharedInstance.provideLocationServicemodel(self)
    }()
    
    var selectedFriend: Friend?
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    private enum TRAVEL_MODE: Int {
        case WALKING, DRIVING, TRANSIT, BIKE
    }
}











