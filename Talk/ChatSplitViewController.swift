//
//  ChatSplitViewController.swift
//  Talk
//
//  Created by Matteo Maselli on 30/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import UIKit

class ChatSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
    }
    
    //IPhone master root view
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        
        let navigationVC = secondaryViewController as UINavigationController
        let current = navigationVC.topViewController
        let detail: AnyObject = self.viewControllers[0]
        if current == detail as NSObject {
            println("ok")
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    }

}
