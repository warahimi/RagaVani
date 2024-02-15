//
//  UserManager.swift
//  
//
//  Created by Wahidullah Rahimi on 9/21/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DatabaseUser{
    let userId: String
    let email: String?
    let dateCreate: Date?
    let firstName:String?
    let lastName:String?
}

//struct Recording {
//    let id: String
//    let name: String
//}

// Define a struct to model the recording data of the user
struct Recording2: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var is_public: Bool
    // Define coding keys to map JSON keys to struct properties.
    private enum CodingKeys: String, CodingKey {
        case id, name, is_public
    }
}

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
}

final class UserManager{
    
    static let shared = UserManager()
    //@Published var raga: RagaObject

    
    // geting the users collection
    private let usersCollection:CollectionReference = Firestore.firestore().collection("users")
    
    func getSignedInUserId() throws-> String
    {
        try AutheticationManager.shared.getAuthenticatedUser().uid
    }

    // geting specific user document
    private func userDocument(userId: String) -> DocumentReference{
        usersCollection.document(userId)
    }

    init(){
    }
    // create database
    func createUser(auth: AuthDataResultModel, firstName:String, lastName:String) async throws{
        // dict
        var userData:[String:Any] = [
            "user_id": auth.uid,
            "date_created": Timestamp(),
        ]
        if let email = auth.email{ // because email is optional
            userData["email"] = email
        }
        userData["first_name"] = firstName
        userData["last_name"] = lastName
        
        
        
        // creating the collection name users, where user id is the document id
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    // get the user from database by user id
    func getUser(userId:String) async throws -> DatabaseUser{
        //get a reference to the user document in the database
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        // geting the user info from snapshot in form of dictionary
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        // getting the values
        //let userId = data["user_id"]
        let email = data["email"] as? String
        let dateCreate = data["date_created"] as? Date
        let firstName = data["first_name"] as? String
        let lastName = data["last_name"] as? String
        
        // creating a DabaseUser from these data
        return DatabaseUser(userId: userId, email: email, dateCreate: dateCreate,firstName: firstName, lastName: lastName)
    }
    
    @discardableResult
    func getAuthUser() async -> DatabaseUser? {
        let authUser = try? AutheticationManager.shared.getAuthenticatedUser()
        
        if authUser == nil {
            return nil
        }
        
        let userId = authUser!.uid
        //get a reference to the user document in the database
        let snapshot = try? await Firestore.firestore().collection("users").document(userId).getDocument()
        
        if snapshot == nil {
            return nil
        }
        
        // geting the user info from snapshot in form of dictionary
        guard let data = snapshot!.data(), let userId = data["user_id"] as? String else {
            return nil
        }
        
        // getting the values
        //let userId = data["user_id"]
        let email = data["email"] as? String
        let dateCreate = data["date_created"] as? Date
        let firstName = data["first_name"] as? String
        let lastName = data["last_name"] as? String
        return DatabaseUser(userId: userId, email: authUser?.email, dateCreate: dateCreate,firstName: firstName, lastName: lastName)
        // creating a DabaseUser from these data
    }
}
