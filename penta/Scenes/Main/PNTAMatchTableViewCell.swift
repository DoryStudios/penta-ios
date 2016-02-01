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
    @IBOutlet weak var lastGuessLabel: UILabel!
    
    var match: PNTAMatch! {
        didSet {
            if let match = match {
                if match.isLocalMatch {
                    opponentNameLabel.text = "Computer"
                } else {
                    //determine correct user, grab name
                }
                
                if let lastGuess = match.lastGuess {
                    lastGuessLabel.text = "last guess \(lastGuess.string!)"
                }
                
            }
        }
    }
    
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
