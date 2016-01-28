//
//  PNTAMenuHeaderTableViewCell.swift
//  penta
//
//  Created by Andrew Brandt on 1/20/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import UIKit

class PNTAMenuHeaderTableViewCell: UITableViewCell {

    var callToAction: Bool = false {
        didSet {
            if (callToAction) {
                actionButton.setTitle("Facebook Connect", forState: .Normal)
            } else {
            
            }
        }
    }
    @IBOutlet weak var actionButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
