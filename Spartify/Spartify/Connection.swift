//
//  Connection.swift
//  Spartify
//
//  Created by Siyu Xie on 1/23/16.
//  Copyright © 2016 pennapps. All rights reserved.
//

import Parse
import ParseUI

class Connection{
    
    
    func createParty(gesture : String){
        let newParty = PFObject(className: "Party")
        let now = NSDate().description
        newParty["partyId"] = now
        let userId = PFUser.currentUser()?.objectId
        //        newParty["userId"] = userId
        //        newParty["gesture"] = gesture
        ////        removeExistingUserData(userId!, name: "Party")
        //        newParty.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        //            print("Party createrd.")
        //        }
        
        
        
        
        
        let query = PFQuery(className : "Party")
        query.whereKey("userId", equalTo: userId!)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil{
                newParty["partyId"] = now
                let userId = PFUser.currentUser()?.objectId
                newParty["userId"] = userId
                newParty["gesture"] = gesture
                newParty.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    print("Party createrd.")
                }
                
            }else {
                // The find succeeded.
                print("Successfully retrieved partyId \(object!["partyId"]) .")
                if let object = object{
                    object["partyId"] = now
                    object["gesture"] = gesture
                }
                object!.saveInBackground()
            }
        }
        
    }
    
    func joinParty(gesture : String){
        let userId = PFUser.currentUser()?.objectId
        let query = PFQuery(className:"Party")
        query.whereKey("gesture", equalTo: gesture)
        query.getFirstObjectInBackgroundWithBlock {
            (obj: PFObject?, error: NSError?) -> Void in
            if error != nil || obj == nil {
                print("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                print("Successfully retrieved partyId \(obj!["partyId"]) .")
                //                let newGuest = PFObject(className: "Guest")
                //                newGuest["userId"] = PFUser.currentUser()?.objectId
                //                newGuest["partyId"] = object!["partyId"]
                //                newGuest["gesture"] = gesture
                //                newGuest.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                //                    print("Party joined.")
                //                }
                let userId = PFUser.currentUser()?.objectId
                let query = PFQuery(className : "Guest")
                query.whereKey("userId", equalTo: userId!)
                query.getFirstObjectInBackgroundWithBlock {
                    (object: PFObject?, error: NSError?) -> Void in
                    if error != nil || object == nil{
                        let newGuest = PFObject(className: "Guest")
                        newGuest["userId"] = userId
                        newGuest["partyId"] = obj!["partyId"]
                        newGuest["gesture"] = gesture
                        newGuest.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                            print("Party joined.")
                        }
                        
                        
                    }else {
                        // The find succeeded.
                        print("Successfully retrieved partyId \(object!["partyId"]) .")
                        if let object = object{
                            object["userId"] = userId
                            object["gesture"] = gesture
                        }
                        object!.saveInBackground()
                    }
                }
                
                
            }
        }
    }
    
}