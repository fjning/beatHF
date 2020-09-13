//
//  DashboardViewController.swift
//  CardinalKit_Example
//
//  Created by Steve Derico on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import HealthKit
import ResearchKit
import Firebase

class DashboardViewController: UIViewController {

    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var beats = [Int]()
    var testWarning = false
    
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

    func here(){
        if let activity = StudyTableItem(rawValue: 0) {
            let myTitle = activity.title
            print("TITLE: \(myTitle)")
            let subtitle = activity.subtitle
            print("subtitle: \(subtitle)")
            let myImage = activity.image
            print("myImage: \(myImage)")
        }
    }
    
    func show(){
        DispatchQueue.main.async {
            let taskViewController: ORKTaskViewController
            taskViewController = ORKTaskViewController(task: StudyTasks.dailySurvey, taskRun: NSUUID() as UUID)
            taskViewController.delegate = self
            self.navigationController?.present(taskViewController, animated: true, completion: nil)
        }
    }

}

// MARK: - ORKTaskViewControllerDelegate
extension DashboardViewController : ORKTaskViewControllerDelegate {
    
    /**
     Handle what happens when an `ORKTaskViewController` finishes.
    */
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        
        var alertTitle = ""
        var alertMessage = ""
        
        let yellowMessage = "You should contact your doctor today".capitalized
        let orangeMessage = "You should contact your doctor right away".capitalized
        let redMessage = "Call 911 right away".capitalized
        
        // TODO: make configurable; document how files are sent and stored.
        let taskResults = taskViewController.result
        guard let results = taskResults.results else {
            return
        }
        
        for result in results {
            guard let stepResult = result as? ORKStepResult else {
              continue
            }
            guard let stepResults = stepResult.results else {
                continue
            }
            
            if stepResults.count == 0 {
              continue
            }

            guard let boolQuestionResult = stepResults[0] as? ORKBooleanQuestionResult else {
              continue
            }
            
            let identifier = boolQuestionResult.identifier
            let answer = boolQuestionResult.booleanAnswer!.boolValue
            print("\(identifier): \(answer)")
            
            if answer == true {
                if identifier == "activeQuestionStep" {
                    if alertMessage != redMessage && alertMessage != orangeMessage {
                        alertMessage = yellowMessage
                        alertTitle = "Code Yellow"
                    }
                } else if identifier == "restingQuestionStep" {
                    if alertMessage != redMessage {
                        alertMessage = orangeMessage
                        alertTitle = "Code Orange"
                    }
                } else if identifier == "awayQuestionStep" {
                    alertMessage = redMessage
                    alertTitle = "Code Red"
                } else if identifier == "gainedQuestionStep" {
                    if alertMessage != redMessage && alertMessage != orangeMessage {
                        alertMessage = yellowMessage
                        alertTitle = "Code Yellow"
                    }
                } else if identifier == "pillowsQuestionStep" {
                    if alertMessage != redMessage && alertMessage != orangeMessage {
                        alertMessage = yellowMessage
                        alertTitle = "Code Yellow"
                    }
                } else if identifier == "wakeQuestionStep" {
                    if alertMessage != redMessage {
                        alertMessage = orangeMessage
                        alertTitle = "Code Orange"
                    }
                } else if identifier == "passOutQuestionStep" {
                    alertMessage = redMessage
                    alertTitle = "Code Red"
                }

            }
                        
        }

