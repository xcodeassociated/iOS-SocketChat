//
//  ChatView.swift
//  ChatMe
//
//  Created by Janusz Majchrzak on 11/06/16.
//  Copyright © 2016 Janusz Majchrzak. All rights reserved.
//

import Foundation
import UIKit

class ChatView : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var tvMessageEditor: UITextView!
    
    var nickname: String!
    var chatMessages = [[String: AnyObject]]()
    var bannerLabelTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard")
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        swipeGestureRecognizer.delegate = self
        view.addGestureRecognizer(swipeGestureRecognizer)
        
        self.tvMessageEditor.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tblChat.delegate = self
        tblChat.dataSource = self
        tblChat.registerNib(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        tblChat.estimatedRowHeight = 90.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        tblChat.tableFooterView = UIView(frame: CGRectZero)
        
        tvMessageEditor.delegate = self
        tvMessageEditor.resignFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.chatMessages.append(messageInfo)
                self.tblChat.reloadData()
                self.scrollToBottom()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        if tvMessageEditor.text.characters.count > 0 {
            SocketIOManager.sharedInstance.sendMessage(tvMessageEditor.text!, withNickname: nickname)
            tvMessageEditor.text = ""
            tvMessageEditor.resignFirstResponder()
        }
    }
    
    func handleKeyboardDidShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                //conBottomEditor.constant = keyboardFrame.size.height
                view.layoutIfNeeded()
            }
        }
    }
    
    func handleKeyboardDidHideNotification(notification: NSNotification) {
        view.layoutIfNeeded()
    }
    
    func scrollToBottom() {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
            if self.chatMessages.count > 0 {
                let lastRowIndexPath = NSIndexPath(forRow: self.chatMessages.count - 1, inSection: 0)
                self.tblChat.scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
    func dismissKeyboard() {
        if tvMessageEditor.isFirstResponder() {
            tvMessageEditor.resignFirstResponder()
            
            SocketIOManager.sharedInstance.sendStopTypingMessage(nickname)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as! ChatCell
        
        let currentChatMessage = chatMessages[indexPath.row]
        let senderNickname = currentChatMessage["nickname"] as! String
        let message = currentChatMessage["message"] as! String
        let messageDate = currentChatMessage["date"] as! String
        
        if senderNickname == nickname {
            cell.lblChatMessage.textAlignment = NSTextAlignment.Right
            cell.lblMessageDetails.textAlignment = NSTextAlignment.Right
        }else{
            cell.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
        }
        
        cell.lblChatMessage.text = message
        cell.lblMessageDetails.text = "\(senderNickname.uppercaseString) @ \(messageDate)"
        
        cell.lblChatMessage.textColor = UIColor.darkGrayColor()
        
        return cell
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        //..
        var pointInTable:CGPoint = textView.superview!.convertPoint(textView.frame.origin, toView: tblChat)
        var contentOffset:CGPoint = tblChat.contentOffset
        contentOffset.y  = pointInTable.y
        if let accessoryView = textView.inputAccessoryView {
            contentOffset.y -= accessoryView.frame.size.height
        }
        tblChat.contentOffset = contentOffset
        
        return true
    }
    
    func keyboardWillBeHidden (notification: NSNotification){
        print("keyboard will be hidden")

    }
    
    func keyboardWasShown (notification: NSNotification){
        print("keyboard was shown")

    }
}