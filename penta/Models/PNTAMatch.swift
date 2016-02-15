//
//  PNTAMatch.swift
//  penta
//
//  Created by Andrew Brandt on 1/20/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Parse

typealias PentaGuessCompletionBlock = (success: Bool, error: NSError?) -> (Void)

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
    
    var isLocalMatch: Bool = false {
        didSet {
            if isLocalMatch {
                let behavior = LocalMatchBehavior(newMatch: self)
                localMatchBehavior = behavior
            }
        }
    }
    var localMatchBehavior: LocalMatchBehavior?
    
    var guesses: [PNTAGuess] = [] {
        didSet {
            filterGuesses(guesses)
        }
    }
    
    dynamic var ownGuesses: [PNTAGuess] = []
    dynamic var opponentGuesses: [PNTAGuess] = []
    
    var matchUploadTask: UIBackgroundTaskIdentifier?
    
    func uploadMatch() {
        fromUser = PFUser.currentUser()
        isReady = false
        
        saveMatch()
    }
    
    func saveMatch() {
        matchUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.matchUploadTask!)
        })
        
        saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in

            if let error = error {
                //something bad happened
                print("error saving: \(error.description)")
            }
            
            UIApplication.sharedApplication().endBackgroundTask(self.matchUploadTask!)
            
            if success {
                //created match successfully
                print("saved match OK")
            }
            
        }
    }
    
    func fetchGuesses() {
        ParseHelper.fetchGuessesForMatch(self)  //trailing closure
        { (result: [PFObject]?, error: NSError?) -> Void in
            if let guesses = result as? [PNTAGuess] {
                self.guesses = guesses
                print("retrieved guesses")
            }
        }
    }
    
    func filterGuesses(guesses: [PNTAGuess]) {
        var own: [PNTAGuess] = []
        var opponent: [PNTAGuess] = []
        if isLocalMatch {
            for var i = 0; i < guesses.count; i++ {
                let guess = guesses[i]
                if i % 2 == 0 {
                    own.append(guess)
                } else {
                    opponent.append(guess)
                }
            }
        } else {
            for guess in guesses {
                if guess.ownerIsCurrentUser() {
                    own.append(guess)
                } else {
                    opponent.append(guess)
                }
            }
        }
        ownGuesses = own
        opponentGuesses = opponent
        print("filtered guesses")
    }
    
    func appendGuess(guess: PNTAGuess, completionBlock: PentaGuessCompletionBlock) {
        lastGuess = guess
        if isLocalMatch {
            guesses.append(guess)
            LocalMatchHelper.setMatch(self)
            completionBlock(success: true, error: nil)
        } else {
            let relationship = relationforKey("guesses")
            relationship.addObject(guess)
            saveInBackgroundWithBlock({
                (success, error) -> Void in
                if let error = error {
                    completionBlock(success: false, error: error)
                } else {
                    self.ownGuesses.append(guess)
                    completionBlock(success: true, error: nil)
                }
            })
        }
    }
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

