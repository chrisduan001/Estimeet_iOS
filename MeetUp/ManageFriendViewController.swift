//
//  ManageFriendViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 24/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import Kingfisher

class ManageFriendViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate,
FriendListListener, ManageFriendCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Main"
        
        friendListModel = ModelFactory.sharedInstance.provideFriendListModel(self)
        friendListModel.getFriendFetchedResultsController()
    }
    
    //MARK: CALLBACK
    func setFriendFetchedResultsController(fetchedResultsController: NSFetchedResultsController) {
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects?.count <= 0 {
                startActivityIndicator()
                friendListModel.makeNetworkRequest()
            } else {
                tableView.reloadData()
            }
        } catch {
            print("An exception occurred while fetch reuest")
        }
    }
    
    func onGetFriendList(friends: [FriendEntity]?) {
        endActivityIndicator()
    }
    
    //MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
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
        case .Update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ManageFriendTableViewCell
                setUpCell(cell, indexPath: indexPath)
            }
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    //MARK: TABLE VIEW
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
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
            if object != nil {
                cell = object as? ManageFriendTableViewCell
            }
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
        let friendObj = fetchedResultsController.objectAtIndexPath(indexPath)
        let friend = DataEntity.sharedInstance.translateFriendObjToFriendEntity(friendObj)
        cell.indexPath = indexPath
        cell.setDelegate(self)
        cell.friendName.text = friend.userName
        cell.friendAction.image = UIImage(named: friend.isFavourite! ? "cancel" : "add_friend")
        
        if friend.image != nil {
            cell.friendDp.image = UIImage(data: friend.image!)
        } else {
            ImageFactory.sharedInstance.loadImageFromUrl(cell.friendDp,
                                                         fromUrl: NSURL(string:friend.dpUri)!,
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
    
    //MARK: CELL DELEGATE
    func onAddFriendClicked(indexPath: NSIndexPath) {
        friendListModel.setFavouriteFriend(fetchedResultsController.objectAtIndexPath(indexPath))
    }
    
    //MARK: VARIABLE
    var friendList = [FriendEntity]()
    var friendListModel: FriendListModel!
}
