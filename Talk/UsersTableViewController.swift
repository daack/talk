//
//  UsersTableViewController.swift
//  Talk
//
//  Created by Matteo Maselli on 30/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var users: [PFObject]? {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    var actionMenu: UIActionSheet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Talk"
    
        self.actionMenu = UIActionSheet(title: "Talk", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Log out", "Add a photo")
        self.actionMenu.tag = 1
        
        self.setBlurBackground()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if PFUser.currentUser() != nil {
            self.loadUserFromParse()
        }
    }
    
    func setBlurBackground() {
        let imgbg = UIImageView(frame: self.tableView.bounds)
        imgbg.image = UIImage(named: "tableBackground")?
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blur.frame = imgbg.bounds
        imgbg.insertSubview(blur, atIndex: 0)
        self.tableView.backgroundView = imgbg
    }
    
    //MERK: - Refresh Action
    
    //Scroll refresh controll
    @IBAction func refreshControllerScroll(sender: UIRefreshControl) {
        self.loadUserFromParse()
    }
    
    //RefreshButton
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        self.tableView.reloadData()
    }
    
    //MARK: - ActionSheet
    
    @IBAction func barButtonActionSheet(sender: UIBarButtonItem) {
        self.actionMenu.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            PFUser.logOut()
            self.performSegueWithIdentifier("loginsegue", sender: self)
        case 2:
            self.pickaPhoto()
        default:
            break
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        
    }
    
     //MARK: - ImagePicker
    
    func pickaPhoto() {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        UIGraphicsBeginImageContext(CGSizeMake(120, 120));
        image.drawInRect(CGRectMake(0, 0, 120, 120))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let newimage: NSData = UIImageJPEGRepresentation(smallImage, 0.8)
        let pfile: PFFile = PFFile(name: "user.jpg", data: newimage)
        
        pfile.saveInBackgroundWithBlock { (succed, error) -> Void in
            
            PFUser.currentUser().setObject(pfile, forKey: "image")
            
            PFUser.currentUser().saveInBackgroundWithBlock({ (succed, error) -> Void in
                if error != nil {
                
                }
            })
        }
    }
    
    //Parse Query
    func loadUserFromParse(){
        self.refreshControl?.beginRefreshing()
        let userQuery = PFUser.query()
        userQuery.selectKeys(["username", "email"])
        userQuery.whereKey("username", notEqualTo: PFUser.currentUser().username)
        
        userQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error == nil {
                self.refreshControl?.endRefreshing()
                self.users = results as? [PFObject]
            } else {
                self.refreshControl?.endRefreshing()
                println("Error on query with error: \(error)")
                self.allertWith("Error on fetch Users", andTitle: "Internal Error")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let user: [PFObject] = self.users {
            return user.count
        }
        
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("users", forIndexPath: indexPath) as UITableViewCell

        if let user: [PFObject] = self.users {
            let userView = cell.contentView.subviews[0] as UserViewCell
            userView.username = user[indexPath.row].objectForKey("username") as? String
            userView.email = user[indexPath.row].objectForKey("email") as? String
            userView.setImage()
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("chatsegue", sender: self)
    }
    
    //Allert Controller
    func allertWith(message: String, andTitle title: String) {
        let avc = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert )
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        avc.addAction(action)
        self.presentViewController(avc, animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginsegue" {
            self.splitViewController?.removeFromParentViewController()
        }
        if segue.identifier == "chatsegue" {
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()!
            let name: String? = self.users?[indexPath.row].objectForKey("username") as? String
            if let username: String = name {
                var cvc = (segue.destinationViewController as UINavigationController).topViewController as ChatViewController
                cvc.user = username
            } else {
                NSException(name: "Error on chatsegue", reason: "Not found username in user array at index: \(indexPath.row)", userInfo: nil)
            }
        }
    }

}
