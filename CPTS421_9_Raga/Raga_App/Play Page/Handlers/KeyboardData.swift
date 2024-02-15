//
//  NewUIData.swift
//  Raga_App
//
//  Created by Aiden Walker on 4/19/23.
//

import Foundation

struct Swara {
    var name:String
    var offset:Int
    var midi:Int
    
    func getPitch() -> Int {
        return offset + midi
    }
}

class KeyboardData : ObservableObject {
    @Published var instrumentSettings : InstrumentSettings
    @Published var currentKeyboard = [Swara]()
    @Published var totalSwaras = 0
    @Published var uiSetting : UISettings
    
    init(settings:InstrumentSettings, uiSetting : UISettings) {
        instrumentSettings = settings
        self.uiSetting = uiSetting
        // sets default swara values
        self.setSwaras()
    }
    
    // set keyboard swaras
    func setSwaras() {
        // get selections, reset keyboard
        var selections = instrumentSettings.swaras
        
        if uiSetting.UI == "Guitar" {
            var pitches = [Int]()
            
            // go through regular selections
            for (i, selection) in selections.enumerated() {
                if selection != 0 {
                    // get swara, midi
                    let swara = KeyboardData.NumToSwara(index: i, num: selection)
                    let midi = getMidi(swaraName: swara)
                    
                    if pitches.contains(midi) {
                        selections[i] = 0
                    }
                    else {
                        pitches.append(midi)
                    }
                }
            }
        }
        
        var count = 0
        currentKeyboard = [Swara]()

        // start at highest pitch for keys below start
        var index = selections.count - 1
        
        // set up first extra keys
        while count < instrumentSettings.extraKeys {
            if selections[index] != 0 {
                // get swara, midi
                let swara = KeyboardData.NumToSwara(index: index, num: selections[index])
                let midi = getMidi(swaraName: swara)
                
                // add swara, midi
                // midis are offset by 12
                currentKeyboard.append(Swara(name:swara, offset:-12, midi:midi))
                count += 1
            }
            
            index -= 1
        }
        
        // reverse keys to put them in order
        currentKeyboard = currentKeyboard.reversed()
        totalSwaras = 0
        
        // go through regular selections
        for (i, selection) in selections.enumerated() {
            if selection != 0 {
                // get swara, midi
                let swara = KeyboardData.NumToSwara(index: i, num: selection)
                let midi = getMidi(swaraName: swara)
                
                // add swara
                currentKeyboard.append(Swara(name:swara, offset:0, midi:midi))
                totalSwaras += 1
            }
        }
        
        totalSwaras += (2*instrumentSettings.extraKeys)
        
        // now start at lowest pitch for keys above selections
        count = 0
        index = 0
        while count < instrumentSettings.extraKeys {
            if selections[index] != 0 {
                // get swara and midi
                let swara = KeyboardData.NumToSwara(index: index, num: selections[index])
                let midi = getMidi(swaraName: swara)
                
                // add to keyboard
                // midi offset by 12
                currentKeyboard.append(Swara(name:swara, offset:12, midi:midi))
                count += 1
            }
            
            index += 1
        }
        
    }
    
    // converts a given index to a swara
    static func NumToSwara(index:Int, num:Int) -> String {
        
        let swaras = ["S", "R", "G", "M", "P", "D", "N"]
        let letter = swaras[index]
        
        // if sa
        if index == 0 {
            return "S"
        }
        
        
        // if no swara selected
        if num == 0 {
            return ""
        }
        
        // if pa
        if index == 4 {
            return "P"
        }
        
        return letter + String(num)
    }
    
    //get midi of swara at index
    func getMidi(swaraName: String) -> Int {
        // no swara
        if swaraName == "" {
            return 0
        }
        
        // gets swara ketter
        let c = swaraName[0]
        
        // checks letter, then checks number
        if swaraName == "S" {
            return 1
        }
        else if c == "R" {
            let num: Character = swaraName[1]
            switch(num) {
                case "1" :
                    return 2
                case "2" :
                    return 3
                case "3" :
                    return 4
                default :
                    return -1
            }
        }
        else if c == "G" {
            let num: Character = swaraName[1]
            switch(num) {
                case "1" :
                    return 3
                case "2" :
                    return 4
                case "3" :
                    return 5
                default :
                    return -1
            }
        }
        else if c == "M" {
            let num: Character = swaraName[1]
            switch(num) {
                case "1" :
                    return 6
                case "2" :
                    return 7
                default :
                    return -1
            }
        }
        else if swaraName == "P"  {
            return 8
        }
        else if c == "D" {
            let num: Character = swaraName[1]
            switch(num) {
                case "1" :
                    return 9
                case "2" :
                    return 10
                case "3" :
                    return 11
                default :
                    return -1
            }
        }
        else if c == "N" {
            let num: Character = swaraName[1]
            switch(num) {
                case "1" :
                    return 10
                case "2" :
                    return 11
                case "3" :
                    return 12
                default :
                    return -1
            }
        }

        return -1
    }
}
