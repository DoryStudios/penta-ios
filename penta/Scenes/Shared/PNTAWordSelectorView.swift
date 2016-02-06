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

    @IBOutlet weak var containerTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var helpContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var blindField: UITextField!
    @IBOutlet weak var selectorContainer: UIView!
    
    @IBAction func didPressFinish(sender: AnyObject) {
        let word = buildWord()
        let shouldFinish = delegate?.wordSelector(self, shouldFinishWithWord: word) ?? false
        
        if shouldFinish {
            self.word = word
            delegate?.wordSelector(self, didFinishWithSuccess: true)
        }
    }

    @IBAction func didPressDismiss(sender: AnyObject) {
        delegate?.wordSelector(self, didFinishWithSuccess: false)
    }
    
    @IBAction func didPressRandom(sender: AnyObject) {
        let word = WordHelper.randomWord()
        let chars = Array(word.uppercaseString.characters)
        for var i = 0; i < chars.count; i++ {
            let label = labels[i]
            let char = chars[i]
            label.text = "\(char)"
        }
        
//        helpContainerHeightConstraint.constant = 40
//        UIView.animateWithDuration(0.3) { () -> Void in
//            self.layoutIfNeeded()
//        }
    }
    
    func prepare() {
        blindField.delegate = self
        
        helpContainerHeightConstraint.constant = 0
        containerTopLayoutConstraint.constant = selectorContainer.frame.size.height * -1.5
        layoutIfNeeded()
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("updateBlindField"), name: UITextFieldTextDidChangeNotification, object: nil)
        
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
        
        selectorContainer.layer.borderWidth = 1.0
        selectorContainer.layer.borderColor = UIColor.groupTableViewBackgroundColor().CGColor
        selectorContainer.layer.cornerRadius = 8.0
    }
    
    func show() {
        containerTopLayoutConstraint.constant = 50
        hidden = false
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.layoutIfNeeded()
            }) { (success) -> Void in
            if success {
                self.blindField.text = " "
                self.blindField.becomeFirstResponder()
            }
        }
    }
    
    func hide() {
        if blindField.isFirstResponder() {
            blindField.resignFirstResponder()
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        
        containerTopLayoutConstraint.constant = selectorContainer.frame.size.height * -1.5
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.layoutIfNeeded()
            }) { (success) -> Void in
            if success {
                self.hidden = true
            }
        }
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
        } else {
            print("probably backspace")
            var newIndex = activeIndex - 1
            if newIndex < 0 {
                newIndex += 5
            }
            updateActiveContainer(newIndex, increment: false)
            blindField.text = " "
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
                self.removeFromSuperview()
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