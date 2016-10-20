//
//  ViewController.swift
//  Walkr
//
//  Created by Jerry on 10/18/16.
//  Copyright © 2016 HMX Roaring Robots. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class ViewController: UIViewController {

    
    @IBOutlet weak var stepCountLabel: UILabel!
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    let stepsCount = HKQuantityType.quantityTypeForIdentifier(
        HKQuantityTypeIdentifierStepCount)
    
    let dataTypesToWrite = NSSet(object: stepsCount)
    let dataTypesToRead = NSSet(object: stepsCount)
    
    healthStore?.requestAuthorizationToShareTypes(dataTypesToWrite,
    readTypes: dataTypesToRead,
    completion: { [unowned self] (success, error) in
    if success {
    println("SUCCESS")
    } else {
    println(error.description)
    }
    })

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func updateStepCount() {}
    
    func checkAuthorization() -> Bool {
        var isEnabled = true
        if HKHealthStore.isHealthDataAvailable() {
            let healthKitTypesToRead : Set = [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.stepCount)!,
                HKObjectType.workoutType()]
            healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead, completion: { (success, error) in
                isEnabled = success
            })
        } else {
            isEnabled = false
        }
        return isEnabled
    }
    
    func recentSteps(completion: @escaping (Double, NSError?) -> () ) {
        let healthKitTypesToRead = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let yesterday = Date().addingTimeInterval(-86400)
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: Date(), options: [])
        let query = HKSampleQuery(sampleType: healthKitTypesToRead!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            if (results?.count)! > 0 {
                for result in results as! [HKQuantitySample] {
                    if(result.device?.model != "iPhone") {
                        steps += result.quantity.doubleValue(for: HKUnit.count())
                    }
                }
            }
            
        }
        healthKitStore.execute(query)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

