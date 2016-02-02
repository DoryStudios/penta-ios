//
//  PNTAMatchEndView.swift
//  penta
//
//  Created by Andrew Brandt on 2/2/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import UIKit

protocol PNTAMatchEndViewDelegate {
    
    func matchEndViewShouldFinish(view: PNTAMatchEndView) -> Bool
    func matchEndViewDidFinish(view: PNTAMatchEndView)
    
}

class PNTAMatchEndView: UIView {

    @IBOutlet weak var containerView: UIView!
    
    var delegate: PNTAMatchEndViewDelegate?
    
    func prepare() {
        containerView.center = CGPointMake(center.x, center.y*3)
        containerView.layer.borderColor = UIColor.groupTableViewBackgroundColor().CGColor
        containerView.layer.borderWidth = 1.0
    }
    
    func appear() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.containerView.center = self.center
            self.backgroundColor = UIColor(white: 0.2, alpha: 0.4)
            }) { (finished) -> Void in
                if finished {
                    let tap = UITapGestureRecognizer(target: self, action: Selector("hide"))
                    self.addGestureRecognizer(tap)
                }
        }
    }
    
    func hide() {
        let shouldHide = delegate?.matchEndViewShouldFinish(self) ?? false
        
        if shouldHide {
            let newCenter = CGPointMake(center.x, center.y*3)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.containerView.center = newCenter
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
                }, completion: { (finished) -> Void in
                    if finished {
                        self.delegate?.matchEndViewDidFinish(self)
                    }
            })
        }
    }
}
