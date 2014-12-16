//
//  Users.swift
//  Talk
//
//  Created by Matteo Maselli on 31/10/14.
//  Copyright (c) 2014 Matteo Maselli. All rights reserved.
//

import Foundation
import CoreData

class Users: NSManagedObject {

    @NSManaged var username: String
    @NSManaged var messages: NSSet

}
