//
//  HostPartyViewController.swift
//  Spartify
//
//  Created by Bill on 1/23/16.
//  Copyright © 2016 pennapps. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import CoreMotion
import AudioToolbox

class HostPartyViewController: UIViewController {
    @IBOutlet weak var XYZLabel: UILabel!
    @IBOutlet weak var leavePartyButton: UIButton!
    @IBOutlet weak var setSeqButton: UIButton!
    @IBOutlet weak var seqLab: UILabel!
    @IBOutlet weak var seqLabel1: UILabel!
    @IBOutlet weak var seqLabel2: UILabel!
    @IBOutlet weak var seqLabel3: UILabel!
    @IBOutlet weak var seqLabel4: UILabel!
    @IBOutlet weak var clearSeqButton: UIButton!
    
    let SEQ_LENGTH = 4
    
    let manager = CMMotionManager()

    let GRAVITY_MARGIN = 0.2
    let ACCELE_TRH = 0.3
    let DELAY_TRH = 50
    
    var delayCounter = 0
    var sucessfullyChangStatus = false
    var currentState = "Normal"
    
    let userObj = PFUser.currentUser()!
    var partyObj:PFObject!
    
    var isSettingSeq = false
    var settingSeqNo = -1
    var seqArray = [String]()
    
    func changeMotionStatus(gx:Double,ax:Double,gy:Double,ay:Double,gz:Double,az:Double){
        if (delayCounter > DELAY_TRH){
            if (gx < (-1+self.GRAVITY_MARGIN) && (abs(ax) + abs(ay) + abs(az)) > self.ACCELE_TRH*3 ){
                self.currentState = "Left"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gx > (1-self.GRAVITY_MARGIN) && (abs(ax) + abs(ay) + abs(az)) > self.ACCELE_TRH*3){
                self.currentState = "Right"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gz < (-1+self.GRAVITY_MARGIN) && (abs(ax) + abs(ay) + abs(az)) > self.ACCELE_TRH*3 ){
                self.currentState = "Forward"
                self.sucessfullyChangStatus = true
                self.delayCounter = 0
            }
            else if (gz > (1-self.GRAVITY_MARGIN) && (abs(ax) + abs(ay) + abs(az)) > self.ACCELE_TRH*3){
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
        if (isSettingSeq){
            if (self.settingSeqNo < self.SEQ_LENGTH ){
                self.addOneSeq(self.currentState)
                self.delayCounter = -DELAY_TRH
                vibrate()
                if ( self.settingSeqNo == self.SEQ_LENGTH ){
                    self.setSeqEnd();
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
            
            self.changeMotionStatus(x,ax:x2,gy:y,ay:y2,gz:z,az:z2)

            self.updateCheck()
                
                print(dispStr)
            })
        }
    }
    
    func jumpToMainMenu(){
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MainMenuVC") as! ViewController
        manager.stopDeviceMotionUpdates();
        self.presentViewController(vc, animated: false, completion: nil)
    }

    @IBAction func leavePartyPressed(sender: UIButton) {

        sender.enabled = false;
        partyObj.deleteInBackgroundWithBlock{
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
    
    
    func setSeqStart(){
        clearSeq()
        isSettingSeq = true
        settingSeqNo = 0
        self.setSeqButton.enabled = false
        self.seqLab.hidden = false
    }
    
    func setSeqEnd(){
        isSettingSeq = false
        self.setSeqButton.enabled = true
        updateSeqArrayInParse()
        settingSeqNo = 0
    }

    func updateSeqArrayInParse(){
        partyObj["sequence"] = self.seqArray
        partyObj.saveInBackground()
    }
    
    func getCorrespondingSeqLabel(number:Int) -> UILabel{
        switch (number){
        case 1:
            return self.seqLabel1
        case 2:
            return self.seqLabel2
        case 3:
            return self.seqLabel3
        case 4:
            return self.seqLabel4
        default:
            return self.seqLabel1
        }
    }
    
    func addOneSeq(motion:String){
        self.seqArray.append(motion)
        settingSeqNo = seqArray.count
        let currentLabel = getCorrespondingSeqLabel(settingSeqNo)
        currentLabel.hidden = false
        currentLabel.text = motion
    }
    
    func clearSeq(){
        self.isSettingSeq = false
        self.seqLab.hidden = true
        self.setSeqButton.enabled = true
        self.settingSeqNo = -1
        seqArray.removeAll()
        updateSeqArrayInParse()
        for index in 1...5{
            getCorrespondingSeqLabel(index).hidden = true
        }
    }
    
    @IBAction func setSeqPressed(sender: AnyObject) {
        if (!isSettingSeq){
            setSeqStart()
        }
    }
    
    @IBAction func clearSeqPressed(sender: UIButton) {
        clearSeq();
    }
    
    func parseInit(){
        let partyQuery = PFQuery(className: "Party");
        partyQuery.whereKey("userId", equalTo:userObj);
        partyQuery.getFirstObjectInBackgroundWithBlock{
            (obj: PFObject?, error: NSError?) -> Void in
            if (error != nil){
                print ("Fetching party query failed")
            }
            else{
              self.partyObj = obj!
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        motionInit()
        parseInit()
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
