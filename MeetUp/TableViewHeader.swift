//
//  TableViewHeader.swift
//  MeetUp
//
//  Created by Chris Duan on 28/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class TableViewHeader {
    static let sharedInstance =  TableViewHeader()
    private init() {}
    
    func getTableHeaderView(tableView: UITableView, withTitle: String, withHeight: CGFloat,
                            textColor: UIColor!, backgroundColor: UIColor!) -> UIView! {
        
        let frame = tableView.frame
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: withHeight))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: frame.width, height: withHeight))
        
        //center the header label
        let labelCenter = label.center
        label.center.y = withHeight / CGFloat(2)
        label.center = labelCenter
        
        label.text = withTitle
        label.textColor = textColor
        
        view.addSubview(label)
        view.backgroundColor = backgroundColor
        
        return view
    }
}