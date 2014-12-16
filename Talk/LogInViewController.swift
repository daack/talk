//
//  LogInViewController.swift
//  Talk
//
//  Created by Matteo Maselli on 30/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var signUp: UIButton!
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
        
        //Set UITextField delegate
        self.username.delegate = self
        self.password.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        //KeyboardTap
        self.addKeyboardObserverAndTapGesture()
        
        //Flip if user logged
        if PFUser.currentUser() != nil {
            performSegueWithIdentifier("welcomesegue", sender: self)
        }
    }
    
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
    
    //LogIn Action
    @IBAction func logIn(sender: UIButton) {
        self.spinner.startAnimating()
        
        PFUser.logInWithUsernameInBackground(self.username.text, password: self.password.text) { (user, error) -> Void in
            if error == nil {
                self.spinner.stopAnimating()
                self.performSegueWithIdentifier("welcomesegue", sender: self)
            } else {
                self.spinner.stopAnimating()
                self.allertWith("Error on username or password", andTitle: "LOGIN Error")
                println("Error on LogIn with error: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Allert Controller
    func allertWith(message: String, andTitle title: String) {
        let avc = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert )
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        avc.addAction(action)
        self.presentViewController(avc, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
