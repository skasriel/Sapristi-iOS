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

class HTTPController {
    let BASE_URL = "http://lit-woodland-6706.herokuapp.com" //"http://localhost:5000" // 
    
    class func getInstance() -> HTTPController {
        return HTTPController() //for now just create a new instance, class variables not supported yet
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
                println("doRequest: url=\(urlPath) params=\(parameters)")
                println("doRequest: res=\(response) json=\(json) err=\(error)")
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
        print("Saved key: ") ; println(userDefaults.objectForKey("username") as? NSString)
    }
    
    class func cleanPhone(phone: String) -> String {
        var cleaned: String = "";
        for (index, character) in enumerate(phone) {
            if index>0 && character=="+" { // + only allowed as first character
                continue;
            } else if character != "+" && (character<"0" || character>"9") {
                continue; // skip all non numeric
            }
            cleaned.append(character);
        }
        if cleaned.startsWith("00") {
            cleaned = "+" + cleaned.substr("00".length)
        }
        if (!cleaned.startsWith("+")) {
            cleaned = "+1" + cleaned;  // hack, for now assume that local number = US number
        }
        return cleaned
    }
}