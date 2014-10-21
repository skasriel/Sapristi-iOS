//
//  SKMotionDetector.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 10/11/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit
import CoreMotion


//enum SKMotionType;
let MotionTypeNotMoving = 1
let MotionTypeWalking = 2
let MotionTypeRunning = 3
let MotionTypeDriving = 4
//enum SKMotionType;

typealias SKMotionType = Int

protocol SKMotionDetectorDelegate {
    func motionDetector(motionDetector: SKMotionDetector, motionTypeChanged motionType: SKMotionType)
}



var skMotionDetectorInstance: SKMotionDetector?


class SKMotionDetector: NSObject, CLLocationManagerDelegate {
    /*weak*/ var delegate: SKMotionDetectorDelegate?

    var locationManager: CLLocationManager?
    var motionManager: CMMotionManager?
    var motionActivityManager: CMMotionActivityManager?

    // Location
    var currentLocation: CLLocation?

    // Motion
    var motionType: SKMotionType?
    var previousMotionType: SKMotionType?
    var currentSpeed: Double = 0
    var acceleration: CMAcceleration?
    
    var isShaking: Bool = true
    var shakeDetectingTimer: NSTimer?
    

    
    class func getInstance() -> SKMotionDetector {
        if skMotionDetectorInstance == nil {
            skMotionDetectorInstance = SKMotionDetector()
        }
        return skMotionDetectorInstance!
    }
    
    override init() {
        super.init()
        
        motionManager = CMMotionManager()

        locationManager = CLLocationManager()
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.distanceFilter = kCLDistanceFilterNone
        locationManager!.delegate = self
        locationManager!.requestAlwaysAuthorization() // shows user dialog box requesting permissions
    }
    
