//
//  ViewController.swift
//  ChatMe
//
//  Created by Janusz Majchrzak on 11/06/16.
//  Copyright © 2016 Janusz Majchrzak. All rights reserved.
//

import UIKit

class User : UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var driver: CoreDataDriver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable segue loops (login -> usersView -> login -> ... )
        self.navigationItem.hidesBackButton = true;
        
        if self.driver == nil{
            self.driver = CoreDataDriver()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func authorize(userName: String?, passwd: String?) -> Bool {
        let result: (Bool, Bool) = self.driver!.checkUser(userName, passwd: passwd)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.username.text! = ""
            self.password.text! = ""
        }
        
        var allert: UIAlertController?
        
        if result.0 == false{
            allert = UIAlertController(title: "Error", message: "Please enter correct username & password !", preferredStyle: UIAlertControllerStyle.Alert)
            
        }else if result.0 == true && result.1 == false{
            allert = UIAlertController(title: "Error", message: "If you forgot a password please create a new user with the same username.", preferredStyle: UIAlertControllerStyle.Alert)
            
        }else if result.0 == true && result.1 == true{
            return true
        }
        
        allert!.addAction(ok)
        self.presentViewController(allert!, animated: true, completion: nil)
        print(">>   Incorrect login!")

        return false;
    }
    
    @IBAction func loginPushed(sender: AnyObject) {
        if self.authorize(self.username.text!, passwd: self.password.text!){
            self.performSegueWithIdentifier("login", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "login"{
            print(">>   Login succes! Nickname: \(self.username.text!)")
            let dest = segue.destinationViewController as! UsersView
            dest.nickname = self.username.text!
        }
    }

}

