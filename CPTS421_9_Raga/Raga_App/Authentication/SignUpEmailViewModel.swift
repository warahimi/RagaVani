//
//  SignUpEmailViewModel.swift
//  
//
//  Created by Wahidullah Rahimi on 9/21/23.
//

import Foundation
import FirebaseAuth

@MainActor
final class SignUpEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var confirmPassword = ""
    @Published var doPasswordsMatch: Bool = true // Tracks whether passwords match
    @Published var shouldNavigate = false // To determine if the user should be navigated to the next view
    @Published var isEmailValid: Bool = true

    
    func checkPasswordsMatch() -> Bool {
        if password == confirmPassword {
            doPasswordsMatch = true
            return true
        } else {
            doPasswordsMatch = false
            confirmPassword = "" // Empty confirmPassword if they don't match
            return false
        }
    }
    
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty, password == confirmPassword else {
            print("Email, password is missing or password and confirm password do not match.")
            return
        }
        
        do {
            let authDataResult = try await AutheticationManager.shared.createUser(email: email, password: password)
            
            // Create the document for the new user in the users database
            try await UserManager.shared.createUser(auth: authDataResult,firstName: firstName,lastName: lastName)
        } catch let error as NSError {
            // Check if the error is due to email already in use
            if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                throw AuthError.emailAlreadyInUse
            } else {
                throw AuthError.unknownError
            }
        }
        
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        // A simple regex for basic email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// custom error type for Auth
enum AuthError: Error, LocalizedError {
    case emailAlreadyInUse
    case unknownError

    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
