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
import Foundation
import AudioToolbox


class JoinPartyViewController: UIViewController {

    let manager = CMMotionManager()
    
    let SEQ_LENGTH = 4
    let GRAVITY_MARGIN = 0.25
    let ACCELE_TRH = 0.2
    let DELAY_TRH = 50
    
    var delayCounter = 0
    var parseCounter = 0
    var sucessfullyChangStatus = false
    var currentState = "Normal"
    
    let userObj = PFUser.currentUser()!
    var partyObj:PFObject!
    var hostObj:PFUser!
    var guestObj:PFObject!
    

    var isFinishedSeq = false
    var partySeqArray = [String]()
    var seqArray = [String]()
    
    var settingSeqNo = -1
    
    @IBOutlet weak var XYZLabel: UILabel!
    @IBOutlet weak var leavePartyButton: UIButton!
    @IBOutlet weak var partySeqLabel: UILabel!
    @IBOutlet weak var yourSeqLabel: UILabel!
    
    func changeMotionStatus(gx:Double,ax:Double,gy:Double,ay:Double,gz:Double,az:Double){
        if (delayCounter > DELAY_TRH){
            if (gx < (-1+self.GRAVITY_MARGIN) && abs(ax) + abs(ay) + abs(az) > self.ACCELE_TRH*3 ){
                self.currentState = "Left"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gx > (1-self.GRAVITY_MARGIN) && abs(ax) + abs(ay) + abs(az) > self.ACCELE_TRH*3){
                self.currentState = "Right"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gz < (-1+self.GRAVITY_MARGIN) && abs(ax) + abs(ay) + abs(az) > self.ACCELE_TRH*3 ){
                self.currentState = "Forward"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gz > (1-self.GRAVITY_MARGIN) && abs(ax) + abs(ay) + abs(az) > self.ACCELE_TRH*3){
                self.currentState = "Backward"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (abs(gx) < (self.GRAVITY_MARGIN) && abs(gz) < self.GRAVITY_MARGIN && gy < -(1-self.GRAVITY_MARGIN) && (abs(ax) + abs(ay) + abs(az)) > self.ACCELE_TRH*3){
                self.currentState = "Up"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (abs(gx) < (self.GRAVITY_MARGIN) && abs(gz) < self.GRAVITY_MARGIN && gy > (1-self.GRAVITY_MARGIN) && (abs(ax) + abs(ay) + abs(az)) > self.ACCELE_TRH*3){
                self.currentState = "Down"
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
    
    func changeBackground(){
        if (self.currentState == "Normal"){
            self.view.backgroundColor = UIColor.whiteColor()
        }
        else if (self.currentState == "Left"){
            self.view.backgroundColor = UIColor.redColor()
        }
        else if (self.currentState == "Right"){
            self.view.backgroundColor = UIColor.greenColor()
        }
        else if (self.currentState == "Up"){
            self.view.backgroundColor = UIColor.orangeColor()
        }
        else if (self.currentState == "Down"){
            self.view.backgroundColor = UIColor.purpleColor()
        }
        else if (self.currentState == "Forward"){
            self.view.backgroundColor = UIColor.blueColor()
        }
        else if (self.currentState == "Backward"){
            self.view.backgroundColor = UIColor.yellowColor()
        }
        else{
            self.view.backgroundColor = UIColor.grayColor()
        }
    }
    
    func vibrate(){
        AudioToolbox.AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func beep(){
        AudioToolbox.AudioServicesPlaySystemSound(1109)
    }
    
    func addSeqUpdater(){
        if (!isFinishedSeq){
            if (self.settingSeqNo < self.SEQ_LENGTH ){
                self.addOneSeq(self.currentState)
                self.delayCounter = -DELAY_TRH
                vibrate()
                if ( self.settingSeqNo == self.SEQ_LENGTH ){
                    if (self.seqArray == self.partySeqArray){
                        self.setSeqEnd();
                    }
                    else{
                        setSeqStart()
                    }
                }
            }
        }
    }

    func partyObjUpdate(){
        partyObj.fetchInBackgroundWithBlock(){
            (obj: PFObject?, error: NSError?) -> Void in
            if (error == nil && obj != nil){
                self.partyObj = obj
                if (self.isFinishedSeq || self.seqArray.count == 0 || self.partySeqArray.count == 0 ){
                    if (obj!["sequence"] != nil && obj!["sequence"].count > 0){
                        if (obj!["sequence"] as! Array<NSString> != self.partySeqArray){
                            self.partySeqArray = obj!["sequence"] as! [String]
                            self.partySeqLabel.hidden = false
                            self.partySeqLabel.text = self.partySeqArray.joinWithSeparator("--->")
                            self.setSeqStart()
                        }
                    }
              }
            }
        }
    }
    
    func updateCheck(){
        if (self.sucessfullyChangStatus){
            self.XYZLabel!.text = self.currentState
            changeBackground()
            beep()
            if (self.currentState != "Normal"){
                addSeqUpdater()
            }
            self.sucessfullyChangStatus = false;
        }
        else{
            self.delayCounter += 1
        }
    }
    
    func parseCheck(){
        if (parseCounter < 100){
            parseCounter += 1
        }
        else{
            self.partyObjUpdate()
            parseCounter = 0
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
                self.changeMotionStatus(x,ax:x2,gy:y,ay:y2,gz:z,az:z2);
                
                if (self.currentState != "Normal"){
                    
                }
                self.updateCheck()
                
                self.parseCheck()
                let dispStr = String(format:"%s g x: %1.2f, y: %1.2f, z: %1.2f a x: %1.2f y:%1.2f z:%1.2f",self.currentState, x,y,z,x2,y2,z2)
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

    func setSeqStart(){
        clearSeq()
        self.isFinishedSeq = false
        settingSeqNo = 0
        self.yourSeqLabel.hidden = false
        self.yourSeqLabel.text=""
    }
    
    func addOneSeq(motion:String){
        self.seqArray.append(motion)
        settingSeqNo = seqArray.count
        self.yourSeqLabel.hidden = false
        self.yourSeqLabel.text = seqArray.joinWithSeparator("--->")
    }
    
    func clearSeq(){
        self.yourSeqLabel.hidden = true
        self.seqArray.removeAll()
        self.settingSeqNo = -1
    }
    
    func setSeqEnd(){
        self.isFinishedSeq = true
        self.yourSeqLabel.hidden = false
        self.yourSeqLabel.text = "You've finished this party sequence"
        settingSeqNo = 0
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
