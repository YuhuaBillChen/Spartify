//
//  LoginViewController.swift
//  Spartify
//
//  Created by Siyu Xie on 1/22/16.
//  Copyright © 2016 pennapps. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class LoginViewController : PFLogInViewController {
    
    var backgroundImage : UIImageView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set our custom background image
        backgroundImage = UIImageView(image: UIImage(named: "PFLoginBackground"))
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.logInView!.insertSubview(backgroundImage, atIndex: 0)
        
        let logo = UILabel()
        logo.text = "Spartify"
        logo.textColor = UIColor.whiteColor()
        logo.font = UIFont(name:"Helvetica", size: 55)
        logo.shadowColor = UIColor.lightGrayColor()
        logo.shadowOffset = CGSizeMake(2, 2)
        logInView?.logo = logo
        
        logInView!.logo!.sizeToFit()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRectMake( 0,  0,  self.logInView!.frame.width,  self.logInView!.frame.height)
    }
    
}