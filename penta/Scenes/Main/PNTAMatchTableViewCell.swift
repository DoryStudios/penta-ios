//
//  PNTAMatchTableViewCell.swift
//  penta
//
//  Created by Andrew Brandt on 1/23/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import UIKit

class PNTAMatchTableViewCell: UITableViewCell {

    @IBOutlet weak var tileView: UIView!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare() {
        tileView.layer.borderColor = UIColor.blueColor().CGColor
        tileView.layer.borderWidth = 1.0
        tileView.layer.cornerRadius = 6.0
        
        tileView.backgroundColor = UIColor.whiteColor()
    }
}
