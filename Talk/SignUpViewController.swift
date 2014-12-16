//
//  SignUpViewController.swift
//  Talk
//
//  Created by Matteo Maselli on 30/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var focus: UITextField? {
        didSet{
            if oldValue != nil && focus != nil && oldValue != focus {
                self.checkKeyboardHeight(self.keyboard?)
            }
        }
    }
    var keyboard: CGRect?
    var keyFlag: Bool = false
    
    let notification = NSNotificationCenter.defaultCenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set UITextField delegates
        self.username.delegate = self
        self.password.delegate = self
        self.email.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    
        //Add Keyboard notification
        self.addKeyboardObserverAndTapGesture()
    }
    
    //MARK: - Keyboard
    
    //KeyboardObserver
    func addShowKeyboardObserver() {
        self.notification.addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func addHideKeyboardObserver() {
        self.notification.addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func addKeyboardObserverAndTapGesture() {
        self.addShowKeyboardObserver()
        self.addHideKeyboardObserver()
        //Resigne Keyboard TapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: "keyboardTapOutside")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func keyboardShow(note: NSNotification){
        let keyboardBoard: CGRect = note.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue() as CGRect
        self.keyboard = keyboardBoard
        self.checkKeyboardHeight(keyboardBoard)
    }
    
    func checkKeyboardHeight(keyboard: CGRect?) {
        if self.keyFlag == true {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                if self.view.window != nil {
                    self.view.window!.frame.origin = CGPointMake(0, 0)
                }
            })
        }
        if let keyboardBoard: CGRect = keyboard {
            if let field: UITextField = self.focus {
                var height: CGFloat = field.frame.origin.y + field.frame.size.height/2 + 20
                if keyboardBoard.origin.y < height {
                    let difference = height - keyboardBoard.origin.y
                    if let window: UIWindow = self.view.window {
                        self.keyFlag = true
                        window.frame.origin = CGPointMake( 0, -difference)
                    }
                }
            }
        }
    }
    
    func keyboardHide(note: NSNotification){
        if let window: UIWindow = self.view.window {
            window.frame.origin = CGPointMake( 0, 0)
        }
        self.keyFlag = false
        self.focus = nil
        self.keyboard = nil
    }
    
    
    //Resize KeyboardView
    func keyboardTapOutside() {
        if let fieldFocus: UITextField = self.focus {
            fieldFocus.resignFirstResponder()
            self.focus = nil
        }
    }
    
    //UITextField delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.focus = textField
        self.addHideKeyboardObserver()
    }

    //MARK: - SignUp
    
    //SignUp Action
    @IBAction func signUpParse(sender: UIButton) {
        let user = PFUser()
    
        user.username = self.username.text
        user.password = self.password.text
        user.email = self.email.text
        
        self.spinner.startAnimating()
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if success && error == nil {
                self.spinner.stopAnimating()
                self.requestForNotification()
            } else {
                self.spinner.stopAnimating()
                self.allertWith("Please check fields", andTitle: "Error on SIGNUP")
                println("Error on signUp with error: \(error)")
            }
        }
    }
    
    //Register for Background Notification
    func requestForNotification() {
        self.notification.addObserver(self, selector: "reciveNotification", name: "didRegisterForNotification", object: nil)
        self.notification.postNotificationName("SignUp", object: self, userInfo: nil)
    }
    
    //CallBack from Remote Notification
    func reciveNotification() {
        self.performSegueWithIdentifier("welcomesignupsegue", sender: self)
    }
    
    //MARK: - Utilities
    
    //Allert Controller
    func allertWith(message: String, andTitle title: String) {
        let avc = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert )
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        avc.addAction(action)
        self.presentViewController(avc, animated: true, completion: nil)
    }    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Dismiss modal
    @IBAction func dismissModal(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
