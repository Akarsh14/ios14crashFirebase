//
//  MatchboxViewController.swift
//  Woo_v2
//
//  Created by Umesh Mishraji on 13/04/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import Foundation
import UIKit


class MatchboxViewController_New: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    //=====************define all the variable here**************==========//
    
    var questionArray:NSMutableArray!
    var myMatchesArray:NSMutableArray!
    var myMatchesSearchArray:NSMutableArray!

    
    @IBOutlet var matchboxTableView:UITableView!
    @IBOutlet var askButton:UIButton!
    @IBOutlet var segmentControl:UISegmentedControl!
    @IBOutlet var tableTopContraint:NSLayoutConstraint!
    
    
    
    var showQuestions:Bool = false
    
    
    var emptyMatches:EmptyMatchesView!
    var emptyQuestions:EmptyQuestionsView!
    var emptyFav:EmptyFavMatchesView!
    
    
    
    
    
    
    
    
    
    
    
    //====================***********************************=============//
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCellWithIdentifier("reuserID", forIndexPath: indexPath)
        
        return cell
        
    }
    
    
    class func sampleFunc(sampleData: NSDictionary) -> MatchboxViewController_New
    {
        
//        var managedObject:NSManagedObjectContext = STORE.newPrivateContext
        
        let match = MatchboxViewController_New()
        return match
        
        
    }
}
