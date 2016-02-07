//
//  FacebookHelper.swift
//  penta
//
//  Created by Andrew Brandt on 2/6/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

struct FacebookHelper {
    
    static func fetchCurrentUserProfile(completionBlock: FBSDKGraphRequestHandler) {
        let parameters = ["fields":"id, name, picture"]
        let request = FBSDKGraphRequest(graphPath: "/me", parameters: parameters)
        
        request.startWithCompletionHandler(completionBlock)
    }
    
    static func fetchCurrentUserFriends(hasInstalled: Bool, completionBlock: FBSDKGraphRequestHandler) {
        var parameters = [:] as [NSObject: AnyObject]
        if hasInstalled {
            parameters = ["fields":"name, installed"]
        } else {
            parameters = ["fields":"name"]
        }

        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: parameters)
        
        request.startWithCompletionHandler(completionBlock)
    }
}