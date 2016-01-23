//
//  ViewController.swift
//  Spartify
//
//  Created by Bill on 1/22/16.
//  Copyright © 2016 pennapps. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class ViewController: UIViewController,PFLogInViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() == nil) {
            let loginViewController = PFLogInViewController()
            loginViewController.delegate = self
            self.presentViewController(loginViewController, animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

