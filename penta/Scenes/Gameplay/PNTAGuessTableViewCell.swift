//
//  PNTAGuessTableViewCell.swift
//  penta
//
//  Created by Andrew Brandt on 1/24/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import UIKit

class PNTAGuessTableViewCell: UITableViewCell {
    
    var guess: PNTAGuess! {
        didSet {
            if let string = guess.string {
                guessLabel.text = "\(string)"
            }
        }
    }
    
    var count = 0 {
        didSet {
            guessCountLabel.text = "\(count)"
            if let image = UIImage(named: "penta-\(count)-small") {
                guessIndicator.image = image
            }
        }
    }

    @IBOutlet weak var guessIndicator: UIImageView!
    @IBOutlet weak var guessLabel: UILabel!
    @IBOutlet weak var guessCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
