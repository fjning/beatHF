//
//  HeartRateReview.swift
//  CardinalKit_Example
//
//  Created by Steve Derico on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import HealthKit
import ResearchKit
import Firebase

class HeartRateReview: UIViewController {

    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var beats = [Int]()
    var testWarning = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.noticeLabel.text = "Your heart rate over the last 24 hours is normal".capitalized
         self.imageView.tintColor = .green
         self.imageView.image = UIImage.init(systemName: "checkmark.circle.fill")
         }
        
        if self.testWarning == true {
            self.showWarning()
        }
        
        self.getHeartRate { (samples) in
            
            guard let samples = samples else {
              return
            }

            for sample in samples {
               
                let heartRateUnit = HKUnit(from: "count/min")
                let heartRateDouble = sample.quantity.doubleValue(for: heartRateUnit)
                let heartRate = Int(heartRateDouble)
                self.beats.append(heartRate)
                
                print("heartRate: \(heartRate)")
                
                if heartRate < 40 || heartRate > 120 {
                    print("WARNING!")
                   
                    self.showWarning()
                    
                    break
                }
                
            }
        }
        
    }
    
    func showWarning(){
        DispatchQueue.main.async {
                               self.noticeLabel.text = "Call Your Doctor Right Away.".capitalized
                               self.imageView.tintColor = .red
                               self.imageView.image = UIImage.init(systemName: "exclamationmark.triangle.fill")
                           }
    }
    
    public func getHeartRate(
      completion: @escaping (_ samples: [HKQuantitySample]?) -> Void) {

      guard let heartRateType = HKObjectType
        .quantityType(forIdentifier: .heartRate) else {
          completion(nil)
        return
      }

      let queryPredicate = HKQuery
        .predicateForSamples(
            withStart: Date().dayByAdding(-1),
          end: Date(),
          options: .strictEndDate)

      let sortKey = NSSortDescriptor(
        key: HKSampleSortIdentifierStartDate,
        ascending: false)

      let sampleQuery = HKSampleQuery(
        sampleType: heartRateType,
        predicate: queryPredicate,
        limit: Int(HKObjectQueryNoLimit),
        sortDescriptors: [sortKey]) { (_, results, error) in

          guard error == nil else {
            print("Error: \(error!.localizedDescription)")
            return
          }
            
          completion(results as? [HKQuantitySample])
      }

      let store = HKHealthStore()
      store.execute(sampleQuery)
    }

}
