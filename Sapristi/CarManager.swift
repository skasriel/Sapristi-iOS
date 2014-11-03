//
//  CCarManager.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/24/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation
import ObjectiveC

var carManagerInstance: CarManager?

class CarManager : NSObject, SKMotionDetectorDelegate, HTTPControllerProtocol {
    lazy var motionDetector = SKMotionDetector.getInstance()
    
    var currentMotionType: SKMotionType = MotionTypeNotMoving
    let availabilityManager = AvailabilityManager.getInstance()
    
    init(requestPermissions: Bool) {
        super.init()
        println("Init CarManager requestPermissions = \(requestPermissions)")
        motionDetector.delegate = self
        motionDetector.startDetection()
    }
    
    class func start(requestPermissions: Bool) -> CarManager {
        if carManagerInstance == nil {
            carManagerInstance = CarManager(requestPermissions: requestPermissions)
        }
        return carManagerInstance!
    }
    
    class func stop() {
        if carManagerInstance == nil {
            return
        }
        carManagerInstance!.motionDetector.stopDetection()
    }
    
    func motionDetector(motionDetector: SKMotionDetector, motionTypeChanged motionType: SKMotionType) {
        println("New motion type: \(motionType)")
        let oldMotionType = currentMotionType
        currentMotionType = motionType
        if currentMotionType != oldMotionType && (currentMotionType == MotionTypeDriving || oldMotionType == MotionTypeDriving) {
            let httpParams = ["oldMotionType": oldMotionType, "newMotionType": currentMotionType]
            let url = "/api/me/motion"
            HTTPController.getInstance().doPOST(url, parameters: httpParams, delegate: self, queryID: "UPDATE_MOTION")
        }
        /*if motionType == MotionTypeDriving {
            availabilityManager.setAvailability(Availability.Available, updateServer: true, reason: Reason.CarMotion, delegate: self)
        } else if oldMotionType == MotionTypeDriving && currentMotionType != MotionTypeDriving {
            //TODO: tell server to figure out new availability - user is not in a car anymore, so need to figure out what availability to revert to
            availabilityManager.setAvailability(Availability.Unknown, updateServer: true, reason: Reason.CarMotion, delegate: self)
        }*/
    }
    
    func didReceiveAPIResults(err: NSError?, queryID: String?, results: AnyObject?) {
        if let error = err {
            println("Unable to update availability from CarManager \(error.localizedDescription)")
            return
        }
        
        let json = results! as Dictionary<String, AnyObject>
        let availability = json["availability"]! as String
        let availabilityCode: Availability? = AvailabilityManager.getAvailabilityFromString(availability)
        if (availabilityCode == nil) {
            println("Invalid availability code from server: \(availability)")
            return
        }
        let reason = json["reason"]! as String
        let reasonCode: Reason? = AvailabilityManager.getReasonFromString(reason)
        availabilityManager.setAvailability(availabilityCode!, reason: reasonCode, updateServer: false, delegate: nil)
    }
}