//
//  CarDetector.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/24/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation
import ObjectiveC

class CarDetector : NSObject, SOMotionDetectorDelegate { //CMMotionManager {
    lazy var motionDetector = SOMotionDetector.sharedInstance()
    
    override init() {
        super.init()
        motionDetector.delegate = self
        motionDetector.useM7IfAvailable = true
        motionDetector.startDetection()
    }
    
    /*func motionDetector(motionDetector: SOMotionDetector!, accelerationChanged acceleration: CMAcceleration) {
        println("acceleration changed \(acceleration)")
    }*/
    func motionDetector(motionDetector: SOMotionDetector!, locationChanged location: CLLocation!) {
        println("location changed \(location)")
    }
    func motionDetector(motionDetector: SOMotionDetector!, motionTypeChanged motionType: SOMotionType) {
        /*switch motionType {
        case SOMotionDetector.MotionTypeNotMoving:
            println("Motion Type = Not Moving")
            break
        case .MotionTypeWalking:
            println("Motion Type = Walking")
            break
        case .MotionTypeRunning:
            println("Motion Type = Running")
            break
        case .MotionTypeAutomotive:
            println("Motion Type = Driving")
            break
        }*/
        println("New motion type: \(motionType.value)")
    }

    /*
    //lazy var motionManager = CMMotionManager()
    init() {
        if motionManager.accelerometerAvailable {
            let queue = NSOperationQueue()
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler:
                {(data: CMAccelerometerData!, error: NSError!) in
                    println("X = \(data.acceleration.x)")
                    println("Y = \(data.acceleration.y)")
                    println("Z = \(data.acceleration.z)")
                }
            )
        } else {
            println("Accelerometer is not available")
        }
    }
    
    func isInCarBasedOnCoreMotion() -> Int {
        if !CMMotionActivityManager.isActivityAvailable() {
            // Not an M7 device, CoreMotion doesn't work
            return -1
        }
        //CMMotionManager.startAccelerometerUpdates(self)
        return 1
    }*/
}