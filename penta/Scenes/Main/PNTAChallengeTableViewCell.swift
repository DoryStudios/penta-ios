//
//  PNTAChallengeTableViewCell.swift
//  penta
//
//  Created by Andrew Brandt on 2/6/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import UIKit

class PNTAChallengeTableViewCell: UITableViewCell {

    @IBOutlet weak var challengerName: UILabel!
    @IBOutlet weak var challengerImage: UIImageView!
    
    var imageUrl: String! {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func didPressChallenge(sender: AnyObject) {
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
