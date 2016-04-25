//
//  ManageFriendTableViewCell.swift
//  MeetUp
//
//  Created by Chris Duan on 24/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class ManageFriendTableViewCell: UITableViewCell {
    static let CELL_HEIGHT:CGFloat = 70
    
    weak var delegate: ManageFriendCellDelegate!

    @IBOutlet weak var friendDp: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendAction: UIImageView!
    
    var indexPath: NSIndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.friendDp.layer.cornerRadius = self.friendDp.frame.size.width / 2
        self.friendDp.clipsToBounds = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ManageFriendTableViewCell.friendActionTapped))
        friendAction.addGestureRecognizer(tapRecognizer)
    }
    
    func setDelegate(delegate: ManageFriendCellDelegate) {
        self.delegate = delegate
    }
    
    func friendActionTapped() {
        delegate.onAddFriendClicked(indexPath)
    }
}

protocol ManageFriendCellDelegate: class {
    func onAddFriendClicked(indexPath: NSIndexPath)
}