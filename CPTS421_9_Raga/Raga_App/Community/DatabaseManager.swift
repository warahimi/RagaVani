//
//  DatabaseManager.swift
//  Raga_App
//
//  Created by Wahidullah Rahimi on 10/9/23.
//

import Foundation
import Foundation
import SwiftUI
import Firebase
import Combine

// Struct to match the response structure from the server
struct RecordingResponse: Codable {
  var message: String
  var recording: SavedRecording
}

// Struct to match the response structure from the server
struct RagaResponse: Codable {
  var message: String
  var raga: Raga
}

// Struct to match the response structure from the server
struct RagaDBResponse : Codable {
    var id: String
    var inputs: [Int]
    var samvadi: String
    var vadi: String
    var name: String
    var description: String
    var category: String
}

final class DatabaseManager:ObservableObject{
    static let shared = DatabaseManager()
    let logInError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "Not Logged In"])
    let urlError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "URL Error"])
    let networkError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "Netowork Error"])
    let decodeError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "Decode Error"])
    let httpError = NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "HTTP Error"])
    
    // Function to add a new Raga to the database through API call only Admin Users will be allowed to invoke this.
    func addRaga(raga: DBRaga) async {
        // API endpoint URL.
        let url = URL(string: "https://us-central1-ragavaniauth.cloudfunctions.net/api/ragas")!
        
        // Creating a mutable URL request with specified URL.
        var request = URLRequest(url: url)
        // Specifying the HTTP method used for the request: POST.
        request.httpMethod = "POST"
        // Indicating that the HTTP request body will be JSON.
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Encoding the Raga object into JSON and assigning it to the HTTP request body.
            let jsonData = try JSONEncoder().encode(raga)
            request.httpBody = jsonData
        } catch {
            // Handling any encoding errors.
            print("Error encoding raga: \(error)")
            return
        }
        
        do {
            // Making the API call and awaiting the response.
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Ensuring that the API responds with HTTP status code 201 (Created).
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("Invalid response: \(response)")
                return
            }
            
            // Decoding the received data back into a Raga object, if necessary.
            let addedRaga = try JSONDecoder().decode(DBRaga.self, from: data)
            print("Added raga: \(addedRaga)")
            
        } catch {
            // Handling any API call errors.
            print("Error making request: \(error)")
        }
    }
    
    
    // The function to fetch all ragas from ragas database by API call
    func fetchAllRagas(completion: @escaping ([Raga]) -> Void) {
        // API endpoint URL
        let url = URL(string: "https://us-central1-ragavaniauth.cloudfunctions.net/api/ragas")!
        
        // Data task to fetch data from API
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Ensure data is received, otherwise complete with an empty array
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            // Attempt to decode received data as an array of Raga
            let fetched = try? JSONDecoder().decode([RagaDBResponse].self, from: data)
            var ragas = [Raga]()
            
            if let fetchedRagas = fetched {
                for raga in fetchedRagas {
                    ragas.append(Raga(id: raga.id, userId: "RagaDB", inputs: raga.inputs, samvadi: raga.samvadi, vadi: raga.vadi, name: raga.name, description: raga.description, category: raga.category, is_public: true))
                }
                completion(ragas)
            }
            else {
                completion([])
            }
            // Complete with the decoded ragas, or an empty array if decoding fails
        }.resume()
    }
    
    // Function to get a user's favorite ragas from the favorite_ragas_from_ragas sub-collection
    func getSavedRagas(completion: @escaping ((Result<[Raga], Error>)) -> Void) {
        let id = try? UserManager.shared.getSignedInUserId()
        if id == nil {
            completion(.failure(logInError))
            return
        }
        
        let userId = id!
        
        // Forming the URL to get favorite ragas from favorite_ragas_from_ragas for a specific user
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_ragas_from_ragas"
        guard let url = URL(string: urlString) else {
            completion(.failure(urlError))
            return
        }
        
        // Data task to fetch data from API
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors first
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(self.networkError))
                return
            }
            //print(String(data:data!, encoding: .utf8)!)
            // Ensure data is received
            guard let data = data else {
                completion(.success([]))
                return
            }
//            print("------------------------------")
            print(String(data: data, encoding: .utf8) ?? "Invalid data")
