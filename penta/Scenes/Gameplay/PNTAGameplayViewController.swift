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
    
    let currentUser = PNTAUser.sharedUser
    var match: PNTAMatch! {
        didSet {
            updateGameplayWithMatch(match)
        }
    }
    var myWord: String!
    
    var playerGuesses: [PNTAGuess] = []
    var opponentGuesses: [PNTAGuess] = []
    
    var wordSelector: PNTAWordSelectorView?
    
    var didFinishGame: Bool = false
    var isLocalMatch: Bool = false
    var isActiveGame: Bool = true {
        didSet {
            playButton.enabled = isActiveGame
        }
    }
    
    func pushGuess(guess: PNTAGuess) {
        
        match.appendGuess(guess) {
            (success, error) -> Void in
            if let error = error {
                print("error uploading guess:\n\(error)")
            } else if success {
//                self.addGuess(guess, toTable: self.playerTable)
            }
        }
        
        if AdHelper.shouldServeAd() {
            AdHelper.serveInterstitialAd()
        }
        
        if playerDidWinMatch(match, withGuess: guess) {
            isActiveGame = false
            didFinishGame = true
            showMatchEnd(true)
        } else {
//            if AdHelper.shouldServeAd() {
//                AdHelper.serveInterstitialAd()
//            }
        }
    }
    
    func addGuess(guess: PNTAGuess, toTable table:UITableView) {
        var count = 0
        if table == playerTable {
            playerGuesses.append(guess)
            count = playerGuesses.count
        } else {
            opponentGuesses.append(guess)
            count = opponentGuesses.count
        }
//        guesses.append(guess)
        table.reloadData()
        let indexPath = NSIndexPath(forRow: count-1, inSection: 0)
        table.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    func playerDidWinMatch(match: PNTAMatch, withGuess guess: PNTAGuess) -> Bool {
        if let toWord = match.toUserWord, let fromWord = match.fromUserWord, let guessWord = guess.string {
            if match.isLocalMatch && guessWord == toWord {
                return true
            } else { //determine which word is opponents, then check
                return false
            }
        } else {
            return false
        }
    }
    
    func showWordSelector() {
        if wordSelector == nil {
            let nibs = NSBundle.mainBundle().loadNibNamed("PNTAWordSelectorView", owner: self, options: nil)
            if nibs.count > 0 {
                if let selector = nibs[0] as? PNTAWordSelectorView {
//                    let rect = CGRectMake(0, 0, view.frame.size.width*0.9, view.frame.size.height*0.4)
//                    let center = CGPointMake(view.center.x, view.frame.size.height*1.2)
//                    selector.bounds = rect
//                    selector.center = center
                    selector.frame = view.frame
                    view.addSubview(selector)
                    selector.prepare()
                    selector.delegate = self
                    wordSelector = selector
                }
            }
        }
        
        
        
        if let selector = wordSelector {
//            view.addSubview(wordSelector!)
            let index = WordHelper.characterStrengthIndexFromGuesses(playerGuesses)
            selector.index = index
            if playerGuesses.count > 4 {
                selector.wordStrategy = .Calculated
            } else if playerGuesses.count > 0 {
                selector.wordStrategy = .Unused
            } else {
                selector.wordStrategy = .Random
            }
            
            selector.potentialMatch = match
            selector.show()
//            let point = CGPointMake(view.center.x, view.center.y*0.5)
//            selector.animateCenterToPoint(point, enableEntry: true)
        }
    }
    
    func hideWordSelector() {
//        let point = CGPointMake(view.center.x, view.frame.size.height*1.2)
//        if let selector = wordSelector {
//            selector.animateCenterToPoint(point, enableEntry: false)
//                selector.hide()
//        }
        wordSelector?.hide()
    }
    
    func showMatchEnd(didWin: Bool) {
        let nibs = NSBundle.mainBundle().loadNibNamed("PNTAMatchEndView", owner: self, options: nil)
        if nibs.count > 0 {
            if let matchEndView = nibs[0] as? PNTAMatchEndView {
                matchEndView.frame = view.frame
                matchEndView.prepare()
                matchEndView.delegate = self
                view.addSubview(matchEndView)
                matchEndView.appear()
            }
        }
    }
    
    func updateGameplayWithMatch(match: PNTAMatch) {
        for var i = 0; i < match.guesses.count; i++ {
            let guess = match.guesses[i]
            if match.isLocalMatch {
                if i % 2 == 0 {
                    guess.count = WordHelper.commonCharactersForWord(guess.string!, inMatchString: match.toUserWord!)
                    playerGuesses.append(guess)
                } else {
                    guess.count = WordHelper.commonCharactersForWord(guess.string!, inMatchString: match.fromUserWord!)
                    opponentGuesses.append(guess)
                }
            } else { //compare PFUser
                
            }
        }
        
        if let fromUser = match.fromUser, let toUser = match.toUser, let parseUser = currentUser.parseUser {
            var myWord = "something"
            if parseUser.objectId == fromUser.objectId {
                if let word = match.fromUserWord {
                    myWord = word
                }
            } else if parseUser.objectId == toUser.objectId {
                if let word = match.toUserWord {
                    myWord = word
                }
            }
            self.myWord = myWord
        }
        
        self.isLocalMatch = match.isLocalMatch
    }
    
    //MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        playButton.layer.cornerRadius = 6.0
        playButton.layer.borderColor = UIColor.groupTableViewBackgroundColor().CGColor
        playButton.layer.borderWidth = 1.0
        
        if match.isLocalMatch {
            if let word = match.fromUserWord, let label = playerWordLabel {
                myWord = word
            }
            if let behavior = match.localMatchBehavior {
                behavior.enabled = true
            }
        } else {
            
        }
        
        match.addObserver(self, forKeyPath: "ownGuesses", options: .New, context: nil)
        match.addObserver(self, forKeyPath: "opponentGuesses", options: .New, context: nil)
        
        if match.isFinished {
            isActiveGame = false
        }
        
        playerWordLabel.text = "using \(myWord)"
    }
    
    override func viewWillDisappear(animated: Bool) {
        match.removeObserver(self, forKeyPath: "ownGuesses")
        match.removeObserver(self, forKeyPath: "opponentGuesses")
        super.viewWillDisappear(animated)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - KVO callback
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath, let dict = change else {
            return
        }
        
        if keyPath == "ownGuesses" {
            playerTable.reloadData()
            let indexPath = NSIndexPath(forRow: match.ownGuesses.count-1, inSection: 0)
            playerTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        } else if keyPath == "opponentGuesses" {
            opponentTable.reloadData()
            let indexPath = NSIndexPath(forRow: match.opponentGuesses.count-1, inSection: 0)
            opponentTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        } else {
            print("could not use change:\n\(dict)")
        }
    }
    
    //MARK: - Navigation method

    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    
        if let vc = unwindSegue.destinationViewController as? PNTAMainViewController {
            if didFinishGame {
                vc.endMatch(match)
            } else {
                vc.updateMatch(match)
            }
        }
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
            count = match.ownGuesses.count
        } else if tableView == self.opponentTable {
            count = match.opponentGuesses.count
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
            guess = match.ownGuesses[index]
            if isLocalMatch {
                let count = WordHelper.commonCharactersForWord(guess.string!, inMatchString: match.toUserWord!)
                guess.count = count
                cell!.count = count
            } else {
                
            }
        } else if tableView == self.opponentTable {
            guess = match.opponentGuesses[index]
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

}

extension PNTAGameplayViewController: PNTAWordSelectorViewDelegate {
    func wordSelector(selector: PNTAWordSelectorView, didFinishWithSuccess success: Bool) {
        self.hideWordSelector()
        if success {
            let word = selector.word
            let guess = PNTAGuess()
            guess.string = word
            guess.owner = PFUser.currentUser()
            pushGuess(guess)
            
            let center = NSNotificationCenter.defaultCenter()
            center.postNotificationName("Penta User Submit Guess", object: nil)
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

extension PNTAGameplayViewController: PNTAMatchEndViewDelegate {
    func matchEndViewDidFinish(view: PNTAMatchEndView) {
        view.removeFromSuperview()
        performSegueWithIdentifier("toMain", sender: self)
    }
    
    func matchEndViewShouldFinish(view: PNTAMatchEndView) -> Bool {
        return true
    }
}