////
////  Connection.swift
////  Spartify
////
////  Created by Siyu Xie on 1/23/16.
////  Copyright © 2016 pennapps. All rights reserved.
////
//
//import Parse
//import ParseUI
//
//class Connection{
//    let userObj = PFUser.currentUser()
//    let partyQuery = PFQuery(className:"Party")
//    let guestQuery = PFQuery(className:"Guest")
//    var partyId = ""
//    var isHost = false
//    var stateUpdating = false
//    
//    func createParty(gesture : String){
//        let userId = userObj?.objectId
//        let newParty = PFObject(className: "Party")
//        newParty["userId"]=userId;
//        newParty.saveInBackgroundWithBlock{
//            
//            (success: Bool, error: NSError?) -> Void in
//            if (success) {
//            // The object has been saved.
//            } else {
//            // There was a problem, check error.description
//            }
//        }
//    }
//    
//    func checkPartySteate(){
//        let userId = userObj?.objectId
//        let hostQuery = PFQuery(className: "Party")
//        let guestQuery = PFQuery(className: "Guest")
//        self.stateUpdating = true
//        
//        // Check whether this user is a party host
//        hostQuery.whereKey("userId", equalTo:userId!)
//        
//        hostQuery.getFirstObjectInBackgroundWithBlock{
//            (obj: PFObject?, error: NSError?) -> Void in
//            if (error != nil){
//                print ("Fetching party query failed")
//                self.stateUpdating = false
//            }
//            else{
//                if (obj != nil){
//                    self.partyId = obj!["partyId"] as! String
//                    self.isHost = true
//                    self.stateUpdating = false
//                }
//                else{
//                    guestQuery.whereKey("userId", equalTo:userId!)
//                    guestQuery.getFirstObjectInBackgroundWithBlock{
//                        (obj: PFObject? , error: NSError?) -> Void in
//                        if (error != nil){
//                            print ("Fetching guest query failed")
//                            
//                        }
//                        else{
//                            if (obj != nil){
//                                self.partyId = obj!["partyId"] as! String
//                                self.isHost = true
//                            }
//                            else{
//                                self.partyId = ""
//                                self.isHost = false
//                            }
//                        }
//                        self.stateUpdating = false
//                    }
//                }
//            }
//        }
//    }
//    
//    func joinParty(gesture : String){
//        let query = PFQuery(className: "Party")
//        query.whereKey("gesture", equalTo: gesture)
//        query.getFirstObjectInBackgroundWithBlock {
//            (obj: PFObject?, error: NSError?) -> Void in
//            if error != nil || obj == nil {
//                print("The getFirstObject request failed.")
//            } else {
//                // The find succeeded.
//                print("Successfully retrieved partyId \(obj!["partyId"]) .")
//                //                let newGuest = PFObject(className: "Guest")
//                //                newGuest["userId"] = PFUser.currentUser()?.objectId
//                //                newGuest["partyId"] = object!["partyId"]
//                //                newGuest["gesture"] = gesture
//                //                newGuest.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                //                    print("Party joined.")
//                //                }
//                let userId = PFUser.currentUser()?.objectId
//                let query = PFQuery(className : "Guest")
//                query.whereKey("userId", equalTo: userId!)
//                query.getFirstObjectInBackgroundWithBlock {
//                    (object: PFObject?, error: NSError?) -> Void in
//                    if error != nil || object == nil{
//                        let newGuest = PFObject(className: "Guest")
//                        newGuest["userId"] = userId
//                        newGuest["partyId"] = obj!["partyId"]
//                        newGuest["gesture"] = gesture
//                        newGuest.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                            print("Party joined.")
//                        }
//                        
//                        
//                    }else {
//                        // The find succeeded.
//                        print("Successfully retrieved partyId \(object!["partyId"]) .")
//                        if let object = object{
//                            object["userId"] = userId
//                            object["gesture"] = gesture
//                        }
//                        object!.saveInBackground()
//                    }
//                }
//                
//                
//            }
//        }
//    }
//    
//}