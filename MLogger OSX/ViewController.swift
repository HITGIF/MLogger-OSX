//
//  ViewController.swift
//  MLogger for MacOSX
//
//  Created by carbonyl on 2017-06-19.
//  Copyright © 2017 CarbonylGroup. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let LOGIN_URL = URL(string: "http://172.16.1.38/webAuth/");
    let userdefault = UserDefaults.standard
    
    var username = ""
    var password = ""
    
    @IBOutlet weak var version_label: NSTextField!
    @IBOutlet weak var username_field: NSTextField!
    @IBOutlet weak var password_field: NSTextField!
    @IBOutlet weak var remember_switch: NSButton!
    @IBOutlet weak var login_start_switch: NSButton!
    @IBOutlet weak var quit_success_switch: NSButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        version_label.stringValue = "Version: " + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        loadPassword();
        loadPref();
        enableAdvancedOptionsAccordingToRemember()
        loginOnStart();
    }
    
    @IBAction func buttonHandler(_ sender: AnyObject) {
        
        self.username = username_field.stringValue
        self.password = password_field.stringValue
        sendLoginPost();
        rememberPassword(state: remember_switch.state);
    }
    
    @IBAction func rememberHandler(_ sender: Any) {
        enableAdvancedOptionsAccordingToRemember()
    }
    
    @IBAction func loginStartSwitchHandler(_ sender: Any) {
        userdefault.set(login_start_switch.state, forKey: "loginOnStart")
    }
    
    @IBAction func quitSuccessHandler(_ sender: Any) {
        userdefault.set(quit_success_switch.state, forKey: "quitIfSuccess")
    }
    
    private func enableAdvancedOptionsAccordingToRemember() {
        if remember_switch.state == 0 {
            login_start_switch.isEnabled = false
            quit_success_switch.isEnabled = false
            userdefault.set(false, forKey: "loginOnStart")
            userdefault.set(false, forKey: "quitIfSuccess")
        } else {
            login_start_switch.isEnabled = true
            quit_success_switch.isEnabled = true
            userdefault.set(login_start_switch.state, forKey: "loginOnStart")
            userdefault.set(quit_success_switch.state, forKey: "quitIfSuccess")
        }
    }
    
    private func loadPref() {
        self.login_start_switch.state = userdefault.integer(forKey: "loginOnStart")
        self.quit_success_switch.state = userdefault.integer(forKey: "quitIfSuccess")
    }
    
    private func loadPassword() {
        
        self.username = userdefault.string(forKey: "username") ?? ""
        self.password = userdefault.string(forKey: "password") ?? ""
        username_field.stringValue = self.username
        password_field.stringValue = self.password
    }
    
    private func rememberPassword(state: Int){
        
        if (state == 1) {
            userdefault.set(self.username, forKey: "username")
            userdefault.set(self.password, forKey: "password")
        } else {
            userdefault.set("", forKey: "username")
            userdefault.set("", forKey: "password")
        }
    }
    
    private func loginOnStart() {
        
        if self.login_start_switch.isEnabled && login_start_switch.state == 1 {
            if self.username != "" && self.password != "" {
                sendLoginPost()
            }
        }
    }
    
    private func sendLoginPost() {
        
        var request = URLRequest(url: LOGIN_URL!)
        let postString = "une=" + self.username + "&passwd=" + self.password +
            "&username=" + self.username + "&pwd=" + self.password;
        
        let yesYouCanQuitOnSuccess = self.quit_success_switch.isEnabled && self.quit_success_switch.state == 1
        
        request.httpBody = postString.data(using: String.Encoding.utf8);
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("error=\(String(describing: error))")
                return
            } else {
                if (response as? HTTPURLResponse)?.statusCode == 200 {
                    let res = String(data: data!, encoding: .utf8)
                    if (res?.contains("认证成功！"))! {
                        if yesYouCanQuitOnSuccess {
                            NSApp.terminate(self)
                        } else {
                            print("success")
                        }
                    } else if (res?.contains("在您使用网络之前，需要进行验证"))! {
                        print("wrong password")
                    }
                }
            }
        }
        task.resume()
    }
}
