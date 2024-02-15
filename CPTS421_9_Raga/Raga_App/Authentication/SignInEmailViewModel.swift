//
//  SignInEmailViewModel.swift
//  
//
//  Created by Wahidullah Rahimi on 9/21/23.
//

import Foundation
import SwiftUI
@MainActor
final class SignInEmailViewModel: ObservableObject{ 
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordCorrect: Bool = true
    
     //to call the sing
    func signIn() async throws{
        // validation
        guard !email.isEmpty, !password.isEmpty else{
            print("No email or password found")
            return
        }// make sure email and passord are not empty
        
        try await AutheticationManager.shared.singIn(email: email, password: password)
    }
}
