//
//  DBRaga.swift
//  Raga_App
//
//  Created by Wahidullah Rahimi on 10/9/23.
//

import Foundation
// Model to represent a Raga, which conforms to Codable to facilitate easy encoding and decoding to/from JSON.
struct DBRaga: Codable {
    var category: String
    var name: String
    var inputs: [Int]
    var vadi: String
    var samvadi: String
    var description: String
    var is_public : Bool
}

// Raga Used for fetching Ragas from database
struct Raga: Identifiable, Codable, Equatable, Hashable {
    // Each raga has a unique ID
    var id: String
    var userId : String
    var inputs: [Int]
    var samvadi: String
    var vadi: String
    var name: String
    var description: String
    var category: String
    var is_public : Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
