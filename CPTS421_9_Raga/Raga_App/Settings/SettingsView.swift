//
//  SettingsView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/8/23.
//

import SwiftUI

struct SettingsView: View {
    
    @State var isDarkModeEnabled: Bool = false
    @State var isNotificationEnabled: Bool = false
    @State var username = ""
    @EnvironmentObject var uiData: UIData
    @EnvironmentObject var settings : UserData
    @Binding var accClicked : Bool

    var body: some View {
        NavigationView {
            Form {
                // show instrument settings
                Section(header: Text("Instrument settings")) {
                    // bend factor picker
                    Picker("Bend Amount", selection: $settings.uiSettings.bendFactor) {
                        ForEach([0.5,1,1.5], id: \.self) {
                            Text(String($0))
                        }
                    }.onChange(of: settings.uiSettings.bendFactor) { newVal in
                        UIData.updateData(newVal, key: "Bend Factor")
                    }
                    
                    // extra keys picker
                    Picker("Extra Keys", selection: $settings.instrumentSettings.extraKeys) {
                        ForEach(0...5, id: \.self) {
                            Text(String($0))
                        }
                    }.onChange(of: settings.instrumentSettings.extraKeys) { newVal in
                        UIData.updateData(newVal, key: "Extra Keys")
                    }
                    
                    // pad rows picker
                    Picker("Pad Rows", selection: $settings.uiSettings.padRows) {
                        ForEach(1...4, id: \.self) {
                            Text(String($0))
                        }
                    }.onChange(of: settings.uiSettings.padRows) { newVal in
                        UIData.updateData(newVal, key: "Pad Rows")
                    }
                    
                    // reset settings
                    Button("Reset Instrument Settings") {
                        settings.instrumentSettings.reset()
                    }
                }
                
                // ui settings section
                Section(header: Text("UI Settings")) {
                    
                    ColorPicker("Key Color", selection: $settings.uiSettings.keyColor)
                        .onChange(of: settings.uiSettings.keyColor) { c in
                            UIData.updateData(SaveColor(r: c.components.red, b:c.components.blue, g:c.components.green), key: "Key Color")
                        }
                    
                    ColorPicker("Key Text Color", selection: $settings.uiSettings.keyTextColor)
                        .onChange(of: settings.uiSettings.keyTextColor) { c in
                            UIData.updateData(SaveColor(r: c.components.red, b:c.components.blue, g:c.components.green), key: "Key Text Color")
                        }
                    
                    ColorPicker("String Color", selection: $settings.uiSettings.stringColor)
                        .onChange(of: settings.uiSettings.stringColor) { c in
                            UIData.updateData(SaveColor(r: c.components.red, b:c.components.blue, g:c.components.green), key: "String Color")
                        }
                    
                    // y spacing
                    Picker("Y Spacing", selection: $settings.uiSettings.ySpacing) {
                        ForEach([0,50,150,200], id: \.self) {
                            Text(String($0))
                        }
                    }.onChange(of: settings.uiSettings.ySpacing) { newVal in
                        UIData.updateData(newVal, key: "Y Spacing")
                    }
                    
                    // x size
                    Picker("Key Width", selection: $settings.uiSettings.xSize) {
                        ForEach([25,40,75], id: \.self) {
                            Text(String($0))
                        }
                    }.onChange(of: settings.uiSettings.xSize) { newVal in
                        UIData.updateData(newVal, key: "Key Width")
                    }
                    
                    // y size
                    Picker("Key Height", selection: $settings.uiSettings.ySize) {
                        ForEach([25,50,75], id: \.self) {
                            Text(String($0))
                        }
                    }.onChange(of: settings.uiSettings.ySize) { newVal in
                        UIData.updateData(newVal, key: "Key Height")
                    }
                    
                    // ui settings
                    Button("Reset UI Settings") {
                        settings.uiSettings.reset()
                    }
                    
                    
                }
                
                
                
                // reset all settings
                Section {
                    Button("Reset All") {
                        settings.reset()
                    }
                }
            }
            .navigationBarTitle(Text("Settings"))
        }
    }
}
