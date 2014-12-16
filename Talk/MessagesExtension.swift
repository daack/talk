//
//  MessagesExtension.swift
//  Talk
//
//  Created by Matteo Maselli on 30/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import UIKit
import CoreData

extension Messages {
    
    class func addMessageToUser(user: String, message: String, mine: Bool = false, context: NSManagedObjectContext) {
        if let currentUser = Users.checkUser(user, context: context) {
            let newMessage = NSEntityDescription.insertNewObjectForEntityForName("Messages", inManagedObjectContext: context) as Messages
            let id = currentUser.lastId
            newMessage.owner = currentUser
            newMessage.message = message
            newMessage.mine = mine
            newMessage.id = id
            newMessage.owner.lastId = id.integerValue + 1
            context.save(nil)
            NSNotificationCenter.defaultCenter().postNotificationName("addedMessageToDatabase", object: self, userInfo: ["message": newMessage])
        }
    }
    
    class func fetchAllMessageFromUser(user: String, context: NSManagedObjectContext, completionHandler: ((data: [Messages]) -> ())?) {
        let request = NSFetchRequest(entityName: "Messages")
        request.predicate = NSPredicate(format: "owner.username = %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        var results: [Messages] = context.executeFetchRequest(request, error: nil) as [Messages]
        completionHandler?(data: results)
    }
}
