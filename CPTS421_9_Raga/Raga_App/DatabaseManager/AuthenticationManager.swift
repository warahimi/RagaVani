//
//  AuthenticationManager.swift
//  
//
//  Created by Wahidullah Rahimi on 9/20/23.
//


import Foundation
import FirebaseAuth

struct AuthDataResultModel{ // the user data return by Auth.auth().createUser in CreateUser() function
    let uid: String
    let email: String?
    let photoUrl: String?
    
//    init(uid: String, email: String?, photoUrl: String?) {
//        self.uid = uid
//        self.email = email
//        self.photoUrl = photoUrl
    
//    }
    init(user:User) // User comes from FirebaseAuth
    {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString 
    }
    
    
}

final class AutheticationManager{// final so other class cannot inherite from this
    static let shared = AutheticationManager() // single globle instance of this class, this will the only instance in the app
    
    private init(){
        
    }
    
    //Sing up function
    func createUser(email:String, password:String) async throws -> AuthDataResultModel{ // retun AuthDataResultModel to the app
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password) // returns a AuthResult 
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // Sing in
    @discardableResult
    func singIn(email:String, password:String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // get the authenticated user
    @discardableResult
    func getAuthenticatedUser() throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else{// user will be nill if the user is not authenticated otherwise we will its information
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    // Reset password
    func resetPassword(emial: String) async throws{
        try await Auth.auth().sendPasswordReset(withEmail: emial)
    }
    
    // Update password within the app
    func updatePassword(password:String) async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    // Update email within the app
    func updateEmail(email:String) async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: email)
    }
    
    func signOut() throws{ // if did not throw an error means the user is successfully signed out
        try Auth.auth().signOut()
    }
    
    func deleteUser() async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badURL)
        }
        try await user.delete()
    }
}
