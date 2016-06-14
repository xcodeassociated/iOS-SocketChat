//
//  data.swift
//  ChatMe
//
//  Created by Janusz Majchrzak on 12/06/16.
//  Copyright © 2016 Janusz Majchrzak. All rights reserved.
//

import Foundation
import CoreData

class Users: NSManagedObject {
    
    @NSManaged var nickname: String
    @NSManaged var password: String

}
