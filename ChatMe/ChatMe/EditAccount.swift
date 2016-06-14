//
//  EditAccount.swift
//  ChatMe
//
//  Created by Janusz Majchrzak on 12/06/16.
//  Copyright © 2016 Janusz Majchrzak. All rights reserved.
//

import UIKit
import CoreData

class EditAccount : UIViewController {
    
    var username: String?
    var passwd: String?
    
    @IBOutlet weak var username_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var task: Users? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.username != nil {
            self.username_field.text! = self.username!
        }
        
        if self.passwd != nil {
            self.password_field.text! = self.passwd!
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    private func dismissViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
         self.dismissViewController()
    }
    
    @IBAction func saveClicked(sender: AnyObject) {
        if task != nil {
            self.editTask()
        } else {
            self.createTask()
        }
        dismissViewController()
    }
    
    func createTask() {
        let entityDescripition = NSEntityDescription.entityForName("Users", inManagedObjectContext: managedObjectContext)
        let task = Users(entity: entityDescripition!, insertIntoManagedObjectContext: managedObjectContext)
        task.nickname = self.username_field.text!
        task.password = self.password_field.text!
        do {
            try managedObjectContext.save()
        } catch _ {
        }
    }
    
    func editTask() {
        task?.nickname = self.username_field.text!
        task?.password = self.password_field.text!
        
        do {
            try managedObjectContext.save()
        } catch _ {
        }
    }
    
}