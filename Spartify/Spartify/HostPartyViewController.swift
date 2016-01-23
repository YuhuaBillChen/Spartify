//
//  HostPartyViewController.swift
//  Spartify
//
//  Created by Bill on 1/23/16.
//  Copyright © 2016 pennapps. All rights reserved.
//

import UIKit
import Parse
import CoreMotion

class HostPartyViewController: UIViewController {
    let manager = CMMotionManager()
    
    @IBOutlet weak var XYZLabel: UILabel!
    func motionInit(){
                    let connection = Connection()
                    connection.createParty("LEFT")
        
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
                self.XYZLabel!.text=dispStr
                print(dispStr)
            })
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        motionInit()
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
