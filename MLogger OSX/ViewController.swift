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
    
    var key = 0
    var authError: NSError?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        version_label.stringValue = "Version: " + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        loadPassword();
        loadPref();
        enableAdvancedOptionsAccordingToRemember()
        loginOnStart();
    }
    
    @IBAction func loginButtonHandler(_ sender: AnyObject) {
        
        if self.username == "" || username_field.stringValue.starts(with: "###") {
            self.username = String(username_field.stringValue.dropFirst(3))
        }
        self.password = password_field.stringValue
        sendLoginPost();
        rememberPassword(state: remember_switch.state);
    }
    
    @IBAction func restartButtonHandler(_ sender: Any) {
        if let path = Bundle.main.resourceURL?.deletingLastPathComponent().deletingLastPathComponent().absoluteString {
            NSLog("restart \(path)")
            _ = Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [path])
            NSApp.terminate(self)
        }
    }
    
    @IBAction func rememberHandler(_ sender: Any) {
        enableAdvancedOptionsAccordingToRemember()
    }
    
    @IBAction func loginStartSwitchHandler(_ sender: Any) {
        userdefault.set(login_start_switch.state, forKey: "loginOnStart")
        key += 1
        if key == 10 {
            popTeamEpic();
            key = 0
        }
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
        
        self.username = userdefault.string(forKey: "safe_username") ?? ""
        self.password = userdefault.string(forKey: "password") ?? ""
        username_field.stringValue = self.username
        password_field.stringValue = self.password
    }
    
    private func rememberPassword(state: Int){
        
        if (state == 1) {
            userdefault.set(self.password, forKey: "password")
        } else {
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
        let u = userdefault.string(forKey: "username") ?? self.username
        let p = userdefault.string(forKey: "username") ?? self.password
        let postString = "une=" + u + "&passwd=" + self.password +
            "&username=" + p + "&pwd=" + self.password;
        
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
                    if (res?.contains("认证成功！"))! || (res?.contains("已登录"))! {
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
    
    private func popTeamEpic() {
        
        let msg = NSAlert()
        msg.addButton(withTitle: "NAÏVE!")
        msg.addButton(withTitle: "キャンセル")
        msg.messageText = "プライベート"
        msg.informativeText = "これは安全です"
        
        let textsView = NSView(frame: NSRect(x: 0, y: 0, width: 250, height: 48))
        let safeT = NSTextView(frame: NSRect(x: 0, y: 0, width: 50, height: 24))
        let truT = NSTextView(frame: NSRect(x: 0, y: 24, width: 50, height: 24))
        safeT.string = "セーブ:"
        truT.string = "真実:"
        safeT.backgroundColor = NSColor.clear
        truT.backgroundColor = NSColor.clear
        let safe = NSTextField(frame: NSRect(x: 50, y: 0, width: 200, height: 24))
        safe.stringValue = userdefault.string(forKey: "safe_username") ?? ""
        let tru = NSTextField(frame: NSRect(x: 50, y: 24, width: 200, height: 24))
        tru.stringValue = userdefault.string(forKey: "username") ?? ""
        textsView.addSubview(safe)
        textsView.addSubview(tru)
        textsView.addSubview(safeT)
        textsView.addSubview(truT)
        msg.accessoryView = textsView
        
        let response: NSModalResponse = msg.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            userdefault.set(safe.stringValue, forKey: "safe_username")
            userdefault.set(tru.stringValue, forKey: "username")
        }
    }
}
