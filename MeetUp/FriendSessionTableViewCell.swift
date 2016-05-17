//
//  FriendSessionTableViewCell.swift
//  MeetUp
//
//  Created by Chris Duan on 7/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class FriendSessionTableViewCell: UITableViewCell {

    @IBOutlet weak var img_dp: UIImageView!
    @IBOutlet weak var img_action: UIImageView!
    @IBOutlet weak var view_container: UIView!
    
    //session request container
    @IBOutlet var view_session_request: UIView!
    @IBOutlet weak var request_name: UILabel!
    @IBOutlet weak var btn_accept: RoundButton!
    @IBOutlet weak var btn_ignore: UIButton!
    
    //session default container
    @IBOutlet var view_default: UIView!
    @IBOutlet weak var friend_name: UILabel!
    
    //session distance and eta
    @IBOutlet var view_distance_eta: UIView!
    @IBOutlet weak var session_distance: UILabel!
    @IBOutlet weak var session_eta: UILabel!
    @IBOutlet weak var session_location: UILabel!
    
    //session request sent
    @IBOutlet var view_request_sent: UIView!
    @IBOutlet weak var request_sent_name: UILabel!
    @IBOutlet weak var request_sent_label: UILabel!
    
    var indexPath: NSIndexPath!
    var delegate: FriendSessionCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        img_dp.layer.cornerRadius = img_dp.frame.size.width / 2
        img_dp.clipsToBounds = true
        
        img_action.layer.cornerRadius = img_action.frame.size.width / 2
        img_action.clipsToBounds = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FriendSessionTableViewCell.actionButtonTapped))
        img_action.addGestureRecognizer(tapRecognizer)
    }
    
    func addView(view: UIView) {
        let subViews = view_container.subviews
        if subViews.count > 0 {
            removeAllSubview(subViews)
        }
        
        view_container.addSubview(view)
    }
    
    func actionButtonTapped() {
        delegate.onCancelSession(indexPath)
    }
    
    private func removeAllSubview(subviews: [UIView]) {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    func setDelegate(delegate: FriendSessionCellDelegate) {
        self.delegate = delegate
    }
}

protocol FriendSessionCellDelegate: class {
    func onCancelSession(indexPath: NSIndexPath)
}
