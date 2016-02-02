//
//  WordHelper.swift
//  penta
//
//  Created by Andrew Brandt on 1/24/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation

struct WordHelper {
    
    static func isWordValid(word: String) -> Bool {
        print("checking \(word)")
        
        if word.characters.count != 5 {
            print("invalid length")
            return false
        }
        
        let letters = NSCharacterSet.letterCharacterSet()
        for char in word.unicodeScalars {
            if !letters.longCharacterIsMember(char.value) {
                print("invalid character")
                return false
            }
        }
        
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        if let _ = word.rangeOfCharacterFromSet(whitespace) {
            return false
        }
        
        let dictionary = Lexicontext.sharedDictionary()
        if !dictionary.containsDefinitionFor(word.lowercaseString) {
            print("no definition")
            return false
        }
        
        for char in word.characters {
            if word.componentsSeparatedByString(String(char)).joinWithSeparator("").characters.count < 4 {
                print("duplicate letters")
                return false
            }
        }
        
        print("\(word) acceptable")
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
        var words: [String] = []
        let index = characterStrengthIndexFromGuesses(guesses)
        
        
        
        return words
    }
    
    static func possibleCharactersFromGuesses(guesses: [PNTAGuess]) -> [Character] {
        var characters: [Character] = []
        let index = characterStrengthIndexFromGuesses(guesses)
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
        var characters: [Character] = []
        let index = characterStrengthIndexFromGuesses(guesses)
        let set = NSMutableCharacterSet.uppercaseLetterCharacterSet()
        let usedSet = NSCharacterSet(charactersInString: String(index.keys))
        set.formIntersectionWithCharacterSet(usedSet.invertedSet)
//        characters = Array(set.)
        return characters
    }
    
    static func avoidCharactersFromGuesses(guesses: [PNTAGuess]) -> [Character] {
        var characters: [Character] = []
        let index = characterStrengthIndexFromGuesses(guesses)
        
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
                        let newStrength = strength+value*value
                        characters.updateValue(newStrength, forKey: char)
                    } else {
                        characters.updateValue(value, forKey: char)
                    }
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