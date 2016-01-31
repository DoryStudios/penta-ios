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
    
}