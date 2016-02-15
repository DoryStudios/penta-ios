//
//  WordHelper.swift
//  penta
//
//  Created by Andrew Brandt on 1/24/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation

enum PNTAWordStrategy {
    case Random, Unused, Calculated
}

struct WordHelper {
    
    static func isWordValid(word: String) -> Bool {
//        print("checking \(word)")
        
        if word.characters.count != 5 {
//            print("invalid length")
            return false
        }
        
        let letters = NSCharacterSet.letterCharacterSet()
        for char in word.unicodeScalars {
            if !letters.longCharacterIsMember(char.value) {
//                print("invalid character")
                return false
            }
        }
        
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        if let _ = word.rangeOfCharacterFromSet(whitespace) {
            return false
        }
        
        let dictionary = Lexicontext.sharedDictionary()
        do {
            let hasDefinition = try dictionary.containsDefinitionFor(word.lowercaseString)
            if !hasDefinition {
    //            print("no definition")
                return false
            }
        } catch {
            print("caught an exception for \(word)")
            return false
        }
        
        for char in word.characters {
            if word.componentsSeparatedByString(String(char)).joinWithSeparator("").characters.count < 4 {
//                print("duplicate letters")
                return false
            }
        }
        
//        print("\(word) acceptable")
        return true
    }
    
    static func randomWord() -> String {
//        let bundle = NSBundle.mainBundle()
//        var string = "PENTA"
//        if let path = bundle.pathForResource("dict", ofType: "plist"), let array = NSArray(contentsOfFile: path) {
//            let count = Float(array.count)
//            let index = Int(random()%array.count)
//            string = array[index] as! String
//        }
        
        var string = ""
        let dictionary = Lexicontext.sharedDictionary()
        while !isWordValid(string) {
            string = dictionary.randomWord()
        }
        return string.uppercaseString
    }
    
    static func commonCharactersForWord(guess: String, inMatchString match: String) -> Int {
        let result = match.characters.map { (char) -> String in
            var out = ""
            if guess.characters.contains(char) {
                out = String(char)
            }
            return out
        }
        
        return result.joinWithSeparator("").characters.count
    }
    
    static func calculateWordStrength(word: String, fromIndex index: Dictionary<Character, Int>) -> Int {
        var strength = 0
        for char in word.characters {
            if let value = index[char] {
                strength += value
            }
        }
        return strength
    }
    
    static func possibleWordsFromGuesses(guesses: [PNTAGuess]) -> [String] {
        let index = characterStrengthIndexFromGuesses(guesses)
        return possibleWordsFromIndex(index)
//        var words: [String] = []
//        var localMax = 0
//        
//        for var i = 0; i < 10; i++ {
//            let word = randomWord()
//            let strength = calculateWordStrength(word, fromIndex: index)
//            if strength > localMax {
//                localMax = strength
//            }
//        }
//        
//        var count = 0
//        while words.count < 2 || count < 25 {
//            let word = randomWord()
//            let strength = calculateWordStrength(word, fromIndex: index)
//            if strength > localMax {
//                words.append(word)
//            }
//            count++
//        }
//        
//        return words
    }
    
    static func possibleWordsFromIndex(index: Dictionary<Character, Int>) -> [String] {
        return possibleWordsFromIndex(index, usingStrategy: .Calculated)
//        var localMax = 0
//        var words: [String] = []
//        
//        for var i = 0; i < 10; i++ {
//            let word = randomWord()
//            let strength = calculateWordStrength(word, fromIndex: index)
//            if strength > localMax {
//                localMax = strength
//            }
//        }
//        
//        var count = 0
//        while words.count < 2 || count < 25 {
//            let word = randomWord()
//            let strength = calculateWordStrength(word, fromIndex: index)
//            if strength > localMax {
//                words.append(word)
//            }
//            count++
//        }
//        
//        return words
    }
    
