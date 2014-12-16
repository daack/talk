//
//  AppDelegate.swift
//  Talk
//
//  Created by Matteo Maselli on 30/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //Set Notification Center
    let notification = NSNotificationCenter.defaultCenter()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Set up Parse key
        Parse.setApplicationId("*", clientKey: "*")
        
        //Parse Analytics
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        //Observer For SignUp Notification
        self.notification.addObserverForName("SignUp", object: nil, queue: nil)
            { (note) -> Void in
                    let userNotificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
                    let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
                    application.registerUserNotificationSettings(notificationSettings)
                    application.registerForRemoteNotifications()
            }

        return true
    }
    
    //MARK: - Notification Center
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        //Token to Parse
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = [PFUser.currentUser().username]
        currentInstallation.saveInBackgroundWithBlock(nil)
        
        //Finish to signUp
        self.notification.postNotificationName("didRegisterForNotification", object: self)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        if (userInfo["username"] != nil && userInfo["message"] != nil) {
        
            let username = userInfo["username"] as String
            let message = userInfo["message"] as String
            
            ManagedDocument().needDocument { (context) -> () in
                Messages.addMessageToUser(username, message: message, mine: false, context: context)
            }
            
            completionHandler(UIBackgroundFetchResult.NewData)
        } else {
        
            completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    //MARK: - Application LifeCycle
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

