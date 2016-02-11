//
//  PNTAUser.swift
//  penta
//
//  Created by Andrew Brandt on 2/6/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import Foundation

let FACEBOOK_TOKEN = "Penta Facebook Token"

class PNTAUser: NSObject {
    
    var imageURL: String?
    var userName: String?
    var parseUser: PFUser?
    
    dynamic var isLinkedToFacebook: Bool = false
    dynamic var availableFriends: [PNTAFriend] = []
    
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
                let defaults = NSUserDefaults.standardUserDefaults()
//                defaults.setObject(, forKey: <#T##String#>)
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
                    var arr: [PNTAFriend] = []
                    for friend in data {
                        if let id = friend["id"] as? String, let name = friend["name"] as? String {
                            let friend = PNTAFriend(name: name, socialID: id)
                            arr.append(friend)
                            print("added friend \(name)")
                        }
                    }
                    self.availableFriends = arr
                }
//                print("fetched user friends:\n\(dict)")
            }
        }
    }
}

class PNTAFriend: NSObject {
    var name: String
    var socialID: String
    
    init(name: String, socialID: String) {
        self.name = name
        self.socialID = socialID
    }
}