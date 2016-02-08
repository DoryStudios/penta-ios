//
//  PNTAUser.swift
//  penta
//
//  Created by Andrew Brandt on 2/6/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation

class PNTAUser: NSObject {
    
    var imageURL: String?
    var userName: String?
    var parseUser: PFUser?
    
    dynamic var isLinkedToFacebook: Bool = false
    dynamic var availableFriends: Dictionary<String, String> = [:]
    
    static let sharedUser = PNTAUser()
    
    override init() {
        super.init()
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
    
    func connectSocial() {
        ParseHelper.tryLoginViaParse { (user: PFUser?, error: NSError?) -> Void in
            print("returned from facebook connect")
            if let error = error {
                print("error occurred: \(error)")
            }
            
            if let user = user {
                print("connected user: \(user)")
                self.isLinkedToFacebook = true
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
                if let name = dict["name"] as? String {
                    self.userName = name
                }
                
                if let subdict = dict["picture"] as? NSDictionary, let data = subdict["data"] as? NSDictionary, let url = data["url"] as? String {
                    self.imageURL = url
                }
//                print("fetched user details:\n\(dict)")
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
                if let data = dict["data"] as? NSArray {
                    for friend in data {
                        if let id = friend["id"] as? String, let name = friend["name"] as? String {
                            self.availableFriends.updateValue(name, forKey: id)
                            print("added friend \(name)")
                        }
                    }
                }
//                print("fetched user friends:\n\(dict)")
            }
        }
    }
    
}