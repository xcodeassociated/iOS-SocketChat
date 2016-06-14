//
//  UsersView.swift
//  ChatMe
//
//  Created by Janusz Majchrzak on 11/06/16.
//  Copyright © 2016 Janusz Majchrzak. All rights reserved.
//

import Foundation
import UIKit

class UsersView : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var usersTable: UITableView!
    
    var users = [[String: AnyObject]]()
    var nickname: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.usersTable.delegate = self
        self.usersTable.dataSource = self
        self.usersTable.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "idCellUser")
        self.usersTable.hidden = true
        self.usersTable.tableFooterView = UIView(frame: CGRectZero)
        
        print(">>   UsersView loaded with nickname: \(self.nickname) ")
        
        SocketIOManager.sharedInstance.connectToServerWithNickname(self.nickname, completionHandler: { (userList) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if userList != nil {
                    self.users = userList
                    self.usersTable.reloadData()
                    self.usersTable.hidden = false
                }
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! != "enterChat"{
            SocketIOManager.sharedInstance.exitChatWithNickname(nickname) { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.nickname = nil
                    self.users.removeAll()
                    self.usersTable.hidden = true
                })
            }
            
            print(">>   Logout")

        }else{
            let chatView = segue.destinationViewController as! ChatView
            chatView.nickname = self.nickname
        }

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellUser", forIndexPath: indexPath) as! UserCell
        
        cell.textLabel?.text = users[indexPath.row]["nickname"] as? String
        //cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
        cell.detailTextLabel?.text = ""
        cell.textLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.greenColor() : UIColor.redColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
}