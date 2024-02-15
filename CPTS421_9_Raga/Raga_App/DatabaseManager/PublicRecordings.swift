//
//  PublicRecordings.swift
//  Raga_App
//
//  Created by Wahidullah Rahimi on 10/11/23.
//

import Foundation

struct DBTimeStamp : Codable {
    var seconds : Int
    var nanoseconds : Int
    
    enum CodingKeys : String, CodingKey {
        case seconds = "_seconds", nanoseconds = "_nanoseconds"
    }
}

struct User2: Identifiable, Decodable {
    var id: String
    var user_id : String
    var lastName: String
    var firstName: String
    var email: String
    var date_created : DBTimeStamp
    
    enum CodingKeys: String, CodingKey {
        case id, user_id, lastName = "last_name", firstName = "first_name", email, date_created
    }
}


struct DBUserData : Decodable, Equatable, Identifiable {
    static func == (lhs: DBUserData, rhs: DBUserData) -> Bool {
        return lhs.user.id == rhs.user.id
    }
    
    var user: User2
    var recordings: [SavedRecording]
    var favoriteRagas : [Raga]
    
    var id : String {
        return user.id
    }
}
