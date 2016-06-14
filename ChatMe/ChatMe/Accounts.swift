//
//  Accounts.swift
//  ChatMe
//
//  Created by Janusz Majchrzak on 12/06/16.
//  Copyright © 2016 Janusz Majchrzak. All rights reserved.
//

import UIKit
import CoreData

class Accounts : UITableViewController, NSFetchedResultsControllerDelegate{
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch _ {
        }
    }
    
    // MARK:- PrepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "edit" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let taskController: EditAccount = segue.destinationViewController as! EditAccount
            let task: Users = fetchedResultController.objectAtIndexPath(indexPath!) as! Users
            taskController.username = task.nickname
            taskController.passwd = task.password
        }
    }
    
    // MARK:- Retrieve Tasks
    
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Users")
        let sortDescriptor = NSSortDescriptor(key: "nickname", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = fetchedResultController.sections?.count
        return numberOfSections!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let task = fetchedResultController.objectAtIndexPath(indexPath) as! Users
        cell.textLabel?.text = task.nickname
        return cell
    }
    
    // MARK: - TableView Delete
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject:NSManagedObject = fetchedResultController.objectAtIndexPath(indexPath) as! NSManagedObject
        managedObjectContext.deleteObject(managedObject)
        do {
            try managedObjectContext.save()
        } catch _ {
        }
    }
    
    // MARK: - TableView Refresh
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
}