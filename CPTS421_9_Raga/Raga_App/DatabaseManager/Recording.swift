//
//  Recording.swift
//  Raga_App
//
//  Created by Wahidullah Rahimi on 10/10/23.
//

import Foundation
import FirebaseStorage

class RecordingDBHandler : ObservableObject {
    static let shared = RecordingDBHandler()
    private let storage = Storage.storage()
    
    // downloads url from firestore
    func downloadURL(id : String) async {
        // get ref to storage
        let ref = storage.reference()
        let recordingRef = ref.child("Recordings")
        
        // get files
        let files = RecordingHandler.getFiles()
        let fileURL = recordingRef.child(id + ".caf")
        
        let contain = files.contains { file in
            return file.absoluteString.contains(id)
        }
        
        // dont download if contain file
        if contain {
            return
        }
        
        // get data
        fileURL.getData(maxSize: 100 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                try? data?.write(to: RecordingHandler.getRecordingPath().appending(path: id))
            }
        }.resume()
    }
    
    // downloads url from firestore into online folder
    func downloadOnlineFile(url : String, completion: @escaping (Bool) -> Void) {
        // get ref to recording folder in db
        let ref = storage.reference()
        let recordingRef = ref.child("Recordings")
        
        // get files
        let files = RecordingHandler.getOnlineFiles()
        let fileURL = recordingRef.child(url + ".caf")
        
        let contain = files.contains { file in
            return file.absoluteString.contains(url)
        }
        
        // check contains file
        if contain {
            completion(false)
            return
        }
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        
        fileURL.getData(maxSize: 1000 * 1024 * 1024) { data, error in
          if let error = error {
              print(error.localizedDescription)
            completion(false)
          } else {
              try? data?.write(to: RecordingHandler.getTempRecordingPath().appending(path: url + ".caf"))
              
              completion(true)
          }
        }.resume()
    }
    
    // downloads url from firestore into online folder
    func downloadUserFile(url : String, completion: @escaping (Bool) -> Void) {
        // get ref to recording folder in db
        let ref = storage.reference()
        let recordingRef = ref.child("Recordings")
        
        // get files
        let files = RecordingHandler.getFiles()
        let fileURL = recordingRef.child(url + ".caf")
        
        let contain = files.contains { file in
            return file.absoluteString.contains(url)
        }
        
        // check contains file
        if contain {
            completion(false)
            return
        }
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        
        fileURL.getData(maxSize: 1000 * 1024 * 1024) { data, error in
          if let error = error {
              print(error.localizedDescription)
            completion(false)
          } else {
              try? data?.write(to: RecordingHandler.getRecordingPath().appending(path: url + ".caf"))
              
              completion(true)
          }
        }.resume()
    }
    
    // remove url from firestore
    func removeRecording(recording:SavedRecording, url:URL, completion: @escaping (Bool) -> Void) {
        // get ref to file
        let ref = storage.reference()
        let recordingRef = ref.child("Recordings/" + recording.URL + ".caf")
        
        // delete file task
        recordingRef.delete { error in
            if error != nil {
                completion(false)
            }
            completion(true)
        }
    }
    
    // upload url to firestore
    func uploadRecording(recording:SavedRecording, url:URL, completion: @escaping (Bool) -> Void) {
        // get ref to file
        let ref = storage.reference()
        let recordingRef = ref.child("Recordings/" + recording.URL + ".caf")
        
        // Upload the file to the path
        recordingRef.putFile(from:url, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                // Uh-oh, an error occurred!
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
}
