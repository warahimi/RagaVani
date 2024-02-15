//
//  CommunityDBHandler.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/12/23.
//

import SwiftUI

class DBErrors {
    static let logInError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "Not Logged In"])
    static let urlError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "URL Error"])
    static let networkError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "Netowork Error"])
    static let decodeError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "Decode Error"])
    static let httpError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "HTTP Error"])
}


class CommunityDBHandler : ObservableObject {
    static let shared = CommunityDBHandler()
    
    
    // function to get a user's all favorite ragas
    func getCreatedRagasForUser(for userId: String, completion: @escaping ((Result<[Raga], Error>)) -> Void) {
        // Forming the URL to get favorite ragas for a specific user
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_ragas"
        guard let url = URL(string: urlString) else {
            completion(.failure(DBErrors.urlError))
            return
        }
        
        // Data task to fetch data from API
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Ensure data is received, otherwise complete with an empty array
            guard let data = data, error == nil else {
                completion(.failure(DBErrors.networkError))
                return
            }
            
            // Attempt to decode received data as an array of Raga2
            let ragas = try? JSONDecoder().decode([Raga].self, from: data)
            
            // Complete with the decoded ragas, or an empty array if decoding fails
            completion(.success(ragas ?? []))
        }.resume()
    }
    
    // Function to fetch all recordings of a specific user.
    func getRecordingsForUser(for userId:String, completion: @escaping ([SavedRecording], Bool) -> Void) async {
        
        // Construct the URL string.
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/getAllMyRecordings/\(userId)"
        
        // Ensure the URL is valid.
        guard let url = URL(string: urlString) else {
            completion([], false)
            return
        }
        
        // Create a data task to fetch the data from the URL.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Ensure data is received.
            guard let data = data else {
                completion([], false)
                return
            }
            
            // Try to decode the data into [Recording].
            do {
                let decoder = JSONDecoder()
                let recordings = try decoder.decode([SavedRecording].self, from: data)
                completion(recordings, true)
            } catch {
                completion([], false)
            }
        }
        // Start the data task.
        task.resume()
    }
    
    // Function to fetch all public recordings of all users
    func getAllUserData(completion: @escaping ([DBUserData]) -> Void) {
        // API endpoint URL
        let url = URL(string: "https://us-central1-ragavaniauth.cloudfunctions.net/api/getUsers")!
        
        // Data task to fetch data from API
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Ensure data is received, otherwise complete with an empty array
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            if let rawResponseString = String(data: data, encoding: .utf8) {
                print("Received raw data: \(rawResponseString)")
            }
            
            // Attempt to decode received data as an array of UserRecordings
            let userRecordings = try? JSONDecoder().decode([DBUserData].self, from: data)
            
            // Complete with the decoded userRecordings, or an empty array if decoding fails
            completion(userRecordings ?? [])
        }.resume()
    }
}
