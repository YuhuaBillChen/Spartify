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


class ViewController:UIViewController, PFLogInViewControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    func presentLoggedInAlert() {
        let alertController = UIAlertController(title: "You're logged in", message: "Welcome to Spartify", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        presentLoggedInAlert()
    }
    
    func createLoginViewController(){
        let loginViewController = LoginViewController()
        loginViewController.delegate = self
        
        loginViewController.fields = [.UsernameAndPassword, .LogInButton , .PasswordForgotten, .SignUpButton, .Facebook,  .Twitter]
        loginViewController.emailAsUsername = true
        self.presentViewController(loginViewController, animated: false, completion: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() == nil) {
            createLoginViewController()
        }
        else{
            presentLoggedInAlert()
            
            //TODO: Show main screen content
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

