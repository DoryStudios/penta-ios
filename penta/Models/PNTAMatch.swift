//
//  PNTAMatch.swift
//  penta
//
//  Created by Andrew Brandt on 1/20/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Parse

class PNTAMatch: PFObject {

    var fromUser: PFUser? {
        set { self[PARSE_FROM_USER_KEY] = newValue }
        get { return self[PARSE_FROM_USER_KEY] as! PFUser? }
    }
    
    var toUser: PFUser? {
        set { self[PARSE_TO_USER_KEY] = newValue }
        get { return self[PARSE_TO_USER_KEY] as! PFUser? }
    }
    
    var fromUserWord: String? {
        set { self[PARSE_FROM_USER_WORD_KEY] = newValue }
        get { return self[PARSE_FROM_USER_WORD_KEY] as! String? }
    }
    
    var toUserWord: String? {
        set { self[PARSE_TO_USER_WORD_KEY] = newValue}
        get { return self[PARSE_TO_USER_WORD_KEY] as! String? }
    }
    
    var isReady: Bool {
        set { self[PARSE_MATCH_ISREADY_KEY] = newValue}
        get { return self[PARSE_MATCH_ISREADY_KEY] as! Bool }
    }
    
    var isFinished: Bool {
        set { self[PARSE_MATCH_ISFINISHED_KEY] = newValue}
        get { return self[PARSE_MATCH_ISFINISHED_KEY] as! Bool }
    }
    
    var lastGuess: PNTAGuess? {
        set { self[PARSE_MATCH_LASTGUESS_KEY] = newValue}
        get { return self[PARSE_MATCH_LASTGUESS_KEY] as! PNTAGuess? }
    }
    
    var isLocalMatch: Bool = false
    var guesses: [PNTAGuess] = []
}

extension PNTAMatch: PFSubclassing {
    static func parseClassName() -> String {
        return "Match"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        
        dispatch_once(&onceToken) { () -> Void in
            super.registerSubclass()
        }
    }
}
