//
//  PresetView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/3/23.
//

import SwiftUI
import AudioKit

struct PresetView: View {
    @State var showingAlert = [false, false, false]
    @State var input = ""
    @State var expanded = false
    @EnvironmentObject var uiData : UIData
    var size:CGFloat = 0.0
    var presetName:String = ""
    var presetCategory:String = ""
    var presetSwaras:String = ""
    var presetPitch:String = ""
    var presetA:String = ""
    var presetD:String = ""
    var presetS:String = ""
    var presetR:String = ""
    var preset:Preset
    
    @EnvironmentObject var handler: PresetHandler
    @EnvironmentObject var touchHandler : TouchHandler
    @EnvironmentObject var engine : InstrumentConductor
    @EnvironmentObject var settings : UserData
    
    init(preset:Preset,size:CGFloat) {
        self.preset = preset
        self.size = size
        self.presetName = preset.name
        self.presetCategory = preset.category
        
        presetSwaras = ""
        self.presetPitch = ""
        
        // set swaras text
        for i in 0..<preset.swaras.count {
            self.presetSwaras += KeyboardData.NumToSwara(index: i, num: preset.swaras[i]) + " "
        }
        
        // set adsr text
        self.presetPitch = "Pitch: " + String(rndFloat(preset.pitch))
        self.presetA = "Attack: " + String(rnd(preset.attack)) + "s"
        self.presetD = "Decay: " + String(rnd(preset.decay)) + "s"
        self.presetS = "Sustain: " + String(rnd(preset.sustain)) + "%"
        self.presetR = "Release: " + String(rnd(preset.release)) + "s"
    }
    
    // round auvalue
    func rnd(_ x:AUValue) -> Double {
        return round(Double(x)*100) / 100
    }
    
    // round float
    func rndFloat(_ x:Float) -> Double {
        return round(Double(x)*100) / 100
    }
    
    var body: some View {
        ZStack {
            BorderRect("", .blue, rad:30)
            
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    // name text
                    HStack {
                        Text(presetName).bold(true).underline(true).font(.system(size:size/8)).onTapGesture {
                            handler.applyPreset(preset:preset)
                            touchHandler.updateSwaras(currentSelections: preset.swaras, category: preset.category)
                            touchHandler.setUp()
                            engine.setADSR()
                            engine.setUpEngine(instrument: settings.audioSettings.sound, path: settings.audioSettings.path, ext: settings.audioSettings.ext)
                            uiData.popupText = "Preset Applied"
                            uiData.showPopup = true
                        }
                        
                        TapImage(name: expanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical",padding: false) {
                            expanded.toggle()
                        }.padding(.horizontal, 5)
                        
                        Spacer()
                    }
                    
                    if expanded {
                        HStack {
                            // rename button
                            TapImage(name: "pencil") {
                                showingAlert[0] = true
                            }
                            .alert("Enter Name", isPresented: $showingAlert[0]) {
                                // input field
                                TextField("...", text: $input)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                
                                // apply rename
                                Button("OK", action: renamePreset)
                                
                                // leave alert
                                Button("Back") {
                                    input = ""
                                    showingAlert[0] = false
                                }
                            }
                            
                            TapImage(name: "square.and.arrow.down") {
                                showingAlert[1]=true
                            }
                            .alert("Are You Sure", isPresented: $showingAlert[1]) {
                                // replace preset
                                Button("Yes") {
                                    handler.replacePreset(preset: preset)
                                    showingAlert[1] = false
                                }
                                
                                // leave alert
                                Button("No") {
                                    showingAlert[1] = false
                                }
                            }
                            
                            TapImage(name: "trash") {
                                showingAlert[2] = true
                            }
                            .alert("Are You Sure", isPresented: $showingAlert[2]) {
                                // remove preset
                                Button("Yes") {
                                    handler.removePreset(preset: preset)
                                    showingAlert[2] = false
                                }
                                
                                // leave alert
                                Button("No") {
                                    showingAlert[2] = false
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // show preset data
                        Text(presetCategory).italic(true).foregroundStyle(.white)
                        Text(presetSwaras).italic(true).foregroundStyle(.white)
                        Text(presetA + " | " + presetD).italic(true).foregroundStyle(.white)
                        Text(presetS + " | " + presetR).italic(true).foregroundStyle(.white)
                        Text(presetPitch).italic(true).foregroundStyle(.white)
                    }
                }
                Spacer()
            }.padding()
            
        }
        
    }
    
    // rename preset
    func renamePreset() {
        // rename preset if valid input
        if input != "" {
            handler.renamePreset(preset: preset, name: input)
        }
        
        // reset input
        input = ""
        showingAlert[0] = false
    }
}
