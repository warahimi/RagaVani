//
//  SettingsViewModel.swift
//  
//
//  Created by Wahidullah Rahimi on 9/21/23.
//

import Foundation
import Firebase
@MainActor
final class SettingsViewUserModel: ObservableObject{
    @Published var shouldNavigate = false // To determine if the user should be navigated to the next view
    
    // calls the logout function in our AutheticationManager
    func signOut() throws{
        try AutheticationManager.shared.signOut()
    }
    
    // reset password
    func resetPassword() async throws{
        let autUser = try AutheticationManager.shared.getAuthenticatedUser()
        guard let email = autUser.email else{
            throw URLError(.fileDoesNotExist)
        }
        try await AutheticationManager.shared.resetPassword(emial: email)
    }
    
    // update password
    func updatePassword(password:String) async throws{
        try await AutheticationManager.shared.updatePassword(password: password)
    }
    
    func updateEmail(email:String) async throws{
        try await AutheticationManager.shared.updateEmail(email: email)
    }
    
    func deleteUser() async throws{
        try await AutheticationManager.shared.deleteUser()
        shouldNavigate = true // Navigate to AuthenticationView after successful deletion

    }
    
    // Function to delete a user profile from "users" collection
    func deleteUserProfile(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Endpoint URL
        guard let url = URL(string: "https://us-central1-ragavaniauth.cloudfunctions.net/api/user/\(userId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Perform the network task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle any errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for successful HTTP status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(true))
            } else {
                print("Failed to deleted the user profile")
            }
        }
        
        // Start the data task
        task.resume()
    }
}

