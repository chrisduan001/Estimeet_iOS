//
//  ManageFriendViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 24/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import Kingfisher

class ManageFriendViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, FriendListListener {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.topItem?.title = "Main"
        
        friendListModel = ModelFactory.sharedInstance.provideFriendListModel(self)
        friendListModel.getDbFriends()
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
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ManageFriendTableViewCell
        
        if cell == nil {
            let object = NibLoader.sharedInstance.loadNibWithName("ManageFriendCell", owner: nil, ofclass: ManageFriendTableViewCell.self)
            if object != nil {
                cell = object as? ManageFriendTableViewCell
            }
        }
        
        if cell != nil {
            let friend = friendList[indexPath.row]
            setUpCell(friend, cell: cell!)
        }

        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ManageFriendTableViewCell.CELL_HEIGHT
    }
    
    private func setUpCell(friend: FriendEntity, cell: ManageFriendTableViewCell) {
        cell.friendName.text = friend.userName
        cell.friendAction.image = UIImage(named: friend.isFavourite! ? "cancel" : "add_friend")
        
        if friend.image != nil {
            cell.friendDp.image = UIImage(data: friend.image!)
        } else {
            cell.friendDp.kf_setImageWithURL(NSURL(string: friend.dpUri)!,
                                         placeholderImage: nil,
                                              optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                        completionHandler: { (image, error, cacheType, imageURL) in
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                                                guard image != nil else {
                                                    return
                                                }
                                                self.friendListModel.saveFriendImage(UIImagePNGRepresentation(image!)!)
                                            }
            })
        }
    }
    
    //MARK: VARIABLE
    var friendList = [FriendEntity]()
    var friendListModel: FriendListModel!
}
