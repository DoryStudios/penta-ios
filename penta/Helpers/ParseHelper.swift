//
//  ParseHelper.swift
//  WordMaster
//
//  Created by Andrew Brandt on 8/23/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation
import Parse

protocol ParseHelperDelegate {
    func retrievedMatchResults(matches: [PNTAMatch])
}

let PARSE_MATCH_CLASS = "Match"
let PARSE_GUESS_CLASS = "Guess"
let PARSE_USER_CLASS = "User"

let PARSE_FROM_USER_KEY = "fromUser"
let PARSE_TO_USER_KEY = "toUser"

let PARSE_FROM_USER_WORD_KEY = "fromUserWord"
let PARSE_TO_USER_WORD_KEY = "toUserWord"

let PARSE_GUESS_MATCH_KEY = "match"

let PARSE_OWNER_GUESS_KEY = "owner"
let PARSE_STRING_GUESS_KEY = "string"

let PARSE_USERNAME_KEY = "username"
let PARSE_TOTAL_MATCHES_KEY = "totalMatches"

let PARSE_USER_UPDATED_KEY = "updatedAt"
let PARSE_MATCH_ISREADY_KEY = "isReady"
let PARSE_MATCH_ISFINISHED_KEY = "isFinished"
let PARSE_MATCH_LASTGUESS_KEY = "lastGuess"

class ParseHelper: NSObject {
    
    var delegate: ParseHelperDelegate?
    
    static func fetchMatchesForUser(user: PFUser, includeFinished include: Bool, completionBlock: PFArrayResultBlock) {
        let fromUserQuery = PFQuery(className: PARSE_MATCH_CLASS)
        fromUserQuery.whereKey(PARSE_FROM_USER_KEY, equalTo: user)
        if !include {
        fromUserQuery.whereKey(PARSE_MATCH_ISFINISHED_KEY, equalTo: false)
        }
//        fromUserQuery.includeKey(PARSE_MATCH_LASTGUESS_KEY)

        let toUserQuery = PFQuery(className: PARSE_MATCH_CLASS)
        toUserQuery.whereKey(PARSE_TO_USER_KEY, equalTo: user)
        if !include {
        toUserQuery.whereKey(PARSE_MATCH_ISFINISHED_KEY, equalTo: false)
        }
//        toUserQuery.includeKey(PARSE_MATCH_LASTGUESS_KEY)
        
        let mainQuery = PFQuery.orQueryWithSubqueries([fromUserQuery, toUserQuery])
        mainQuery.includeKey(PARSE_MATCH_LASTGUESS_KEY)
        
        mainQuery.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func fetchGuessesForMatch(match: PNTAMatch, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: PARSE_GUESS_CLASS)
        
        query.whereKey(PARSE_GUESS_MATCH_KEY, equalTo: match)
        //query.includeKey(PARSE_STRING_GUESS_KEY)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func fetchRandomUsers(completionBlock: PFArrayResultBlock) {
        
        if let query = PFUser.query() {
            
            query.orderByAscending(PARSE_USER_UPDATED_KEY)
        
            query.findObjectsInBackgroundWithBlock(completionBlock)
            
        }
    }
    
   
}
