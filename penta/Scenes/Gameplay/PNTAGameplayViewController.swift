//
//  PNTAGameplayViewController.swift
//  penta
//
//  Created by Andrew Brandt on 1/20/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import UIKit

class PNTAGameplayViewController: UIViewController {

    @IBOutlet weak var opponentTable: UITableView!
    @IBOutlet weak var playerTable: UITableView!
    
    @IBOutlet weak var opponentContainer: UIView!
    @IBOutlet weak var playerContainer: UIView!
    
    @IBOutlet weak var playerWordLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerImage: UIImageView!
    
    @IBOutlet weak var opponentNameLabel: UILabel!
    @IBOutlet weak var opponentImage: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    
    var match: PNTAMatch! {
        didSet {
            for var i = 0; i < match.guesses.count; i++ {
                let guess = match.guesses[i]
                if match.isLocalMatch {
                    if i % 2 == 0 {
                        playerGuesses.append(guess)
                    } else {
                        opponentGuesses.append(guess)
                    }
                } else { //compare PFUser
                
                }
            }
            self.isLocalMatch = match.isLocalMatch
        }
    }
    
    var playerGuesses: [PNTAGuess] = []
    var opponentGuesses: [PNTAGuess] = []
    
    var wordSelector: PNTAWordSelectorView?
    
    var isLocalMatch: Bool = false
    
    func pushGuess(guess: PNTAGuess) {
        match.guesses.append(guess)
        playerGuesses.append(guess)
        playerTable.reloadData()

        let indexPath = NSIndexPath(forRow: playerGuesses.count-1, inSection: 0)
        playerTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        
        if isLocalMatch {
            let opponentWord = WordHelper.randomWord()
            let opponentGuess = PNTAGuess()
            opponentGuess.string = opponentWord
            match.guesses.append(opponentGuess)
            opponentGuesses.append(opponentGuess)
            opponentTable.reloadData()
            LocalMatchHelper.setGuesses(match.guesses)
        } else { //submit online
            if let match = match, let user = PFUser.currentUser() {
                guess.match = match
                guess.owner = user
                guess.uploadGuess()
                //pop gameplay scene?
            }
        }
    }
    
    func addGuess(guess: PNTAGuess, toTable table:UITableView) {
        
    }
    
    func showWordSelector() {
        if wordSelector == nil {
            let nibs = NSBundle.mainBundle().loadNibNamed("PNTAWordSelectorView", owner: self, options: nil)
            if nibs.count > 0 {
                if let selector = nibs[0] as? PNTAWordSelectorView {
                    let rect = CGRectMake(0, 0, view.frame.size.width*0.9, view.frame.size.height*0.4)
                    let center = CGPointMake(view.center.x, view.frame.size.height*1.2)
                    selector.bounds = rect
                    selector.center = center
//                    view.addSubview(selector)
                    selector.prepare()
                    selector.delegate = self
                    wordSelector = selector
                }
            }
        }
        
        if let selector = wordSelector {
            view.addSubview(wordSelector!)
            selector.potentialMatch = match
            let point = CGPointMake(view.center.x, view.center.y*0.5)
            selector.animateCenterToPoint(point, enableEntry: true)
        }
    }
    
    func hideWordSelector() {
        let point = CGPointMake(view.center.x, view.frame.size.height*1.2)
        if let selector = wordSelector {
            selector.animateCenterToPoint(point, enableEntry: false)
        }
    }
    
    //MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if match.isLocalMatch {
            if let word = match.fromUserWord, let label = playerWordLabel {
                label.text = "using \(word)"
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - Navigation method

    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
    
    //MARK: IBAction methods
    
    @IBAction func didPressClose(sender: AnyObject) {
        performSegueWithIdentifier("toMain", sender: self)
    }

    @IBAction func didPressPlay(sender: AnyObject) {
        showWordSelector()
    }
    
}

extension PNTAGameplayViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == self.playerTable {
            count = self.playerGuesses.count
        } else if tableView == self.opponentTable {
            count = self.opponentGuesses.count
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("PNTAGuessTableViewCell") as? PNTAGuessTableViewCell
        if cell == nil {
            let arr = NSBundle.mainBundle().loadNibNamed("PNTAGuessTableViewCell", owner: self, options: nil)
            if let newCell = arr[0] as? PNTAGuessTableViewCell {
                cell = newCell
            }
        }
        
        let index = indexPath.row
        var guess: PNTAGuess!
        if tableView == self.playerTable {
            guess = playerGuesses[index]
            if isLocalMatch {
                let count = WordHelper.commonCharactersForWord(guess.string!, inMatchString: match.toUserWord!)
                cell!.count = count
            }
        } else if tableView == self.opponentTable {
            guess = opponentGuesses[index]
            if isLocalMatch {
                let count = WordHelper.commonCharactersForWord(guess.string!, inMatchString: match.fromUserWord!)
                cell!.count = count
            }
        }
        
        cell!.guess = guess
        
        cell!.backgroundColor = UIColor.clearColor()
        if let bgView = cell!.backgroundView {
            bgView.backgroundColor = UIColor.clearColor()
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
}

extension PNTAGameplayViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cellContentView  = cell.contentView;
        let rotationAngleDegrees = -30.0;
        let rotationAngleRadians = rotationAngleDegrees * (M_PI/180);
//        let offsetPositioning = CGPointMake(500, -20.0);
        let offsetPositioning = CGPointMake(0, cell.contentView.frame.size.height*4);
        var transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, CGFloat(rotationAngleRadians), -50.0, 0.0, 1.0);
        transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, -50.0);
        cellContentView.layer.transform = transform;
        cellContentView.layer.opacity = 0.8;
        
        UIView.animateWithDuration(0.65, delay: 0.0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.8, options: .TransitionNone, animations: { () -> Void in
            cellContentView.layer.transform = CATransform3DIdentity;
            cellContentView.layer.opacity = 1;
            }) { (success) -> Void in
                
        }
    }
}

extension PNTAGameplayViewController: PNTAWordSelectorViewDelegate {
    func wordSelector(selector: PNTAWordSelectorView, didFinishWithSuccess success: Bool) {
        self.hideWordSelector()
        if success {
            let word = selector.word
            let guess = PNTAGuess()
            guess.string = word
            
            pushGuess(guess)
//            match.guesses.append(guess)
//            playerGuesses.append(guess)
//            playerTable.reloadData()
//            
//            if isLocalMatch {
//                let opponentWord = WordHelper.randomWord()
//                let opponentGuess = PNTAGuess()
//                opponentGuess.string = opponentWord
//                match.guesses.append(opponentGuess)
//                opponentGuesses.append(opponentGuess)
//                opponentTable.reloadData()
//                LocalMatchHelper.setGuesses(match.guesses)
//            } else {
//            
//            }
            
        }
    }
    
    func wordSelector(selector: PNTAWordSelectorView, shouldFinishWithWord word: String) -> Bool {
        let isValid = WordHelper.isWordValid(word)
        if isValid {
            return true
        } else {
            return false
        }
    }
}
