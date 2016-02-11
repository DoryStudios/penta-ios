//
//  PNTAMainViewController.swift
//  penta
//
//  Created by Andrew Brandt on 1/20/16.
//  Copyright © 2016 Dory Studios. All rights reserved.
//

import UIKit

enum PNTAMenuState {
    case Appeared
    case Animating
    case Ready
}

class PNTAMainViewController: UITableViewController {
    
    let GAMEPLAY_SEGUE = "toGameplay"
    
    var menuState: PNTAMenuState = .Appeared
    
    var pendingMatches: [PNTAMatch] = []
    var activeMatches: [PNTAMatch] = []
    var completedMatches: [PNTAMatch] = []
    
    var potentialMatch: PNTAMatch?
    var wordSelector: PNTAWordSelectorView?
    var isLinkedToFacebook: Bool = true
    
    lazy var currentUser = PNTAUser.sharedUser
    var availableFriends: NSArray = []
    
    func fetchMatches() {
        if let user = PFUser.currentUser() {
            ParseHelper.fetchMatchesForUser(user, includeFinished: false, completionBlock: {
            (result: [AnyObject]?, error: NSError?) -> Void in
                if let matches = result as? [PNTAMatch] {
                    print("fetched \(matches.count) matches")
                    self.filterMatches(matches)
                } else if let error = error {
                    print("encountered error fetching matches:\n\(error)")
                }
            })
        } else {
            
        }
    }
    
    func filterMatches(matches: [PNTAMatch]) {
        
        for match in matches {
            if !match.isFinished {
                if let lastGuess = match.lastGuess, let user = PFUser.currentUser() {
                    if user.madeGuess(lastGuess) {
                        pendingMatches.append(match)
                    } else {
                        activeMatches.append(match)
                    }
                } else if match.isLocalMatch {
                    if match.guesses.count % 2 == 0 {
                        activeMatches.append(match)
                    } else {
                        pendingMatches.append(match)
                    }
                } else { //no lastGuess, match waiting for user to acknowledge
                    
                }
            } else {
                completedMatches.append(match)
            }
        }
        
        updateTable()
    }
    
    func updateTable() {
        tableView.reloadData()
    }
    
    func didChallenge(message: NSNotification) {
        guard let friend = message.object as? PNTAFriend else {
            print("notification sent without friend")
            return
        }
        
        ParseHelper.fetchUserByFacebookID(friend.socialID) {
        (result: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                print("error looking up user:\n\(error)")
            }
            
            if let result = result as? [PFUser] {
                
            }
        }
    }
    
    func pushMatch(match: PNTAMatch) {
        if match.isLocalMatch {
//            let word = WordHelper.randomWord()
//            match.toUserWord = word
            LocalMatchHelper.setMatch(match)
        }
        potentialMatch = match
        performSegueWithIdentifier(GAMEPLAY_SEGUE, sender: match)
    }
    
    func updateMatch(match: PNTAMatch) {
        if let index = pendingMatches.indexOf(match) {
            pendingMatches.removeAtIndex(index)
        } else if let index = activeMatches.indexOf(match) {
            activeMatches.removeAtIndex(index)
        }
        
        filterMatches([match])
    }
    
    func endMatch(match: PNTAMatch) {
        
        if let index = activeMatches.indexOf(match) {
            activeMatches.removeAtIndex(index)
        } else if let index = pendingMatches.indexOf(match) {
            pendingMatches.removeAtIndex(index)
        }
        
        if match.isLocalMatch {
            LocalMatchHelper.clearMatch()
        }
        
        tableView.reloadData()
    }
    
