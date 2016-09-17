//
//  DpBaseViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 28/06/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class DpBaseViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgUserDp: UIImageView!
    
    private lazy var imagePicker: UIImagePickerController = self.setupImagePicker()
    
    var isRegisterController: Bool!
    
    //MARK: BASE METHOD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpImageView()
    }
    
    private func setUpImageView() {
        self.imgUserDp.layer.cornerRadius = self.imgUserDp.frame.size.width / 2
        self.imgUserDp.clipsToBounds = true
    }
    
    private func setupImagePicker() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        
        return imagePicker
    }
    
    private func scaleDown(image: UIImage, withSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(withSize, true, 0.0)
        image.drawInRect(CGRectMake(0, 0, withSize.width, withSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    private func compressImage(image: UIImage) -> NSData {
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.1
        var imageData = UIImageJPEGRepresentation(image, compression)
        
        //50k
        while imageData?.length > 50000 && compression > maxCompression {
            compression -= 0.2
            imageData = UIImageJPEGRepresentation(image, compression)
        }
        
        return imageData!
    }
    
    //MARK: DELEGATE
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
    
        let scale = scaleDown(image!, withSize: CGSize(width: 90, height: 90))
        let compressed = compressImage(scale)
        imgUserDp.image = UIImage(data: compressed)
        
        if !isRegisterController {
            addSaveDpButton()
        }
    }
    
    private func addSaveDpButton() {
        let saveButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ManageProfileViewController.saveTapped))
        navigationItem.setRightBarButtonItem(saveButtonItem, animated: true)
    }
    
    //MARK: METHOD USED BY SUBCLASS
    @IBAction func userDpTapped(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func getImageDataEncode() -> String {
        let imageData = UIImagePNGRepresentation(imgUserDp.image!)!
        print("image size: \(imageData.length / 1024))")
        return imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }
}