//            print("------------------------------")


            do {
                // Decode the data
                let fetchedRagas = try JSONDecoder().decode([Raga?].self, from: data)
                let ragas: [Raga] = fetchedRagas.compactMap { $0 }
                
                completion(.success(ragas))
            } catch {
                completion(.failure(self.decodeError))
            }
        }.resume()
    }
    
    // function to get a user's all favorite ragas
    func getCreatedRagas(completion: @escaping ((Result<[Raga], Error>)) -> Void) {
        let id = try? UserManager.shared.getSignedInUserId()
        if id == nil {
            completion(.failure(self.logInError))
            return
        }
        
        let userId = id!
        
        // Forming the URL to get favorite ragas for a specific user
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_ragas"
        guard let url = URL(string: urlString) else {
            completion(.failure(self.urlError))
            return
        }
        
        // Data task to fetch data from API
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Ensure data is received, otherwise complete with an empty array
            guard let data = data, error == nil else {
                completion(.failure(self.networkError))
                return
            }
            
            // Attempt to decode received data as an array of Raga2
            let ragas = try? JSONDecoder().decode([Raga].self, from: data)
            
            // Complete with the decoded ragas, or an empty array if decoding fails
            completion(.success(ragas ?? []))
        }.resume()
    }
    
    func addRagaToSaved(raga: Raga, completion: @escaping (Result<Bool, Error>) -> Void) {
        print(raga.userId)
        print(raga.id)
        let id = try? UserManager.shared.getSignedInUserId()
        if id == nil {
            completion(.failure(self.logInError))
            return
        }
        
        let userId = id!
        // Constructing the API endpoint URL
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_raga_from_ragas/\(raga.userId)/\(raga.id)"
        guard let url = URL(string: urlString) else {
            completion(.failure(self.urlError))
            return
        }
        
        // Creating the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Starting the data task
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for the absence of error and presence of data
            guard error == nil, data != nil else {
                completion(.failure(self.networkError))
                return
            }

            // Check for a successful HTTP response
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(true))
            } else {
                let res = response as! HTTPURLResponse
                print(res.statusCode)
                print(res.description)
                
                completion(.failure(self.httpError))
            }
        }.resume()
    }
    
    // Function to add a favorite raga to a user's favorite_ragas sub-collection
    func addRagaToCreated(rag: Raga, completion: @escaping (Result<String, Error>) -> Void) {
        
        let id = try? UserManager.shared.getSignedInUserId()
        if id == nil {
            completion(.failure(self.logInError))
            return
        }
        
        let raga = DBRaga(category: rag.category, name: rag.name, inputs: rag.inputs, vadi: rag.vadi, samvadi: rag.samvadi, description: rag.description, is_public: rag.is_public)
        
        let userId = id!
        // Endpoint URL
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_raga"
        
        // Ensure the URL is valid
        guard let url = URL(string: urlString) else {
            completion(.failure(self.urlError))
            return
        }
        
        // Encode the raga object to JSON data
        guard let ragaData = try? JSONEncoder().encode(raga) else {
            completion(.failure(self.decodeError))
            return
        }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Specify the request type
        request.httpBody = ragaData  // Attach the encoded raga data as the HTTP request body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Specify content type in HTTP headers
        
        // Create a URLSession data task to handle the HTTP request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle the HTTP request response
            if let error = error {
                print(error.localizedDescription)
                // Handle error
                completion(.failure(self.networkError))
                return
            }
            
            // Check for successful HTTP status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
              // Handle success: Parse and return the added raga ID
              if let data = data,
                let ragaResponse = try? JSONDecoder().decode(RagaResponse.self, from: data) {
                  completion(.success(ragaResponse.raga.id))
              } else {
                  completion(.failure(self.decodeError))
              }
            } else {
                let httpResponse = response as! HTTPURLResponse
                print(httpResponse.statusCode)
              // Handle unexpected status code
                completion(.failure(self.httpError))
            }
        }
        
        // Start the data task
        task.resume()
    }
    
    // The function to delete a raga from a user's favorite list
    func deleteRagaFromCreated(raga: Raga, completion: @escaping (Result<Bool, Error>) -> Void) {
        let id = try? UserManager.shared.getSignedInUserId()
        if id == nil {
            completion(.failure(self.logInError))
            return
        }
        
        print(raga.id)
        let userId = id!
        // Construct the URL for the API endpoint
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_raga/\(raga.id)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(self.urlError))
            return
        }
        
        // Create the URL request with the DELETE method
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Make the API call using URLSession
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Ensure there's no error and we got a valid HTTP response
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(self.networkError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(self.httpError))
                return
            }
            print(httpResponse.statusCode)
            // Check the HTTP status code to determine the outcome of our request
            switch httpResponse.statusCode {
            case 200: // Success
                completion(.success(true))
            default: // Any other status code indicates an error
                let error = NSError(domain: "API Error", code: httpResponse.statusCode, userInfo: nil)
                print(error.localizedDescription)
                completion(.failure(self.httpError))
            }
            
        }.resume() // Start the API call
    }
    
    // deletes raga from saved ragas
    func deleteRagaFromSaved(raga: Raga, completion: @escaping (Result<Bool, Error>) -> Void) {
        let id = try? UserManager.shared.getSignedInUserId()
        if id == nil {
            completion(.failure(self.logInError))
            return
        }
        
        let userId = id!
        
        // Construct the URL for the API call
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_ragas_from_ragas/\(raga.id)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL format.")
            completion(.failure(self.urlError))
            return
        }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Start the network task
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors and valid HTTP response
            if let error = error {
                print("Error occurred: \(error)")
                completion(.failure(self.networkError))
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(.success(true))
                } else {
                    if let data = data, let errorMsg = String(data: data, encoding: .utf8) {
                        print("Error: \(errorMsg)")
                    } else {
                        print("HTTP Error: \(httpResponse.statusCode)")
                    }
                    completion(.failure(self.httpError))
                }
            } else {
                print("Unknown error or invalid response.")
                completion(.failure(self.httpError))
            }
        }.resume()
    }
    
    // Get version of a collection
    func getVersion(collectionName: String, completion: @escaping (Version?) -> Void) async {
        // The API endpoint
        let url = URL(string: "https://us-central1-ragavaniauth.cloudfunctions.net/api/versions/\(collectionName)")!
        
        // Create a data task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle the error case
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Handle the successful response case
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let versions = try decoder.decode([Version].self, from: data)
                    DispatchQueue.main.async {
                        completion(versions[0])
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
        
        // Start the data task
        task.resume()
    }
    
    /// This function is used to add a new version for a given collection to the backend.
    /// - Parameters:
    ///   - collectionName: The name of the collection for which the version is being added.
    ///   - version: The version string (e.g., "1.0.1") to add.
    func addVersion(collectionName: String, version: String) {
        
        // Base URL for the server API
        let baseURL = "https://us-central1-ragavaniauth.cloudfunctions.net/api/versions"
        
        // Create the URL object
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }
        
        // Define the request parameters and headers
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert the parameters into a JSON body
        let bodyData: [String: Any] = [
            "name": collectionName,
            "version": version
        ]
        
        // Convert the dictionary into Data
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        
        // Create a data task to handle the API call
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Print any errors if they occur
                print("Error:", error.localizedDescription)
                return
            }
            
            if let data = data {
                do {
                    // Parse and print the response from the server (if needed)
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print(jsonResponse)
                } catch {
                    print("Error parsing JSON:", error.localizedDescription)
                }
            }
        }.resume() // Start the task
    }
    
    // Function to fetch all recordings of a specific user.
    func getRecordings(completion: @escaping ([SavedRecording], Bool) -> Void) {
        guard let userId = getID() else {
            completion([], false)
            return
        }
        
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
                let recordings = try decoder.decode([UsernamelessRecording].self, from: data)
                var recs = [SavedRecording]()
                for rec in recordings {
                    recs.append(SavedRecording(id: rec.id, userId: userId, name: rec.name, isPublic: rec.isPublic, URL: rec.URL, date_created: rec.date_created, duration: rec.duration))
                }
                completion(recs, true)
            } catch {
                completion([], false)
            }
        }
        // Start the data task.
        task.resume()
    }
    
    // gets id of user
    func getID() -> String? {
        // get user
        let authUser = try? AutheticationManager.shared.getAuthenticatedUser()
        
        // check user valid
        if authUser == nil {
            return nil
        }
        
        // get id
        let userId = authUser!.uid
        
        return userId
    }
    
    // A function to perform API call to add recording.
    func addRecording(recording: SavedRecording, completion: @escaping (String, Bool) -> Void) {
        guard let userId = getID() else {
            completion(UUID().uuidString, false)
            return
        }
        
        let recording = DBRecording(name: recording.name, isPublic: recording.isPublic, URL: recording.URL, date_created: recording.date_created, duration: recording.duration)
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/recording"
        guard let url = URL(string: urlString) else {
            completion(UUID().uuidString, false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        // encoder.keyEncodingStrategy = .convertToSnakeCase // [Optional] if all keys conform to API's format.
        guard let jsonData = try? encoder.encode(recording) else {
            completion(UUID().uuidString, false)
            return
        }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(UUID().uuidString, false)
                return
            }
            
            if let error = error {
                print(error.localizedDescription)
                completion(UUID().uuidString, false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                completion(UUID().uuidString, false)
                return
            }
            
            if let rawResponseString = String(data: data, encoding: .utf8) {
                print("Received raw data: \(rawResponseString)")
            }
            // Attempt to decode the received data
            do {
              let recordingResponse = try JSONDecoder().decode(RecordingResponse.self, from: data)
              print("Recording saved successfully: \(recordingResponse.recording)")
                completion(recordingResponse.recording.id, true)
            } catch {
              // Handle decoding error
                print("Error decoding response: \(error.localizedDescription)")
                completion(UUID().uuidString, false)
            }
            
        }.resume()
    }
    
    // api call to remove recoding
    func removeRecording(id:String? = nil,recording: SavedRecording, completion: @escaping (Bool) -> Void) {
        var userId : String
        if id == nil {
            guard let id = getID() else {
                completion(false)
                return
            }
            userId = id
        }
        else {
            userId = id!
        }
        
        print(recording.id)
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/recording/\(recording.id)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
    
    func updateRecording(id:String? = nil,recording: SavedRecording, completion: @escaping (Bool) -> Void) {
        var userId : String
        if id == nil {
            guard let id = getID() else {
                completion(false)
                return
            }
            userId = id
        }
        else {
            userId = id!
        }
        
        print(recording.id)
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/updateRecording/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        // encoder.keyEncodingStrategy = .convertToSnakeCase // [Optional] if all keys conform to API's format.
        guard let jsonData = try? encoder.encode(recording) else {
            completion(false)
            return
        }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
    
    func updateCreatedRaga(id:String? = nil,raga: Raga, completion: @escaping (Bool) -> Void) {
        var userId : String
        if id == nil {
            guard let id = getID() else {
                completion(false)
                return
            }
            userId = id
        }
        else {
            userId = id!
        }
        
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/updateCreatedRaga/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        // encoder.keyEncodingStrategy = .convertToSnakeCase // [Optional] if all keys conform to API's format.
        guard let jsonData = try? encoder.encode(raga) else {
            completion(false)
            return
        }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
    
    func getFavoriteRecordings(id:String? = nil, completion: @escaping (Bool, [SavedRecording]) -> Void) {
        var userId : String
        if id == nil {
            guard let id = getID() else {
                completion(false, [])
                return
            }
            userId = id
        }
        else {
            userId = id!
        }
        
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_recordings"
        guard let url = URL(string: urlString) else {
            completion(false, [])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false, [])
                return
            }
            print(String(data:data!, encoding: .utf8)!)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print(httpResponse.statusCode)
                completion(false, [])
                return
            }
            
            let favoriteRecordings = try? JSONDecoder().decode(FavoriteRecordingResponse.self, from: data!)
            completion(true, favoriteRecordings?.recordings.compactMap { $0 } ?? [])
        }.resume()
    }
    
    func removeFavoriteRecording(id:String? = nil,recording: SavedRecording, completion: @escaping (Bool) -> Void) {
        var userId : String
        if id == nil {
            guard let id = getID() else {
                completion(false)
                return
            }
            userId = id
        }
        else {
            userId = id!
        }
        
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_recordings/12/\(recording.id)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        // encoder.keyEncodingStrategy = .convertToSnakeCase // [Optional] if all keys conform to API's format.
        guard let jsonData = try? encoder.encode(recording) else {
            completion(false)
            return
        }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { d, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            print(String(data:d!, encoding: .utf8)!)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                print(httpResponse.statusCode)
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
    
    func addFavoriteRecording(id:String? = nil,recording: SavedRecording, completion: @escaping (Bool) -> Void) {
        var userId : String
        if id == nil {
            guard let id = getID() else {
                completion(false)
                return
            }
            userId = id
        }
        else {
            userId = id!
        }
        
        print(recording.userId)
        let urlString = "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)/favorite_recordings/\(recording.userId)/\(recording.id)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        // encoder.keyEncodingStrategy = .convertToSnakeCase // [Optional] if all keys conform to API's format.
        guard let jsonData = try? encoder.encode(recording) else {
            completion(false)
            return
        }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { d, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            print(String(data:d!, encoding: .utf8)!)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                completion(false)
                
                return
            }
            completion(true)
        }.resume()
    }
}

struct FavoriteRecordingResponse : Decodable {
    var recordings : [SavedRecording?]
}