        do {
            // (1) convert the result of the ResearchKit task into a JSON dictionary
            if let json = try CKTaskResultAsJson(taskViewController.result) {
            
                
                // (2) send using Firebase
                try CKSendJSON(json)
                
                // (3) if we have any files, send those using Google Storage
                if let associatedFiles = taskViewController.outputDirectory {
                    try CKSendFiles(associatedFiles, result: json)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // (4) we must dismiss the task when we are done with it, otherwise we will be stuck.
        taskViewController.dismiss(animated: true, completion: {
            if alertMessage != ""{
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
          
        })
    }
    
    /**
       Create an output directory for a given task.
       You may move this directory.
        
        - Returns: URL with directory location
       */
       func CKGetTaskOutputDirectory(_ taskViewController: ORKTaskViewController) -> URL? {
           do {
               let defaultFileManager = FileManager.default
               
               // Identify the documents directory.
               let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
               
               // Create a directory based on the `taskRunUUID` to store output from the task.
               let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
               try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
               
               return outputDirectory
           }
           catch let error as NSError {
               print("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
           }
           
           return nil
       }
       
       /**
        Parse a result from a ResearchKit task and convert to a dictionary.
        JSON-friendly.

        - Parameters:
           - result: original `ORKTaskResult`
        - Returns: [String:Any] dictionary with ResearchKit `ORKTaskResult`
       */
       func CKTaskResultAsJson(_ result: ORKTaskResult) throws -> [String:Any]? {
           let jsonData = try ORKESerializer.jsonData(for: result)
           return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
       }
       
       /**
        Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
       */
       func CKSendJSON(_ json: [String:Any]) throws {
           
           if  let identifier = json["identifier"] as? String,
               let taskUUID = json["taskRunUUID"] as? String,
               let authCollection = CKStudyUser.shared.authCollection,
               let userId = CKStudyUser.shared.currentUser?.uid {
               
               let dataPayload: [String:Any] = ["userId":"\(userId)", "payload":json]
               
               // If using the CardinalKit GCP instance, the authCollection
               // represents the directory that you MUST write to in order to
               // verify and access this data in the future.
               
               let db = Firestore.firestore()
               db.collection(authCollection + "\(Constants.dataBucketSurveys)").document(identifier + "-" + taskUUID).setData(dataPayload) { err in
                   
                   if let err = err {
                       print("Error writing document: \(err)")
                   } else {
                       // TODO: better configurable feedback via something like:
                       // https://github.com/Daltron/NotificationBanner
                       print("Document successfully written!")
                   }
               }
               
           }
       }
       
       /**
        Given a file, use the Firebase SDK to store it in Google Storage.
       */
       func CKSendFiles(_ files: URL, result: [String:Any]) throws {
           if  let identifier = result["identifier"] as? String,
               let taskUUID = result["taskRunUUID"] as? String,
               let stanfordRITBucket = CKStudyUser.shared.authCollection {
               
               let fileManager = FileManager.default
               let fileURLs = try fileManager.contentsOfDirectory(at: files, includingPropertiesForKeys: nil)
               
               for file in fileURLs {
                   
                   var isDir : ObjCBool = false
                   guard FileManager.default.fileExists(atPath: file.path, isDirectory:&isDir) else {
                       continue //no file exists
                   }
                   
                   if isDir.boolValue {
                       try CKSendFiles(file, result: result) //cannot send a directory, recursively iterate into it
                       continue
                   }
                   
                   let storageRef = Storage.storage().reference()
                   let ref = storageRef.child("\(stanfordRITBucket)\(Constants.dataBucketStorage)/\(identifier)/\(taskUUID)/\(file.lastPathComponent)")
                   
                   let uploadTask = ref.putFile(from: file, metadata: nil)
                   
                   uploadTask.observe(.success) { snapshot in
                       // TODO: better configurable feedback via something like:
                       // https://github.com/Daltron/NotificationBanner
                       print("File uploaded successfully!")
                   }
                   
                   uploadTask.observe(.failure) { snapshot in
                       print("Error uploading file!")
                       /*if let error = snapshot.error as NSError? {
                           switch (StorageErrorCode(rawValue: error.code)!) {
                           case .objectNotFound:
                               // File doesn't exist
                               break
                           case .unauthorized:
                               // User doesn't have permission to access file
                               break
                           case .cancelled:
                               // User canceled the upload
                               break
                               
                               /* ... */
                               
                           case .unknown:
                               // Unknown error occurred, inspect the server response
                               break
                           default:
                               // A separate error occurred. This is a good place to retry the upload.
                               break
                           }
                       }*/
                   }
                   
               }
           }
       }
    
}
