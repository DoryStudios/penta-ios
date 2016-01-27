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
    
    var match: PNTAMatch? {
        set { self[PARSE_GUESS_MATCH_KEY] = newValue }
        get { return self[PARSE_GUESS_MATCH_KEY] as! PNTAMatch? }
    }
    
    var string: String? {
        set { self[PARSE_STRING_GUESS_KEY] = newValue }
        get { return self[PARSE_STRING_GUESS_KEY] as! String? }
    }

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
