//
//  LocalMatchHelper.swift
//  penta
//
//  Created by Andrew Brandt on 1/23/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation

let PENTA_SOLO_GUESSES = "Solo Play Guesses"
let MATCH_OFFLINE_KEY = "Penta Single Player"
let MATCH_HAS_ACTIVE_OFFLINE_KEY = "Active Single Player"

struct LocalMatchHelper {

    static func hasSoloMatch() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let value = defaults.boolForKey(MATCH_HAS_ACTIVE_OFFLINE_KEY)
        return value
    }
    
    static func getMatch() -> PNTAMatch {
        let match = PNTAMatch()
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let dict = defaults.dictionaryForKey(MATCH_OFFLINE_KEY) {
            match.fromUserWord = dict[PARSE_FROM_USER_WORD_KEY] as? String
            match.toUserWord = dict[PARSE_TO_USER_WORD_KEY] as? String
            match.isLocalMatch = true
            let guesses = getGuesses()
            match.guesses = guesses
        }
        match.isLocalMatch = true
        
        return match
    }
    
    static func setMatch(match: PNTAMatch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var dict: [String: AnyObject] = [:]
        
        dict[PARSE_FROM_USER_WORD_KEY] = match.fromUserWord
        dict[PARSE_TO_USER_WORD_KEY] = match.toUserWord
        
        defaults.setBool(true, forKey: MATCH_HAS_ACTIVE_OFFLINE_KEY)
        defaults.setObject(dict, forKey: MATCH_OFFLINE_KEY)
        defaults.synchronize()
    }
    
    static func getGuesses() -> [PNTAGuess] {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let arr = defaults.arrayForKey(PENTA_SOLO_GUESSES) as? [String] ?? []
        var guesses: [PNTAGuess] = []
        
        for word in arr {
            let guess = PNTAGuess()
//            guess.owner = PFUser.currentUser()
            guess.string = word
            guesses.append(guess)
        }
        
        return guesses
    }
    
    static func setGuesses(guesses: [PNTAGuess]) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var arr: [String] = []
        
        for guess in guesses {
            let word = guess.string!
            arr.append(word)
        }
        
        defaults.setObject(arr, forKey: PENTA_SOLO_GUESSES)
        defaults.synchronize()
    }
    
}