//
//  JoinPartyViewController.swift
//  Spartify
//
//  Created by Bill on 1/23/16.
//  Copyright © 2016 pennapps. All rights reserved.
//

import UIKit
import Parse
import CoreMotion


class JoinPartyViewController: UIViewController {

    let manager = CMMotionManager()
    let GRAVITY_MARGIN = 0.2
    let ACCELE_TRH = 0.2
    var delayCounter = 0
    var sucessfullyChangStatus = false
    var currentState = "Normal"
    
    let userObj = PFUser.currentUser()!
    var partyObj:PFObject!
    var hostObj:PFUser!
    var guestObj:PFObject!
    
    @IBOutlet weak var XYZLabel: UILabel!
    @IBOutlet weak var leavePartyButton: UIButton!

    func changeMotionStatus(gx:Double,ax:Double,gy:Double,ay:Double,gz:Double,az:Double){
        if (delayCounter > 50){
            if (gx < (-1+self.GRAVITY_MARGIN) && ax < -self.ACCELE_TRH*2 ){
                self.currentState = "Left"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gx > (1-self.GRAVITY_MARGIN) && ax > self.ACCELE_TRH*2){
                self.currentState = "Right"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gz < (-1+self.GRAVITY_MARGIN) && az < -self.ACCELE_TRH ){
                self.currentState = "Frontward"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gz > (1-self.GRAVITY_MARGIN) && az > self.ACCELE_TRH){
                self.currentState = "Backward"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gy < (-1+self.GRAVITY_MARGIN) && ay < -self.ACCELE_TRH ||
                gy > (1-self.GRAVITY_MARGIN) && ay > self.ACCELE_TRH){
                    self.currentState = "Tiltting"
                    self.sucessfullyChangStatus = true
                    self.delayCounter = 0
            }
            else{
                if (self.currentState != "Normal"){
                    self.currentState = "Normal"
                    self.sucessfullyChangStatus = true
                }
            }
        }
    }
    
    func updateCheck(){
        if (self.sucessfullyChangStatus){
            self.XYZLabel!.text = self.currentState
            self.sucessfullyChangStatus = false;
        }
        else{
            self.delayCounter += 1
        }
    }
    
    func motionInit(){
        if manager.deviceMotionAvailable {
            let _:CMAccelerometerData!
            let _:NSError!
            manager.deviceMotionUpdateInterval = 0.01
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler:{
                accelerometerData, error in
                let x = accelerometerData!.gravity.x
                let y = accelerometerData!.gravity.y
                let z = accelerometerData!.gravity.z
                let x2 = accelerometerData!.userAcceleration.x;
                let y2 = accelerometerData!.userAcceleration.y;
                let z2 = accelerometerData!.userAcceleration.z;
                let dispStr = String(format:"g x: %1.2f, y: %1.2f, z: %1.2f a x: %1.2f y:%1.2f z:%1.2f",x,y,z,x2,y2,z2)
                self.changeMotionStatus(x,ax:x2,gy:y,ay:y2,gz:z,az:z2);
                
                if (self.currentState != "Normal"){
                }
                self.updateCheck()
                print(dispStr)
                
            })
        }
    }

    @IBAction func leavePartyPressed(sender: UIButton) {
        sender.enabled = false;
        guestObj.deleteInBackgroundWithBlock{
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                self.jumpToMainMenu()
            } else {
                // There was a problem, check error.description
                print("failed to create a new party room")
                self.leavePartyButton.enabled = true;
            }
            
        }
    }
    
    func parseInit(){
        let guestQuery = PFQuery(className: "Guest");
        guestQuery.whereKey("userId", equalTo:userObj);
        guestQuery.getFirstObjectInBackgroundWithBlock{
            (obj: PFObject?, error: NSError?) -> Void in
            if (error != nil){
                print ("Fetching party query failed")
            }
            else{
                self.guestObj = obj!
                self.partyObj = (self.guestObj["partyId"])! as! PFObject
                self.hostObj = (self.partyObj["userId"])! as! PFUser
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        motionInit()
        parseInit()
    }

    func jumpToMainMenu(){
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainMenuVC") as! ViewController
        manager.stopDeviceMotionUpdates();
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
