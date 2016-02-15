//
//  PNTALocalMatchBehavior.swift
//  penta
//
//  Created by Andrew Brandt on 2/15/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation

class LocalMatchBehavior: NSObject {
    weak var match: PNTAMatch?
    
    var enabled: Bool = false {
        didSet {
            let center = NSNotificationCenter.defaultCenter()
            if enabled {
                center.addObserver(self, selector: Selector("submitGuess"), name: "Penta User Submit Guess", object: nil)
            } else {
                center.removeObserver(self)
            }
        }
    }
    
    init(newMatch: PNTAMatch) {
        match = newMatch
    }
    
    func submitGuess() {
        guard let match = match else {
            return
        }
        let shouldGuess = match.ownGuesses.count > match.opponentGuesses.count
        if enabled && shouldGuess && match.isLocalMatch && !match.isFinished {
            let opponentWord = WordHelper.randomWord()
            let opponentGuess = PNTAGuess()
            opponentGuess.string = opponentWord
            match.appendGuess(opponentGuess, completionBlock: { (success, error) -> (Void) in })
        }
    }
    
}