//
//  UserData.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/7/23.
//

import Foundation
import AVFAudio
import SwiftUI

struct DatabaseTransaction : Codable {
    var command : String
    var collection : String
    var raga : Raga
}

struct SaveColor : Codable {
    var r : Double
    var b : Double
    var g : Double
}

class UserData : ObservableObject {
    @Published var audioSettings = AudioSettings()
    @Published var instrumentSettings = InstrumentSettings()
    @Published var uiSettings = UISettings()
    @Published var createdRagas : [Raga] = UIData.initalizeData([Raga](), "Created Ragas") as! [Raga]
    @Published var savedRagas = UIData.initalizeData([Raga](), "Saved Ragas") as! [Raga]
    
    @Published var databaseTransactions = UIData.initalizeData([DatabaseTransaction](), "Database Transactions") as! [DatabaseTransaction]
    @Published var savedRecordings = UIData.initalizeData([SavedRecording](), "Saved Recordings") as! [SavedRecording]
    @Published var favoriteRecordings = UIData.initalizeData([SavedRecording](), "Favorite Recordings") as! [SavedRecording]
    
    @Published var selectedRaga : Raga? = nil
    
    func setUpFiles() async {
        // get local files
        let files = RecordingHandler.getFiles()
        
        // go through all recordings
        for recording in savedRecordings {
            // check contain file
            let contains = files.contains { file in
                return file.absoluteString.contains(recording.URL)
            }

            // download file if missing
            if !contains {
                await RecordingDBHandler.shared.downloadURL(id: recording.URL)
            }
        }
        
        // go through all favorite recordings
        for recording in favoriteRecordings {
            // check contains file
            let contains = files.contains { file in
                return file.absoluteString.contains(recording.URL)
            }

            // download file if missing
            if !contains {
                await RecordingDBHandler.shared.downloadURL(id: recording.URL)
            }
        }
        
        // update data
        UIData.updateData(self.savedRecordings, key: "Saved Recordings")
        UIData.updateData(self.favoriteRecordings, key: "Favorite Recordings")
    }
    
    // reset settings
    func reset() {
        audioSettings.reset()
        uiSettings.reset()
        instrumentSettings.reset()
        
        selectedRaga = nil
    }
    
    func resetData() {
        favoriteRecordings = []
        savedRagas = []
        createdRagas = []
        savedRecordings = []
        RecordingHandler.clearRecordings()
        
        // update data
        UIData.updateData(self.savedRecordings, key: "Saved Recordings")
        UIData.updateData(self.favoriteRecordings, key: "Favorite Recordings")
        // update data
        UIData.updateData(self.savedRagas, key: "Saved Ragas")
        UIData.updateData(self.createdRagas, key: "Created Ragas")
    }
    
    func resetEverything() {
        reset()
        resetData()
    }
    
    // get user data
    func loadData() {
        // get created ragas
        DatabaseManager.shared.getCreatedRagas { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ragas) :
                    // set created ragas
                    self.createdRagas = ragas
                    UIData.updateData(self.createdRagas, key: "Created Ragas")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        // get saved ragas
        DatabaseManager.shared.getSavedRagas { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ragas) :
                    // set saved ragas
                    self.savedRagas = ragas
                    UIData.updateData(self.savedRagas, key: "Saved Ragas")
                case .failure(let error):
                    print("saved" + error.localizedDescription)
                }
            }
        }
        
        // get recordings
        DatabaseManager.shared.getRecordings { r, s in
            DispatchQueue.main.async {
                if s {
                    // save recordings
                    self.savedRecordings = r
                    UIData.updateData(self.savedRecordings, key: "Saved Recordings")
                }
                else {
                    print("ERROR")
                }
            }
        }
        
        // get favorite recordings
        DatabaseManager.shared.getFavoriteRecordings() { success, recs in
            DispatchQueue.main.async {
                if success {
                    // save favorite recordings
                    self.favoriteRecordings = recs
                    UIData.updateData(self.favoriteRecordings, key: "Favorite Recordings")
                }
            }
        }
    }
    
    func uploadData() {
        for saved in savedRagas {
            DatabaseManager.shared.addRagaToSaved(raga: saved) { _ in}
        }
        
        for created in createdRagas {
            DatabaseManager.shared.addRagaToCreated(rag: created) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let id) :
                        self.createdRagas[self.createdRagas.firstIndex(where: {raga in raga.id == created.id})!].id = id
                        break
                    case .failure(let error) :
                        print(error.localizedDescription)
                        break
                    }
                    
                }
            }
        }
        
        for favorite in favoriteRecordings {
            DatabaseManager.shared.addFavoriteRecording(recording: favorite) { _ in}
        }
        
        for recording in savedRecordings {
            DatabaseManager.shared.addRecording(recording: recording) { url, b in
                DispatchQueue.main.async {
                    self.savedRecordings[self.savedRecordings.firstIndex(where: {rec in rec.id == recording.id})!].URL = url
                }
                
            }
        }
    }
}

class AudioSettings : ObservableObject {
    @Published var attack = UIData.initalizeData(Float(0.1), "Attack") as! Float
    @Published var decay = UIData.initalizeData(Float(0.1), "Decay") as! Float
    @Published var sustain = UIData.initalizeData(Float(1), "Sustain") as! Float
    @Published var release = UIData.initalizeData(Float(0.1), "Release") as! Float
    @Published var sound = UIData.initalizeData("Guitar", "Sound") as! String
    @Published var ext = UIData.initalizeData("wav", "Ext") as! String
    @Published var path = UIData.initalizeData("/Sounds/Instruments/Guitar", "Path") as! String
    @Published var cent = UIData.initalizeData(Float(0), "Cent") as! Float
    