    func showWordSelectorForMatch(match: PNTAMatch) {
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
            selector.potentialMatch = match
            selector.show()
//            let point = CGPointMake(view.center.x, view.center.y*0.5)
//            selector.animateCenterToPoint(point, enableEntry: true)
        }
    }
    
    func hideWordSelector() {
//        let point = CGPointMake(view.center.x, view.frame.size.height*1.2)
        if let selector = wordSelector {
//            selector.animateCenterToPoint(point, enableEntry: false)
                selector.hide()
        }
    }
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if let user = PFUser.currentUser() {
//            if PFFacebookUtils.isLinkedWithUser(user) { //happy path
//                fetchMatches()
//            } else { //likely user invalidated session in facebook
//                isLinkedToFacebook = false
//            }
//        } else { //new user, offer link to facebook, don't bother fetch remote matches
//            isLinkedToFacebook = false
//        }

//        if let nc = self.navigationController {
//            nc.setNavigationBarHidden(true, animated: false)
//        }

        let imageView = UIImageView(image: UIImage(named: "penta-bg"))
        imageView.contentMode = .ScaleAspectFill
        tableView.backgroundView = imageView
        
        let matches = LocalMatchHelper.fetchMatches()
        filterMatches(matches)
        
        if !isLinkedToFacebook {
            updateTable()
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        isLinkedToFacebook = currentUser.isLinkedToFacebook
        currentUser.addObserver(self, forKeyPath: "isLinkedToFacebook", options: .New, context: nil)
        currentUser.addObserver(self, forKeyPath: "availableFriends", options: .New, context: nil)
        
        if currentUser.availableFriends.count > 0 {
            
        }
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("didChallenge:"), name: ISSUE_CHALLENGE, object: nil)
        tableView.reloadData()
    }
    
    //MARK: - Navigation method
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == GAMEPLAY_SEGUE {
            if let vc = segue.destinationViewController as? PNTAGameplayViewController, let match = sender as? PNTAMatch {
                vc.match = match
            }
        }
    }
    
    //MARK: - KVO callback method
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let dict = change else {
            return
        }
        
        if keyPath == "isLinkedToFacebook" {
            print("observed change to social link:\n\(dict)")
            var linkedStatus: Bool = false
            if let isLinked = dict["new"]?.boolValue {
                print("linked social value now \(isLinked)")
                linkedStatus = isLinked
            }
            self.isLinkedToFacebook = linkedStatus
            self.updateTable()
        } else if keyPath == "availableFriends" {
            //TODO: should sort friends first
            updateTable()
        }
    }
    
    //MARK: - UITableViewDataSource methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let hasPendingMatches = !self.pendingMatches.isEmpty
        let hasActiveMatches = !self.activeMatches.isEmpty
        
        switch indexPath.section {
            case 0:
                let arr = NSBundle.mainBundle().loadNibNamed("PNTAMenuHeaderTableViewCell", owner: self, options: nil)
                if let newCell = arr[0] as? PNTAMenuHeaderTableViewCell {
                    if indexPath.row == 1 {
                        newCell.callToAction = true
                    }
                    cell = newCell
                }
                break
            case 1,2:
                let reusedCell = tableView.dequeueReusableCellWithIdentifier("PNTAMatchTableViewCell")
                
                if let reusedCell = reusedCell as? PNTAMatchTableViewCell {
                    reusedCell.prepare()
                    cell = reusedCell
                } else {
                    let arr = NSBundle.mainBundle().loadNibNamed("PNTAMatchTableViewCell", owner: self, options: nil)
                    if let newCell = arr[0] as? PNTAMatchTableViewCell {
                        newCell.prepare()
                        cell = newCell
                    }
                }
                
                let row = indexPath.row
                var match: PNTAMatch? = nil
                
                if indexPath.section == 1 {
                    match = activeMatches[row]
                } else if indexPath.section == 2 {
                    match = pendingMatches[row]
                }
                
                if let match = match, let cell = cell as? PNTAMatchTableViewCell {
                    cell.match = match
                }
                
                if hasActiveMatches {
                
                }
                if hasPendingMatches {
                
                }
                
                break
            case 3:
                let reusedCell = tableView.dequeueReusableCellWithIdentifier("PNTAChallengeTableViewCell")
                let row = indexPath.row
                let challenger = currentUser.availableFriends[row]
                if let reusedCell = reusedCell as? PNTAChallengeTableViewCell {
                    reusedCell.challengerName.text = challenger.name
                    cell = reusedCell
                } else {
                    let arr = NSBundle.mainBundle().loadNibNamed("PNTAChallengeTableViewCell", owner: self, options: nil)
                    if let newCell = arr[0] as? PNTAChallengeTableViewCell {
                        newCell.friend = challenger
                        cell = newCell
                    }
                }
                break
            default: break
        }
        
        cell.backgroundColor = UIColor.clearColor()
        if let bgView = cell.backgroundView {
            bgView.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                //call to action button
                let addSocialButton = isLinkedToFacebook ? 0 : 1
                return 1 + addSocialButton
            
            case 1:
                return activeMatches.count
            case 2:
                return pendingMatches.count
            case 3:
                return currentUser.availableFriends.count
            default:
                return 0
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hasPendingMatches = !self.pendingMatches.isEmpty
        let hasActiveMatches = !self.activeMatches.isEmpty
        let hasFriends = currentUser.availableFriends.count > 0

        var titleView: UIView? = nil
        let rect = CGRectMake(0, 0, self.view.frame.size.width, 40)
        
        if section == 0 {
            let arr = NSBundle.mainBundle().loadNibNamed("PNTAMenuHeaderView", owner: self, options: nil)
            if let vw = arr[0] as? PNTAMenuHeaderView {
                let rect = CGRectMake(0, 0, self.view.frame.size.width, 100)
                vw.frame = rect
                titleView = vw
            }
        } else if section == 1 {
            if hasActiveMatches {
                let arr = NSBundle.mainBundle().loadNibNamed("PNTAMatchHeaderView", owner: self, options: nil)
                if let vw = arr[0] as? UIView {
                    vw.frame = rect
                    titleView = vw
                }
            } else if !hasPendingMatches && !hasActiveMatches && !hasFriends {
                let arr = NSBundle.mainBundle().loadNibNamed("PNTAMatchHeaderView", owner: self, options: nil)
                if let vw = arr[0] as? UIView, let label = vw.viewWithTag(42) as? UILabel {
                    vw.frame = rect
                    label.text = "Click Quick Start to Play!"
                    titleView = vw
                }
            } else {
                titleView = UIView(frame: CGRectZero)
            }
        } else if section == 2 {
            if hasPendingMatches {
                let arr = NSBundle.mainBundle().loadNibNamed("PNTAMatchHeaderView", owner: self, options: nil)
                if let vw = arr[0] as? UIView, let label = vw.viewWithTag(42) as? UILabel {
                    vw.frame = rect
                    label.text = "Opponent's Turn"
                    titleView = vw
                }
            } else {
                titleView = UIView(frame: CGRectZero)
            }
        } else if section == 3 {
            if currentUser.availableFriends.count > 0 {
                let arr = NSBundle.mainBundle().loadNibNamed("PNTAMatchHeaderView", owner: self, options: nil)
                if let vw = arr[0] as? UIView, let label = vw.viewWithTag(42) as? UILabel {
                    vw.frame = rect
                    label.text = "Challenge Friends"
                    titleView = vw
                }
            } else {
                titleView = UIView(frame: CGRectZero)
            }
        }
        
        return titleView
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80.0
        } else {
            return 70.0
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let hasPendingMatches = !self.pendingMatches.isEmpty
        let hasActiveMatches = !self.activeMatches.isEmpty
        let hasNoMatches = !hasActiveMatches && !hasPendingMatches
        let hasFriends = currentUser.availableFriends.count > 0
        
        if section == 0 {
            return 100.0
        } else if (section == 1 && (hasActiveMatches || hasNoMatches) && (hasFriends && hasActiveMatches)) || (section == 2 && hasPendingMatches) || section == 3 {
            return 40.0
        } else {
            return CGFloat.min
        }
    }
    
    //MARK: - UITableViewDelegate methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        var match: PNTAMatch?
        
        if section == 0 { //quick match
            if row == 0 {
                let newMatch = LocalMatchHelper.newMatch()
                showWordSelectorForMatch(newMatch)
            } else {
                currentUser.connectSocial()
            }
        } else if section == 1 { //active match (users turn)
            match = activeMatches[row]
        } else if section == 2 { //pending match (opponents turn)
            match = pendingMatches[row]
        }
        
        if let match = match {
            pushMatch(match)
        }
    }
}

extension PNTAMainViewController: PNTAWordSelectorViewDelegate {
    
    func wordSelector(selector: PNTAWordSelectorView, didFinishWithSuccess success: Bool) {
        self.hideWordSelector()
        if success {
            let word = selector.word
            let match = selector.potentialMatch
            match.fromUserWord = word
            if match.isLocalMatch {
                match.toUserWord = WordHelper.randomWord()
            }
            
            pushMatch(match)
            print("selected word \(word)")
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