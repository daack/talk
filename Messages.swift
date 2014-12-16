//
//  Messages.swift
//  Talk
//
//  Created by Matteo Maselli on 31/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import Foundation
import CoreData

class Messages: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var message: String
    @NSManaged var mine: NSNumber
    @NSManaged var owner: Users

}
