//
//  InstrumentHandler.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/10/23.
//

import Foundation

// database of possible raga sounds
class InstrumentHandler: ObservableObject {
    @Published var instruments: Dictionary<String,String> = Dictionary()
    @Published var noises: Dictionary<String,String> = Dictionary()
    @Published var extensions: Dictionary<String,String> = Dictionary()
    
    init() {
        let instrumentURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Sounds/Instruments")!
        let noiseURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Sounds/Synthetic Sounds")!
        
        // load all noises
        for u in noiseURLs {
            let path = u.lastPathComponent
            let newPath = String(path[path.startIndex..<path.firstIndex(of: ".")!])
            let ext = String(path[path.index(after:path.firstIndex(of:".")!)..<path.endIndex])
            noises[newPath] = "Sounds/Synthetic Sounds/" + newPath
            extensions[newPath] = ext
        }
        
        // load all instruments
        for u in instrumentURLs {
            let path = u.lastPathComponent
            let newPath = String(path[path.startIndex..<path.firstIndex(of: ".")!])
            let ext = String(path[path.index(after:path.firstIndex(of:".")!)..<path.endIndex])
            instruments[newPath] = "Sounds/Instruments/" + newPath
            extensions[newPath] = ext
        }
    }
    
    // get all noises
    func getNoises() -> [String] {
        return Array(noises.keys)
    }
    
    // get all instruments
    func getInstruments() -> [String] {
        return Array(instruments.keys)
    }
    
    // get all sounds
    func getAll() -> [String] {
        var arr = getNoises()
        arr.append(contentsOf: getInstruments())
        return arr
    }
    
    // get sound at name
    func getSound(_ name:String) -> String {
        if instruments.keys.contains(name) {
            return instruments[name]!
        }
        else if noises.keys.contains(name) {
            return noises[name]!
        }
        
        return ""
    }
}
