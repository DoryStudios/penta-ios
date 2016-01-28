//
//  PNTAWordSelectorView.swift
//  penta
//
//  Created by Andrew Brandt on 1/23/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import UIKit

enum PNTAWordSelectorViewState {
    case Idle, Animating
}

protocol PNTAWordSelectorViewDelegate {
    func wordSelector(selector: PNTAWordSelectorView, didFinishWithSuccess success: Bool)
    func wordSelector(selector: PNTAWordSelectorView, shouldFinishWithWord word: String) -> Bool
}

class PNTAWordSelectorView: UIView {

    let LABEL_TAG_OFFSET = 10
    let CONTAINER_TAG_OFFSET = 20
    
    var labels: [UILabel] = []
    var containers: [UIView] = []
    
    var activeIndex: Int = 0
    var word: String = ""
    var potentialMatch: PNTAMatch!
    
    var state: PNTAWordSelectorViewState = .Idle
    var delegate: PNTAWordSelectorViewDelegate?

    @IBOutlet weak var blindField: UITextField!
    
    @IBAction func didPressFinish(sender: AnyObject) {
        let word = buildWord()
        let shouldFinish = delegate?.wordSelector(self, shouldFinishWithWord: word) ?? false
        
        if shouldFinish {
            delegate?.wordSelector(self, didFinishWithSuccess: true)
        }
    }

    @IBAction func didPressDismiss(sender: AnyObject) {
        delegate?.wordSelector(self, didFinishWithSuccess: false)
    }
    
    @IBAction func didPressRandom(sender: AnyObject) {
    }
    func prepare() {
        blindField.delegate = self
        
        for var i = 0; i < 15; i++ {
            var tag = i + LABEL_TAG_OFFSET
            if let label = viewWithTag(tag) as? UILabel {
                labels.append(label)
            }
            
            tag = i + CONTAINER_TAG_OFFSET
            if let view = viewWithTag(tag) {
                containers.append(view)
                let tap = UITapGestureRecognizer(target: self, action: Selector("selectContainer:"))
                view.addGestureRecognizer(tap)
            }
        }
        
        containers[0].backgroundColor = UIColor.lightGrayColor()
    }
    
    func buildWord() -> String {
        var word = ""
        for var i = 0; i < 5; i++ {
            let label = labels[i]
            word.append((label.text?.characters.first)!)
        }
        return word
    }
    
    func updateBlindField() {
        if let string = blindField.text?.uppercaseString, let character = string.characters.last {
            let label = labels[activeIndex]
            label.text = "\(character)"
            blindField.text = "\(character)"
            updateActiveContainer(activeIndex, increment: true)
        }
    }
    
    func updateActiveContainer(index: Int, increment: Bool) {
        containers[activeIndex].backgroundColor = UIColor.groupTableViewBackgroundColor()
        activeIndex = index
        if increment {
            activeIndex++
            activeIndex = activeIndex % 5
        }
        containers[activeIndex].backgroundColor = UIColor.lightGrayColor()
    }
    
    func selectContainer(sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            let index = tag % CONTAINER_TAG_OFFSET
            updateActiveContainer(index, increment: false)
        }
    }
    
    func animateCenterToPoint(point: CGPoint, enableEntry enabled: Bool) {
        let center = NSNotificationCenter.defaultCenter()
        if enabled {
            self.blindField.becomeFirstResponder()
            center.addObserver(self, selector: Selector("updateBlindField"), name: UITextFieldTextDidChangeNotification, object: nil)
        } else {
            self.blindField.resignFirstResponder()
            center.removeObserver(self)
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.center = point
            }) { (success) -> Void in
            if success && enabled {
                
            } else if success {
                
            }
        }
    }
}

extension PNTAWordSelectorView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let word = buildWord()
        
//        delegate?.wordSelector(self, shouldFinishWithWord: word)
        let isValid = WordHelper.isWordValid(word)
        if isValid {
            self.word = word
            delegate?.wordSelector(self, didFinishWithSuccess: true)
        }
        
        return true
    }
}