//
//  PhoneController.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/9/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation

class PhoneController {
    class func makePhoneCall(phoneNumber: String) {
        let cleanNumber = cleanPhoneNumber(phoneNumber)
        let url:NSURL? = NSURL(fileURLWithPath: "tel://"+cleanNumber);
        if (url != nil) {
            println("Calling \(url!)")
            UIApplication.sharedApplication().openURL(url!);
        } else {
            println("Invalid phone #: \(phoneNumber) -> \(cleanNumber)")
        }
    }
    
    /** 
    * Remove (,),-,space and other non numeric characters from phone number
    */
    class func cleanPhoneNumber(phoneNumber: String) -> String {
        var cleaned: String = "";
        for (index, character) in enumerate(phoneNumber) {
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
            cleaned = "+1" + cleaned;  //TODO: hack, for now assume that local number = US number
        }
        return cleaned
    }
}