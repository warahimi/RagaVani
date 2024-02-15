//
//  UIData.swift
//  Raga_App
//
//  Created by Aiden Walker on 4/5/23.
//

import SwiftUI

// contains all data used for main view and for raga
class UIData : ObservableObject {
    @Published var currentScene = "Play" //current scene being shown
    
    @Published var screenWidth =  UIScreen.main.bounds.width
    @Published var screenHeight =  UIScreen.main.bounds.height
    
    @Published var loggedIn = UIData.initalizeData(false, "Logged In") as! Bool
    
    @Published var currentEditor = "Swaras"
    
    @Published var currentRaga : String? = nil
    
    @Published var loadedRecordings = false
    
    @Published var showPopup = false
    @Published var popupText = ""
    
    @Published var showNav = true
    
    // get data from user defaults
    static func getData(_ type:Codable.Type,_ key:String) -> Any {
        let decoder = JSONDecoder()
        let data = UserDefaults.standard.data(forKey: key)!
        return try! decoder.decode(type, from: data)
    }
    
    // update user default
    static func updateData(_ data : Codable, key:String) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(data)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    // check if user default contains key
    static func containsData(_ key : String) -> Bool {
        return UserDefaults.standard.data(forKey: key) != nil
    }
    
    // initiaze user default, set default if nothing present
    static func initalizeData(_ initial: Codable, _ key:String) -> Any {
        // check to see if data needs to be set to default
        if !UIData.containsData(key) {
            UIData.updateData(initial, key: key)
        }
        
        // get type, data
        let t = type(of: initial).self
        let decoder = JSONDecoder()
        let data = UserDefaults.standard.data(forKey: key)!
        
        // try to decode data
        guard let data = try? decoder.decode(t, from: data) else {
            return initial
        }
        
        return data
    }
}
