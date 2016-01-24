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
import CoreMotion

class ViewController:UIViewController, PFLogInViewControllerDelegate{
    @IBOutlet weak var jointPartyButton: UIButton!
    @IBOutlet weak var hostPartyButton: UIButton!

    var userObj = PFUser.currentUser()
    var partyId:PFObject!
    var isHost = false
    var stateUpdating = false
    
    func createParty(){
        let newParty = PFObject(className: "Party")
        newParty["userId"]=self.userObj;
        newParty.saveInBackgroundWithBlock{
            
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                self.jumpToHostPary()
            } else {
                // There was a problem, check error.description
                print("failed to create a new party room")
                self.enableAllButtons()
            }
        }
    }
    
    func joinParty(){
        //TODO jump to a list of parties
        let partyQuery = PFQuery(className:"Party")
        
        //Right now just find the first party room and join
        partyQuery.getFirstObjectInBackgroundWithBlock{
            (obj: PFObject? , error: NSError?) -> Void in
            if (error != nil || obj == nil ){
                print ("There are no party rooms, please create a new one")
                self.enableAllButtons()
            }
            else{
                let newGuest = PFObject(className: "Guest")
                newGuest["userId"]=self.userObj
                newGuest["partyId"]=obj
                newGuest.saveInBackgroundWithBlock{
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        self.jumpToJoinParty()
                    } else {
                        // There was a problem, check error.description
                        print("failed to create a new party room")
                        self.enableAllButtons()
                    }
                }
            }
        }
    }
    
    func enableAllButtons(){
        self.jointPartyButton.enabled = true
        self.hostPartyButton.enabled = true
    }
    
    func disableAllButtons(){
        self.jointPartyButton.enabled = false
        self.hostPartyButton.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    func jumpToJoinParty(){
        let jointPartyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("JoinPartyVC") as! JoinPartyViewController;
        self.presentViewController(jointPartyViewController, animated: true, completion: nil)
    }
    
    func jumpToHostPary(){
        let hostPartyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HostPartyVC") as! HostPartyViewController;

        self.presentViewController(hostPartyViewController, animated: true, completion: nil)
    }
    
    func checkPartySteate(){
        self.stateUpdating = true
        let guestQuery = PFQuery(className:"Guest")
        let partyQuery = PFQuery(className:"Party")
        
        // Check whether this user is a party host
        partyQuery.whereKey("userId", equalTo:userObj!)
        partyQuery.getFirstObjectInBackgroundWithBlock{
            (obj: PFObject?, error: NSError?) -> Void in
            if (error != nil || obj == nil){
                guestQuery.whereKey("userId", equalTo:self.userObj!)
                guestQuery.getFirstObjectInBackgroundWithBlock{
                    (obj: PFObject? , error: NSError?) -> Void in
                    if (error != nil || obj == nil){
                        self.partyId = nil
                        self.isHost = false
                        
                        //Enable buttons to choose action
                        self.enableAllButtons()

                    }
                    else{
                        self.partyId = obj!
                        self.isHost = false
                        self.jumpToJoinParty()
                    }
                    self.stateUpdating = false
                }
            }
            else{
                self.partyId = obj
                self.isHost = true
                self.stateUpdating = false
                    
                //Jump to party host party view controller
                self.jumpToHostPary()
            }
        }
    }
    
    @IBAction func joinPartyPressed(sender: UIButton) {
        self.disableAllButtons()
        self.joinParty()
    }
    
    @IBAction func createPartyPressed(sender: UIButton) {
        self.disableAllButtons()
        self.createParty()
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
        userObj = PFUser.currentUser()
        if ( userObj == nil) {
            createLoginViewController()
        }
        else{
            //            let connection = Connection()
            //            connection.createParty("LEFT")
            //            connection.joinParty("LEFT")
            
            //presentLoggedInAlert()
            checkPartySteate()
            //TODO: Show main screen content
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

