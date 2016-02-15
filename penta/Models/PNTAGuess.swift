//
//  PNTAGuess.swift
//  penta
//
//  Created by Andrew Brandt on 1/20/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Parse

class PNTAGuess: PFObject {

    var owner: PFUser? {
        set { self[PARSE_OWNER_GUESS_KEY] = newValue }
        get { return self[PARSE_OWNER_GUESS_KEY] as! PFUser? }
    }
    
    var string: String? {
        set { self[PARSE_STRING_GUESS_KEY] = newValue }
        get { return self[PARSE_STRING_GUESS_KEY] as! String? }
    }
    
    var guessUploadTask: UIBackgroundTaskIdentifier?
    var count = 0
    
    func ownerIsCurrentUser() -> Bool {
        if let user = PFUser.currentUser(), let userId = user.objectId, let owner = owner, let ownerId = owner.objectId {
            if userId == ownerId {
                return true
            }
        }
        return false
    }
    
    func uploadGuess() {
        
        owner = PFUser.currentUser()
        
        guessUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.guessUploadTask!)
        })
        
        saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in

            if let error = error {
                //something bad happened
                print("error: \(error.description)")
            }
            
            UIApplication.sharedApplication().endBackgroundTask(self.guessUploadTask!)
            
            if success {
                //created match successfully
                print("created guess OK")
            }
        }
    }
    
//    func checkGuess() {
//        if let string = string, let match = match {
//            var checkString: String!
//            if let fromUser = match.fromUser, let toUser = match.toUser { //unwraps when online match
//                if fromUser.madeGuess(self) {
////                    let count = WordHelper.commonCharactersForWord(string, inMatchString: match.toUserWord!)
//                    checkString = match.toUserWord!
//                } else if toUser.madeGuess(self) {
//                    checkString = match.fromUserWord!
//                }
//            } else if match.fromUser == match.toUser { //true when solo match
//                checkString = match.fromUserWord!
//            }
//            let common = WordHelper.commonCharactersForWord(string, inMatchString: checkString)
//            count = common
//        }
//    }
}

extension PNTAGuess: PFSubclassing {
    static func parseClassName() -> String {
        return "Guess"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        
        dispatch_once(&onceToken) { () -> Void in
            super.registerSubclass()
        }
    }
}