    static func possibleWordsFromIndex(index: Dictionary<Character, Int>, usingStrategy strategy: PNTAWordStrategy) -> [String] {
        var words: [String] = []
        switch strategy {
            case .Random:
                print("random")
                while words.count < 3 {
                    let word = randomWord()
                    if !words.contains(word) {
                        words.append(word)
                    }
                }
                break
            case .Unused:
                print("unused")
                var count = 0
                let unusedCharacters = unusedCharactersFromIndex(index)
                while words.count < 2 {
                    let word = randomWord()
                    var unusedCount = 0
                    for char in word.characters {
                        if unusedCharacters.contains(char) {
                            unusedCount++
                        }
                    }
                    if unusedCount > 3 {
                        words.append(word)
                    } else {
                        count++
                    }
                }
                break
            case .Calculated:
                print("calculated")
                var localMax = 0
                
                for var i = 0; i < 10; i++ { //generate local max word strength
                    let word = randomWord()
                    let strength = calculateWordStrength(word, fromIndex: index)
                    if strength > localMax {
                        localMax = strength
                    }
                }
                
                var count = 0
                while words.count < 2 { //pick words that beat local max
                    let word = randomWord()
                    let strength = calculateWordStrength(word, fromIndex: index)
                    if strength > localMax {
                        words.append(word)
                    }
                    count++
                }
                break
        }
        print("generated \(words.count) word")
        return words
    }
    
    static func possibleCharactersFromGuesses(guesses: [PNTAGuess]) -> [Character] {
        let index = characterStrengthIndexFromGuesses(guesses)
        return possibleCharactersFromIndex(index)
//        var characters: [Character] = []
//        let average = averageStrengthOfIndex(index)
//        
//        for char in index.keys {
//            if let value = index[char] {
//                let factor = Float(value)/average
//                if factor < 8 && factor > 0.2  {
//                    characters.append(char)
//                }
//            }
//        }
//        
//        return characters
    }
    
    static func possibleCharactersFromIndex(index: Dictionary<Character, Int>) -> [Character] {
        var characters: [Character] = []
        let average = averageStrengthOfIndex(index)
        
        for char in index.keys {
            if let value = index[char] {
                let factor = Float(value)/average
                if factor < 8 && factor > 0.2  {
                    characters.append(char)
                }
            }
        }
        
        return characters
    }
    
    static func unusedCharactersFromGuesses(guesses: [PNTAGuess]) -> [Character] {
        let index = characterStrengthIndexFromGuesses(guesses)
        return unusedCharactersFromIndex(index)
//        var characters: [Character] = []
//        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
//        
//        for char in letters.characters {
//            if index.indexForKey(char) == nil {
//                characters.append(char)
//            }
//        }
//        
//        return characters
    }
    
    static func unusedCharactersFromIndex(index: Dictionary<Character, Int>) -> [Character] {
        var characters: [Character] = []
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        for char in letters.characters {
            if index.indexForKey(char) == nil {
                characters.append(char)
            }
        }
        
        return characters
    }
    
    static func avoidCharactersFromGuesses(guesses: [PNTAGuess]) -> [Character] {
        let index = characterStrengthIndexFromGuesses(guesses)
        return avoidCharactersFromIndex(index)
//        var characters: [Character] = []
//        
//        for char in index.keys {
//            if let value = index[char] {
//                if value == 0 {
//                    characters.append(char)
//                }
//            }
//        }
//        return characters
    }
    
    static func avoidCharactersFromIndex(index: Dictionary<Character, Int>) -> [Character] {
        var characters: [Character] = []
        
        for char in index.keys {
            if let value = index[char] {
                if value == 0 {
                    characters.append(char)
                }
            }
        }
        return characters
    }
    
    static func characterStrengthIndexFromGuesses(guesses: [PNTAGuess]) -> Dictionary<Character, Int> {
        var characters: Dictionary<Character, Int> = [:]
        
        for guess in guesses {
            let value = guess.count
            if let word = guess.string {
                for char in word.characters {
                    if let strength = characters[char] {
                        if strength > 0 && value > 0 {
                            let newStrength = strength+(value*value)
                            characters.updateValue(newStrength, forKey: char)
                        } else if strength == 0 || value == 0 {
                            characters.updateValue(0, forKey: char)
                        }
                    } else {
                        characters.updateValue(value*value, forKey: char)
                    }
//                    print("processed \(char) at \(value): \(characters)")
                }
            }
        }
        
        return characters
    }
    
    static func updateIndex(index: Dictionary<Character, Int>, withGuess guess:PNTAGuess) -> Dictionary<Character, Int> {
        var newIndex = index
        
        let value = guess.count
        if let word = guess.string {
            for char in word.characters {
                if let strength = newIndex[char] {
                    let newStrength = (strength+value)*strength
                    newIndex.updateValue(newStrength, forKey: char)
                } else {
                    newIndex.updateValue(value, forKey: char)
                }
            }
        }
        
        return newIndex
    }
    
    static func averageStrengthOfIndex(index: Dictionary<Character, Int>) -> Float {
        var strength = 0
        for value in index.values {
            strength += value
        }
        let average = Float(strength/index.keys.count)
        return average
    }
    
}