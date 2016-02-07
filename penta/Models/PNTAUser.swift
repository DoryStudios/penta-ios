//
//  PNTAUser.swift
//  penta
//
//  Created by Andrew Brandt on 2/6/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation

class PNTAUser {
    
    var imageURL: String?
    var userName: String?
    var parseUser: PFUser?
    
    var isLinkedToFacebook: Bool = false
    
    static let sharedUser = PNTAUser()
    
    init() {
        if let user = PFUser.currentUser() {
            parseUser = user
            if PFFacebookUtils.isLinkedWithUser(user) { //happy path
                isLinkedToFacebook = true
                fetchUserDetails()
                fetchUserFriends()
            } else { //likely user invalidated session in facebook
//                isLinkedToFacebook = false
            }
        }
    }
    
    
    func fetchUserDetails() {
        FacebookHelper.fetchCurrentUserProfile {
        (connection: FBSDKGraphRequestConnection?, result: AnyObject?, error: NSError?) -> Void in
            if let error = error {
                print("error fetching user details:\n\(error)")
            }
            
            if let dict = result as? NSDictionary {
                print("fetched user details:\n\(dict)")
            }
        }
    }
    
    func fetchUserFriends() {
        FacebookHelper.fetchCurrentUserFriends(false) {
        (connection: FBSDKGraphRequestConnection?, result: AnyObject?, error: NSError?) -> Void in
            if let error = error {
                print("error fetching friends:\n\(error)")
            }
            
            if let dict = result as? NSDictionary {
                print("fetched user friends:\n\(dict)")
            }
        }
    }
    
}