    func startDetection() {
        locationManager!.startUpdatingLocation() //         locationManager!.startMonitoringSignificantLocationChanges()

        shakeDetectingTimer = NSTimer(timeInterval: 0.01, target: self, selector: Selector("detectShaking:"), userInfo: nil, repeats: true)
        
        motionManager!.startAccelerometerUpdatesToQueue(NSOperationQueue()) { (accelerometerData: CMAccelerometerData!, error: NSError!) -> Void in
            self.acceleration = accelerometerData.acceleration;
            self.calculateMotionType()
        }
        
        println("CMM? \(CMMotionActivityManager.isActivityAvailable())") // am I requesting permissions correctly here?
        if (useM7IfAvailable && CMMotionActivityManager.isActivityAvailable()) {
            if (motionActivityManager==nil) {
                println("create motion activity manager")
                motionActivityManager = CMMotionActivityManager()
            }
            println("here")
            
            motionActivityManager!.startActivityUpdatesToQueue(NSOperationQueue()) { (activity: CMMotionActivity!) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if activity.walking {
                        self.motionType = MotionTypeWalking
                    } else if activity.running {
                        self.motionType = MotionTypeRunning
                    } else if activity.automotive {
                        self.motionType = MotionTypeDriving
                    } else if activity.stationary || activity.unknown {
                        self.motionType = MotionTypeNotMoving;
                    }
            
                    // If type was changed, then call delegate method
                    if (self.motionType != self.previousMotionType) {
                        println("Motion Type changed to \(self.motionType), from \(self.previousMotionType)")
                        self.previousMotionType = self.motionType
                        if let delegate = self.delegate {
                            println("Calling motionDetector callback because of CMM with \(self.motionType!)")
                            delegate.motionDetector(self, motionTypeChanged: self.motionType!)
                        }
                    }
                })
            }
        }
    }
    
    func stopDetection() {
        shakeDetectingTimer!.invalidate()
        shakeDetectingTimer = nil
        
        locationManager!.stopUpdatingLocation() //         locationManager!.stopMonitoringSignificantLocationChanges()
        motionManager!.stopAccelerometerUpdates()
        motionActivityManager!.stopActivityUpdates()
    }
    
    func calculateMotionType() {
        if (useM7IfAvailable && CMMotionActivityManager.isActivityAvailable()) {
            return
        }
    
        //println("currentSpeed = \(currentSpeed)")
        if (currentSpeed < kMinimumSpeed) {
            motionType = MotionTypeNotMoving
        } else if (currentSpeed <= kMaximumWalkingSpeed) {
            motionType = MotionTypeWalking //isShaking ? MotionTypeRunning : MotionTypeWalking
        } else if (currentSpeed <= kMaximumRunningSpeed) {
            motionType = MotionTypeRunning //isShaking ? MotionTypeRunning : MotionTypeDriving
        } else {
            motionType = MotionTypeDriving
        }
    
        // If type was changed, then call delegate method
        if (motionType != previousMotionType) {
            previousMotionType = motionType
            dispatch_async(dispatch_get_main_queue(), {
                if let delegate = self.delegate {
                    delegate.motionDetector(self, motionTypeChanged: self.motionType!)
                }
            })
        }
    }
    
    /**
    * CLLocatiomManager Delegate functions
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]! ) {
        var location: CLLocation = locations.last! as CLLocation
        currentLocation = location
        currentSpeed = currentLocation!.speed
        if currentSpeed < 0 {
            currentSpeed = 0
        }
        calculateMotionType()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithErrors error: NSError!) {
        println("SKLocationManager:error \(error.localizedDescription)")
    }
    
    // callback after requesting authorization from user
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("LocationManager auth status = \(status)")
    }

    
    /** 
    * Shake detection code - to correct motion type if phone is shaking
    */
    //Array for collecting acceleration for last one second period.
    var shakeDataForOneSec: [CMAcceleration]?
    
    //Counter for calculating completion of one second interval
    var currentFiringTimeInterval: Double = 0.0
    
    func detectShaking() {
        println("Detect shaking")
        currentFiringTimeInterval += 0.01
        if (currentFiringTimeInterval < 1.0) {
            if shakeDataForOneSec == nil {
                shakeDataForOneSec = [CMAcceleration]()
            }
    
            // Add current acceleration to array
            let boxedAcceleration = CMAcceleration(x: acceleration!.x, y: acceleration!.y, z: acceleration!.z)
            shakeDataForOneSec!.append(boxedAcceleration)
        } else {
            // Now, when one second was elapsed, calculate shake count in this interval. If the will be at least one shake then we'll determine it as shaked in all this one second interval
            var shakeCount = 0
            for boxedAcceleration in shakeDataForOneSec! {
                // Detecting shaking
                let accX_2 = boxedAcceleration.x * boxedAcceleration.x
                let accY_2 = boxedAcceleration.y * boxedAcceleration.y
                let accZ_2 = boxedAcceleration.z * boxedAcceleration.z
                let vectorSum = sqrt(accX_2 + accY_2 + accZ_2)
                if (vectorSum >= kMinimumRunningAcceleration) {
                    shakeCount++
                }
            }
            isShaking = shakeCount > 0
            shakeDataForOneSec = nil
            currentFiringTimeInterval = 0.0
        }
    }

    
    
    /**
    * Set this parameter to YES if you want to use M7 chip to detect more exact motion type.
    * Set this parameter before calling startDetection method.
    * Available only on devices that have M7 chip. At this time only the iPhone 5S, the iPad Air and iPad mini with retina display have the M7 coprocessor.
    */
    var useM7IfAvailable = true // NS_AVAILABLE_IOS(7_0);
    
    
    /**
    *@param speed  The minimum speed value less than which will be considered as not moving state
    */
    func setMinimumSpeed(speed: Double) {
        kMinimumSpeed = speed
    }
    
    /**
    *@param speed  The maximum speed value more than which will be considered as running state
    */
    func setMaximumWalkingSpeed(speed: Double) {
        kMaximumWalkingSpeed = speed
    }
    
    /**
    *@param speed  The maximum speed value more than which will be considered as driving state
    */
    func setMaximumRunningSpeed(speed: Double) {
        kMaximumRunningSpeed = speed
    }
    /**
    *@param acceleration  The minimum acceleration value less than which will be considered as non shaking state
    */
    func setMinimumRunningAcceleration(acceleration: Double) {
        kMinimumRunningAcceleration = acceleration
    }
    
    var kMinimumSpeed = 0.3
    var kMaximumWalkingSpeed = 1.9
    var kMaximumRunningSpeed = 7.5
    var kMinimumRunningAcceleration = 3.5
}



