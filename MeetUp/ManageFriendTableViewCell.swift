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

    @IBOutlet weak var friendDp: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendAction: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.friendDp.layer.cornerRadius = self.friendDp.frame.size.width / 2
        self.friendDp.clipsToBounds = true
    }
}
