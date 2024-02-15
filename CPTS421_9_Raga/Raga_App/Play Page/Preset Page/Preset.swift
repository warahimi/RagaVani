//
//  Preset.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/3/23.
//

import Foundation
import SwiftUI
import AudioKit
import SoundpipeAudioKit

struct Preset : Hashable, Codable, Identifiable {
    static func == (lhs: Preset, rhs: Preset) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    var swaras:[Int]
    var name:String
    var category:String
    var pitch:Float
    var attack:AUValue
    var decay:AUValue
    var sustain:AUValue
    var release:AUValue
    var id = UUID()
}

class PresetHandler : ObservableObject {
    @Published var presets = UIData.initalizeData([Preset](), "Presets") as! [Preset]
    @Published var settings : UserData?
    
    // add new preset
    func addPreset(name:String, category:String) {
        presets.append(createPreset(name: name, category:category))
        UIData.updateData(presets, key: "Presets")
    }
    
    // clear all presets
    func clearPresets() {
        presets = []
        UIData.updateData(presets, key: "Presets")
    }
    
    // create presets
    func createPreset(name:String,category:String) -> Preset {
        let swaras = settings!.instrumentSettings.swaras
        let category = category
        let pitch = settings!.instrumentSettings.pitch
        let attack = settings!.audioSettings.attack
        let decay = settings!.audioSettings.decay
        let sustain = settings!.audioSettings.sustain
        let release = settings!.audioSettings.release
        
        return Preset(swaras: swaras, name: name, category: category, pitch: pitch, attack:attack, decay: decay, sustain: sustain, release: release)
    }
    
    // remove presets
    func removePreset(preset:Preset) {
        presets.remove(at: presets.firstIndex(of: preset)!)
        UIData.updateData(presets, key: "Presets")
    }
    
    // rename presets
    func renamePreset(preset:Preset, name:String) {
        // get preset index, rename
        let index = presets.firstIndex(of: preset)!
        presets[index].name = name
        
        UIData.updateData(presets, key: "Presets")
    }
    
    // replace presets
    func replacePreset(preset:Preset) {
        // get preset index, replace
        let index = presets.firstIndex(of: preset)!
        presets[index] = createPreset(name: preset.name, category: preset.category)
        
        UIData.updateData(presets, key: "Presets")
    }
    
    // apply preset to engine, raga
    func applyPreset(preset:Preset) {
        // update data
        UIData.updateData(preset.attack, key: "Attack")
        UIData.updateData(preset.decay, key: "Decay")
        UIData.updateData(preset.sustain, key: "Sustain")
        UIData.updateData(preset.release, key: "Release")
        UIData.updateData(preset.pitch, key: "Pitch")
        UIData.updateData(preset.swaras, key: "Swaras")
        
        // apply data
        settings!.audioSettings.attack = preset.attack
        settings!.audioSettings.decay = preset.decay
        settings!.audioSettings.sustain = preset.sustain
        settings!.audioSettings.release = preset.release
        settings!.instrumentSettings.pitch = preset.pitch
        settings!.instrumentSettings.swaras = preset.swaras
    }
}
