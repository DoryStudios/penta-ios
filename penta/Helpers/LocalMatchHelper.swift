//
//  LocalMatchHelper.swift
//  penta
//
//  Created by Andrew Brandt on 1/23/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation

let PENTA_SOLO_GUESSES = "Solo Play Guesses"
let PENTA_SOLO_MATCHES = "Penta Solo Matches"
let PENTA_OFFLINE_MATCH_ID = "Penta Match Offline ID"

let MATCH_OFFLINE_KEY = "Penta Single Player"

let MATCH_HAS_ACTIVE_OFFLINE_KEY = "Active Single Player"

struct LocalMatchHelper {

    static func hasSoloMatch() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let value = defaults.boolForKey(MATCH_HAS_ACTIVE_OFFLINE_KEY)
        return value
    }
    
    static func clearMatch() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(MATCH_OFFLINE_KEY)
        defaults.removeObjectForKey(PENTA_SOLO_GUESSES)
        defaults.setBool(false, forKey: MATCH_HAS_ACTIVE_OFFLINE_KEY)
        defaults.synchronize()
    }
    
    static func newMatch() -> PNTAMatch {
        let match = PNTAMatch()
        match.isLocalMatch = true
        match.isFinished = false
        match.objectId = NSUUID().UUIDString
        return match
    }
    
    static func getMatchById(uuid: String) -> PNTAMatch {
        let match = PNTAMatch()
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let dict = defaults.dictionaryForKey(uuid) {
            match.fromUserWord = dict[PARSE_FROM_USER_WORD_KEY] as? String
            match.toUserWord = dict[PARSE_TO_USER_WORD_KEY] as? String
            match.isLocalMatch = true
            match.isFinished = dict[PARSE_MATCH_ISFINISHED_KEY] as? Bool ?? false
            match.objectId = uuid
            match.guesses = []
            
            if let arr = dict["Guesses"] as? [String] {
                for word in arr {
                    let guess = PNTAGuess()
                    guess.string = word
                    match.guesses.append(guess)
                }
            }
//            let guesses = getGuesses()
//            match.guesses = guesses
        }
        
        if match.guesses.count > 0 {
            match.lastGuess = match.guesses.last
        }
        
        return match
    }
    
    static func setMatch(match: PNTAMatch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var dict: [String: AnyObject] = [:]
        
        if let uuid = match.objectId {
            dict[PARSE_FROM_USER_WORD_KEY] = match.fromUserWord
            dict[PARSE_TO_USER_WORD_KEY] = match.toUserWord
            dict[PARSE_MATCH_ISFINISHED_KEY] = match.isFinished
            
            var arr: [String] = []
            for guess in match.guesses {
                let string = guess.string
                arr.append(string!)
            }
            dict["Guesses"] = arr
            
            defaults.setBool(true, forKey: MATCH_HAS_ACTIVE_OFFLINE_KEY)
            defaults.setObject(dict, forKey: uuid)
            defaults.synchronize()
            
            let matchStrings = defaults.arrayForKey(PENTA_SOLO_MATCHES) as? [String] ?? []
            if !matchStrings.contains(uuid) {
                var newStrings = Array(matchStrings)
                newStrings.append(uuid)
                defaults.setObject(newStrings, forKey: PENTA_SOLO_MATCHES)
            }
        }
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
    
    static func fetchMatches() -> [PNTAMatch] {
        var matches: [PNTAMatch] = []
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let matchStrings = defaults.arrayForKey(PENTA_SOLO_MATCHES) as? [String] {
            for string in matchStrings {
                let match = getMatchById(string)
                matches.append(match)
            }
        }
        
        return matches
    }
    
}