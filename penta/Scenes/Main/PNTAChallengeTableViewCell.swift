//
//  PNTAChallengeTableViewCell.swift
//  penta
//
//  Created by Andrew Brandt on 2/6/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import UIKit

let ISSUE_CHALLENGE = "Penta New Online Game"

class PNTAChallengeTableViewCell: UITableViewCell {

    @IBOutlet weak var challengerName: UILabel!
    @IBOutlet weak var challengerImage: UIImageView!
    
    var friend: PNTAFriend! {
        didSet {
            challengerName.text = friend.name
            FacebookHelper.fetchUserProfileWithId(friend.socialID) { (image, error) -> (Void) in
                if let image = image {
                    print("downloaded image")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.challengerImage.layer.cornerRadius = 8.0
                        self.challengerImage.image = image
                    })
                } else if let error = error {
                    print("error:\n\(error)")
                }
            }
        }
    }
    
    var imageUrl: String! {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func didPressChallenge(sender: AnyObject) {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(ISSUE_CHALLENGE, object: friend)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
