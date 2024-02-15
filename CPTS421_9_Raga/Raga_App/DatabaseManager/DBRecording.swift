//
//  DBRecording.swift
//  Raga_App
//
//  Created by Wahidullah Rahimi on 10/10/23.
//

// A struct that represents a Recording object, conforming to Codable for easy encoding and decoding.
import Foundation
struct DBRecording: Encodable {
    var name: String
    var isPublic: Bool
    var URL: String // store the .mp3 file URL in Firebase Storage Database
    var date_created: String
    var duration:Double
    
    enum CodingKeys: String, CodingKey {
        case name
        case isPublic = "is_public"
        case URL = "URL"
        case date_created
        case duration
    }
}

