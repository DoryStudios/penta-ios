//
//  AdHelper.swift
//  penta
//
//  Created by Andrew Brandt on 2/2/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation

struct AdHelper {

    static let AD_COUNTER_KEY = "Penta Ad Counter"
    
    static func shouldServeAd() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        var counter = defaults.integerForKey(AD_COUNTER_KEY)
        
        if counter < 0 {
            counter = 0
        }
        
        counter++
        defaults.setInteger(counter, forKey: AD_COUNTER_KEY)
        defaults.synchronize()
        
        let num = Int(rand()) % counter
        if num > 3 && ALInterstitialAd.isReadyForDisplay() {
            return true
        } else {
            return false
        }
    }
    
    static func serveInterstitialAd() {
        ALInterstitialAd.show()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(0, forKey: AD_COUNTER_KEY)
    }
}