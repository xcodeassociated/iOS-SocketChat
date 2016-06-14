//
//  CoreDataDriver.swift
//  ChatMe
//
//  Created by Janusz Majchrzak on 11/06/16.
//  Copyright © 2016 Janusz Majchrzak. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataDriver{
    
    var appDelegate: AppDelegate
    var context: NSManagedObjectContext
    
    init(){
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.context = self.appDelegate.managedObjectContext
    }
    
    func checkUser(username: String?, passwd: String?) -> (Bool, Bool){
        return (self.checkUsername(username), self.checkPasswd(passwd))
    }
    
    private func request(predicate: NSPredicate) -> Bool{
        var obj = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: self.context) as! NSManagedObject
        
        var request = NSFetchRequest(entityName: "Users")
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        var resultArray: NSArray?
        
        do {
           resultArray  = try self.context.executeFetchRequest(request)
            self.context.reset()
        } catch {}
        if resultArray!.count > 0 {
            return true
        }else{
            return false
        }
    }
    
    private func checkUsername(username: String?) -> Bool{
        if username == nil {
            return false
        }else{
            return self.request(NSPredicate(format: "nickname = %@", username!))
        }
    }
    
    private func checkPasswd(passwd: String?) -> Bool{
        if passwd == nil {
            return false
        }else{
            return self.request(NSPredicate(format: "password = %@", passwd!))
        }
    }
    
}