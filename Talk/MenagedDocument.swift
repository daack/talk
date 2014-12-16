//
//  MenagedDocument.swift
//  Talk
//
//  Created by Matteo Maselli on 31/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Global {
    static var document: UIManagedDocument?

    static let documentDirectory: NSURL? = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first as NSURL?
}

class ManagedDocument {
    
    //Global Variable
    private var document: UIManagedDocument? {
        set{
            Global.document = newValue
        }
        get{
            return Global.document
        }
    }
    private var url: NSURL? {
        get {
            return self.setUrl()
        }
    }
    
    private let fileManager = NSFileManager.defaultManager()
    
    //DatabaseModel Path
    private let databaseModel = "MessageModel"
    
    private func setUrl() -> NSURL? {
        if let directory: NSURL = Global.documentDirectory {
            return directory.URLByAppendingPathComponent(self.databaseModel)
        }
        return nil
    }
    
    //Function to call in order to perfom operetions in context
    func needDocument(work: ((context: NSManagedObjectContext) -> ())?) {
        if self.document != nil && self.document!.documentState == UIDocumentState.Normal {
            work?(context: self.document!.managedObjectContext)
        } else {
            self.openDocument(work)
        }
    }
    
    private func openDocument(work: ((context: NSManagedObjectContext) -> ())?) {
        if self.url == nil {
            NSException(name: "Path Missing", reason: "Don't set a PATH for database model --> define databaseModel const", userInfo: nil)
        } else {
            self.document = UIManagedDocument(fileURL: self.url!)
            
            if self.fileManager.fileExistsAtPath(self.url!.path!) {
                self.document!.openWithCompletionHandler()
                    { (success) -> Void in
                        if success {
                            self.needDocument(work)
                        } else {
                            NSException(name: "Document Error", reason: "Can't open the Document", userInfo: nil)
                        }
                }
            } else {
                self.document!.saveToURL(self.url!, forSaveOperation: UIDocumentSaveOperation.ForCreating)
                    { (success) -> Void in
                        if success {
                            self.needDocument(work)
                        } else {
                            NSException(name: "Document Error", reason: "Can't create the Document", userInfo: nil)
                        }
                }
            }
            
        }
        
    }
    
}