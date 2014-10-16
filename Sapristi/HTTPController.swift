//
//  HTTPController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/17/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import Alamofire

protocol HTTPControllerProtocol {
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject? /*NSDictionary?*/)
}

let httpControllerInstance = HTTPController()

class HTTPController {
    let BASE_URL = "http://lit-woodland-6706.herokuapp.com" //"http://localhost:5000" //"http://169.254.124.168:5000" //  
    
    class func getInstance() -> HTTPController {
        return httpControllerInstance
    }
    
    private init() {
        /*
        let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist")
        let config:NSDictionary = NSDictionary(contentsOfFile:path)
        host = config.objectForKey("host") as String
        */
    }
    
    class func JSONStringify(jsonObj: AnyObject) -> String {
        var e: NSError?
        let jsonData: NSData! = NSJSONSerialization.dataWithJSONObject(
            jsonObj,
            options: NSJSONWritingOptions(0),
            error: &e)
        if e != nil {
            println("Error parsing json \(jsonObj)")
            return ""
        } else {
            return NSString(data: jsonData, encoding: NSUTF8StringEncoding)
        }
    }

   
    /*
    * @queryID is a way for the delegate to know which response it's receiving (useful when a class is a delegate for multiple different HTTP requests
    */
    private func doRequest(urlPath: String, method: Alamofire.Method, parameters: [String: AnyObject]? = nil, delegate: HTTPControllerProtocol?, queryID: String?) {
        let absoluteURL = BASE_URL + urlPath
        Alamofire.request(method, absoluteURL, parameters: parameters)
            .responseJSON { (request, response, json, error) in
                //println("doRequest: url=\(urlPath) params=\(parameters)")
                //println("doRequest: res=\(response) json=\(json) err=\(error)")
                /*if let jsonNSArray = json as NSArray {
                } else if let jsonNSDictionary = json as NSDictionary {
                    
                } else {
                    println("Don't know how to deserialize \(json)");
                    delegate.didReceiveAPIResults(error, queryID: queryID, results: )
                }
                var jsonDic: Dictionary<String, AnyObject>?
                if (error == nil) {
                    jsonDic = json as Dictionary<String, AnyObject>!
                }*/
                if (delegate != nil) {
                    delegate!.didReceiveAPIResults(error, queryID: queryID, results: json)
                }
        }
    }
    
    func doGET(urlPath: String, parameters: [String: AnyObject]? = nil, delegate: HTTPControllerProtocol?, queryID: String?) {
        doRequest(urlPath, method:.GET, parameters: parameters, delegate: delegate, queryID: queryID)
    }
    
    func doPOST(urlPath: String, parameters: [String: AnyObject]? = nil, delegate: HTTPControllerProtocol?, queryID: String?) {
        doRequest(urlPath, method:.POST, parameters: parameters, delegate: delegate, queryID: queryID)
    }
    
    func doLogin(delegate: HTTPControllerProtocol) {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        var username: NSString? = userDefaults.objectForKey("username") as NSString?
        let authToken: NSString? = userDefaults.objectForKey("authToken") as NSString?
        
        if username != nil && authToken != nil {
            var url = "/api/auth/login"
            if ((username! as String).indexOf("+")==0) { // hack until I upgrade to latest version of Alamofire, which properly encodes POST bodies
                username = "%2B" + username!.substringFromIndex(1)
            }
            var formData: [String: AnyObject] = [
                "username": username!,
                "password": authToken!
            ]
            println("Trying to log in as: \(username)");
            doPOST(url, parameters: formData, delegate: delegate, queryID: "LOGIN")
        } else {
            // no login data yet (first time use)
            let userInfo: [NSObject: AnyObject] = [NSLocalizedDescriptionKey: "no login"]
            let error: NSError = NSError(domain: "sapristi", code: -1, userInfo: userInfo)
            delegate.didReceiveAPIResults(error, queryID: "LOGIN", results: nil)
        }
    }
    
    func saveLogin(username: String, authToken: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(username as NSString, forKey: "username")
        userDefaults.setObject(authToken as NSString, forKey: "authToken")
        userDefaults.synchronize()
        //print("Saved key: ") ; println(userDefaults.objectForKey("username") as? NSString)
    }
    
    class func sendUserToSettings() {
        let alert = UIAlertController(title: "Permissions",
            message: "Please update permissions in the privacy section of this app’s settings.",
            preferredStyle: .Alert)
        
        let default_action = UIAlertAction(title: "Open Settings", style: .Default) { action in
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString))
            return
        }
        
        alert.addAction(default_action)
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().keyWindow.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
    }
}