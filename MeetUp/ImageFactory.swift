//
//  ImageFactory.swift
//  MeetUp
//
//  Created by Chris Duan on 25/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ImageFactory {
    static let sharedInstance = ImageFactory()
    private init() {}
    
    func loadImageFromUrl(imageView: UIImageView, fromUrl: NSURL, placeHolder: Image?, completionHandler: CompletionHandler?) {
        imageView.kf_setImageWithURL(fromUrl, placeholderImage: placeHolder,
                                                   optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                             completionHandler: completionHandler)
    }
}