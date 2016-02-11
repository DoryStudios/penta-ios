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

typealias PentaFacebookImageRequestHandler = (image: UIImage?, error: NSError?) -> (Void)

struct FacebookHelper {
    
    static func fetchCurrentUserProfile(completionBlock: FBSDKGraphRequestHandler) {
        let parameters = ["fields":"id, name, picture"]
        let request = FBSDKGraphRequest(graphPath: "/me", parameters: parameters)
        
        request.startWithCompletionHandler(completionBlock)
    }
    
    static func fetchCurrentUserFriends(hasInstalled: Bool, completionBlock: FBSDKGraphRequestHandler) {
        var parameters = [:] as [NSObject: AnyObject]
        if hasInstalled {
            parameters = ["fields":"name, installed, picture"]
        } else {
            parameters = ["fields":"name"]
        }

        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: parameters)
        request.startWithCompletionHandler(completionBlock)
    }
    
    static func fetchUserProfileWithId(id: String, completionBlock: PentaFacebookImageRequestHandler) {
//        fetchCurrentUserProfile { (connnection, result, error) -> Void in
//            if let error = error {
//                print("error:\n\(error)")
//            }
//            
//            if let token = result.valueForKey("id") as? String {
//                let url = NSURL(string: "https://graph.facebook.com/\(id)/picture")
//                let request = NSURLRequest(URL: url!)
//                let session = NSURLSession.sharedSession()
//                let task = session.dataTaskWithRequest(request, completionHandler: {
//                    (data, response, error) -> Void in
//                    
//                    if let response = response as? NSHTTPURLResponse {
//                        print("http response code: \(response.statusCode)")
//                        print("http response url: \(response.URL)")
//                    }
//                    
////                    if let data = data {
////                        print("\(data)")
////                        let image = UIImage(data: data)
////                        completionBlock(image: image, error: nil)
////                    }
//                    
//                    if let error = error {
//                        print("error:\n\(error)")
//                        completionBlock(image: nil, error: error)
//                    }
//                })
//                task.resume()
//            }
//        }
        let url = NSURL(string: "https://graph.facebook.com/\(id)/picture")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            if let error = error {
                print("error:\n\(error)")
                completionBlock(image: nil, error: error)
            } else if let response = response as? NSHTTPURLResponse, let url = response.URL {
                print("http response code: \(response.statusCode)")
                print("http response url: \(url)")
                let imageRequest = NSURLRequest(URL: url)
                let newTask = session.dataTaskWithRequest(imageRequest, completionHandler: {
                    (data, response, error) -> Void in
                    if let error = error {
                        completionBlock(image: nil, error: error)
                    } else if let data = data, let image = UIImage(data: data) {
                        completionBlock(image: image, error: nil)
                    }
                })
                newTask.resume()
            }
            
        })
        task.resume()
    }
}