    // reset audio settings
    func reset() {
        attack = 0.1
        decay = 0.1
        sustain = 0.1
        release = 0.1
        sound = "Guitar"
        path = "/Sounds/Instruments/Guitar"
        ext = "wav"
        
        UIData.updateData(Float(0.1), key: "Attack")
        UIData.updateData(Float(0.1), key: "Decay")
        UIData.updateData(Float(1), key: "Sustain")
        UIData.updateData(Float(0.1), key: "Release")
        UIData.updateData("Guitar", key: "Sound")
        UIData.updateData("wav", key: "Ext")
        UIData.updateData("/Sounds/Instruments/Guitar", key: "Path")
    }
}

class InstrumentSettings : ObservableObject {
    @Published var swaras: [Int] = UIData.initalizeData([1,1,1,1,1,1,1], "Swaras") as! [Int]
    @Published var extraKeys:Int = UIData.initalizeData(0, "Extra Keys") as! Int
    @Published var pitch = UIData.initalizeData(Float(60), "Pitch") as! Float
    
    // reset instrument settings
    func reset() {
        swaras = [1,1,1,1,1,1,1]
        extraKeys = 0
        pitch = 60
        UIData.updateData([1,1,1,1,1,1,1], key: "Swaras")
        UIData.updateData(0, key: "Extra Keys")
        UIData.updateData(Float(60), key: "Pitch")
    }
}

class UISettings : ObservableObject {
    @Published var UI: String = UIData.initalizeData("Guitar", "UI") as! String
    @Published var bendFactor:Float = UIData.initalizeData(Float(1), "Bend Factor") as! Float
    @Published var padRows : Int = UIData.initalizeData(3, "Pad Rows") as! Int
    
    @Published var xSize : Int = UIData.initalizeData(40, "Key Width") as! Int
    @Published var ySize : Int = UIData.initalizeData(50, "Key Height") as! Int
    
    @Published var xSpacing : Int = UIData.initalizeData(0, "X Spacing") as! Int
    @Published var ySpacing : Int = UIData.initalizeData(50, "Y Spacing") as! Int
    
    @Published var xPadding : Int = UIData.initalizeData(0, "X Padding") as! Int
    @Published var yPadding : Int = UIData.initalizeData(0, "Y Padding") as! Int
    
    @Published var stringColor : Color
    @Published var keyColor : Color
    @Published var keyTextColor : Color
    
    init() {
//        var stringColorSaved = SaveColor(r: 0, b: 1, g: 0)
//        var keyColorSaved = SaveColor(r: 0, b: 0, g: 0)
//        var keyTextColorSaved = SaveColor(r: 1, b: 1, g: 1)
        
        let blues = Color.blue.components
        
        var stringColorSaved = UIData.initalizeData(SaveColor(r: blues.red, b: blues.blue, g: blues.green), "String Color") as! SaveColor
        var keyColorSaved = UIData.initalizeData(SaveColor(r: 0, b: 0, g: 0), "Key Color") as! SaveColor
        var keyTextColorSaved = UIData.initalizeData(SaveColor(r: 1, b: 1, g: 1), "Key Text Color") as! SaveColor
        
        stringColor = Color(red: stringColorSaved.r, green: stringColorSaved.g, blue: stringColorSaved.b)
        keyColor = Color(red: keyColorSaved.r, green: keyColorSaved.g, blue: keyColorSaved.b)
        keyTextColor = Color(red: keyTextColorSaved.r, green: keyTextColorSaved.g, blue: keyTextColorSaved.b)
    }
    
    // reset ui settings
    func reset() {
        UI = "Guitar"
        bendFactor = 1
        padRows = 3
        xSize = 25
        ySize = 50
        xSpacing = 0
        ySpacing = 50
        
        xPadding = 0
        yPadding = 0
        
        let blues = Color.blue.components
        
        var stringColorSaved = SaveColor(r: blues.red, b: blues.blue, g: blues.green)
        var keyColorSaved = SaveColor(r: 0, b: 0, g: 0)
        var keyTextColorSaved = SaveColor(r: 1, b: 1, g: 1)
        
        UIData.updateData(stringColorSaved, key: "String Color")
        UIData.updateData(keyColorSaved, key: "Key Color")
        UIData.updateData(keyTextColorSaved, key:"Key Text Color")
        
        stringColor = Color(red: stringColorSaved.r, green: stringColorSaved.g, blue: stringColorSaved.b)
        keyColor = Color(red: keyColorSaved.r, green: keyColorSaved.g, blue: keyColorSaved.b)
        keyTextColor = Color(red: keyTextColorSaved.r, green: keyTextColorSaved.g, blue: keyTextColorSaved.b)
        
        UIData.updateData("Guitar", key: "UI")
        UIData.updateData(Float(1), key: "Bend Factor")
        UIData.updateData(3, key:"Pad Rows")
        
        UIData.updateData(25, key:"Key Width")
        UIData.updateData(50, key:"Key Height")
        UIData.updateData(0, key:"X Spacing")
        UIData.updateData(50, key:"Y Spacing")
        
        UIData.updateData(xPadding, key: "X Padding")
        UIData.updateData(yPadding, key: "Y Padding")
    }
}
