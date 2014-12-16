//
//  ChatViewController.swift
//  Talk
//
//  Created by Matteo Maselli on 30/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var message: UITextField!
    
    
    //KeyboardActionExtension
    var focus: UITextField? {
        didSet{
            if oldValue != nil && focus != nil && oldValue != focus {
                self.checkKeyboardHeight(self.keyboard?)
            }
        }
    }
    var keyboard: CGRect?
    var difference: CGFloat = 0.0

    //Data Variables
    var user: String? {
        didSet{
            self.fetchFromDatabase()
        }
    }
    var messages: [Messages] = [] 
    
    let notification = NSNotificationCenter.defaultCenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addKeyboardObserverAndTapGesture()
        
        self.notification.addObserver(self, selector: "addMessageToTable:", name: "addedMessageToDatabase", object: nil)
        
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        

        if self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular {
            self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        }
        
        self.message.delegate = self
        
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.message.resignFirstResponder()
    }
    
    //MARK: - View Stuff
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.chatTableView.reloadData()
        if PFUser.currentUser() != nil && self.user != nil {
            self.navigationItem.title = self.user
        }
    }

    
    @IBAction func sendMessage(sender: UIButton) {
        if self.message.text != "" && self.user != nil {
            self.insertMessageInDatabase()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("ok")
    }
    
}
