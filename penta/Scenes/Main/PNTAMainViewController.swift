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
    
    var potentialMatch: PNTAMatch?
    var wordSelector: PNTAWordSelectorView?
    var isLinkedToFacebook: Bool = true
    
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
        }
    }
    
    func filterMatches(matches: [PNTAMatch]) {
        
        for match in matches {
            if let lastGuess = match.lastGuess, let user = PFUser.currentUser() {
                if user.madeGuess(lastGuess) {
                    pendingMatches.append(match)
                } else {
                    activeMatches.append(match)
                }
            } else { //no lastGuess, match waiting for user to acknowledge
            
            }
        }
        
        updateTable()
    }
    
    func updateTable() {
        tableView.reloadData()
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
    
    func showWordSelectorForMatch(match: PNTAMatch) {
        if wordSelector == nil {
            let nibs = NSBundle.mainBundle().loadNibNamed("PNTAWordSelectorView", owner: self, options: nil)
            if nibs.count > 0 {
                if let selector = nibs[0] as? PNTAWordSelectorView {
                    let rect = CGRectMake(0, 0, view.frame.size.width*0.9, view.frame.size.height*0.4)
                    let center = CGPointMake(view.center.x, view.frame.size.height*1.2)
                    selector.bounds = rect
                    selector.center = center
                    view.addSubview(selector)
                    selector.prepare()
                    selector.delegate = self
                    wordSelector = selector
                }
            }
        }
        
        if let selector = wordSelector {
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

        if let user = PFUser.currentUser() {
            if PFFacebookUtils.isLinkedWithUser(user) { //happy path
                fetchMatches()
            } else { //likely user invalidated session in facebook
                isLinkedToFacebook = false
            }
        } else { //new user, offer link to facebook, don't bother fetch remote matches
            isLinkedToFacebook = false
        }
        
        let imageView = UIImageView(image: UIImage(named: "penta-bg"))
        imageView.contentMode = .ScaleAspectFill
        tableView.backgroundView = imageView
        
        if !isLinkedToFacebook {
            updateTable()
        }
        
//        if let nc = self.navigationController {
//            nc.setNavigationBarHidden(true, animated: false)
//        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if LocalMatchHelper.hasSoloMatch() {
            let match = LocalMatchHelper.getMatch()
            activeMatches.append(match)
        }
    }
    
    //MARK: - Navigation method
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == GAMEPLAY_SEGUE {
            if let vc = segue.destinationViewController as? PNTAGameplayViewController, let match = sender as? PNTAMatch {
                vc.match = match
            }
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
            default:
                return 0
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hasPendingMatches = !self.pendingMatches.isEmpty
        let hasActiveMatches = !self.activeMatches.isEmpty

        var titleView: UIView? = nil
        let rect = CGRectMake(0, 0, self.view.frame.size.width, 30)
        
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
        
        if section == 0 {
            return 100.0
        } else if (section == 1 && hasActiveMatches) || (section == 2 && hasPendingMatches) {
            return 30.0
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
            let newMatch = PNTAMatch()
            newMatch.isLocalMatch = true
            showWordSelectorForMatch(newMatch)
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