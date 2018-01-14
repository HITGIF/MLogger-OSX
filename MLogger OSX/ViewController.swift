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
    
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSTextField!
    @IBOutlet weak var remember: NSButton!
    
    let separater = "&sp@li#t*"
    let file = "file.txt"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadPassword();
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func buttonHandler(_ sender: AnyObject) {
        
        let un = username.stringValue
        let pw = password.stringValue
        sendLoginPost(un: un, pw: pw);
        rememberPassword(un: un, pw: pw);
    }
    
    func sendLoginPost(un: String, pw: String) {
        
        var request = URLRequest(url: LOGIN_URL!)
        let postString = "une=" + un + "&passwd=" + pw +
            "&username=" + un + "&pwd=" + pw;
        
        request.httpBody = postString.data(using: String.Encoding.utf8);
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
        }
        task.resume()
    }
    
    private func loadPassword() {
        
        if let dir = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(file)
            let text: String
            
            //reading
            do {
                text = try String(contentsOf: path, encoding: String.Encoding.utf8)
                if(text.contains(separater)){
                    username.stringValue = text.components(separatedBy: separater)[0]
                    password.stringValue = text.components(separatedBy: separater)[1]
                }
            }
            catch {/* error handling here */}
        }
    }
    
    private func rememberPassword(un: String, pw: String){
        
        var text = ""
        if (remember.state == 1) {
            text = un + separater + pw
        } else {
            text = separater
        }
        
        if let dir = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(file)
            //writing
            do { try text.write(to: path, atomically: false, encoding: String.Encoding.utf8) }
            catch {/* error handling here */}
        }
    }
}
