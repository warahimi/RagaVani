//
//  PresetView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/3/23.
//

import SwiftUI

struct PresetPageView: View {
    @State var showingAlert = false
    @State var input = ""
    @StateObject var handler = PresetHandler()
    @EnvironmentObject var settings: UserData
    @EnvironmentObject var ragaDB: RagaDatabase
    @EnvironmentObject var uiData : UIData
    @FocusState var focused
    
    @State var searchText = ""
    
    var searchResults : [Preset] {
        let results = handler.presets.filter({$0.name.contains(searchText)})
        if results.isEmpty {
            return results
        }
        return Array(results[0..<min(3, results.count)])
    }
    
    var body: some View {
        GeometryReader { g in
            let w = g.frame(in: .local).width
            let h = g.size.height
            ZStack {
                BorderRect("", .gray)
                HStack {
                    VStack {
                        HStack {
                            // add preset button
                            BorderRect("Add Preset", .blue).frame(width:w/3, height:h/5).onTapGesture {
                               showingAlert = true
                            }
                            .alert("Enter Name", isPresented: $showingAlert) {
                                // name input
                                TextField("...", text: $input)
                                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                                
                                Button("OK") {
                                    // save current settings
                                    if input != "" {
                                        // get raga category, save preset with new name
                                        let category = ragaDB.findCategory(inputs: settings.instrumentSettings.swaras)
                                        handler.addPreset(name: input, category:category)
                                    }
                                    
                                    input = ""
                                    showingAlert = false
                                }
                                
                                // leave alert
                                Button("Back") {
                                    input = ""
                                    showingAlert = false
                                }
                            }
                            
                            ZStack {
                                BorderRect("", .white)
                                
                                // input to search ragas
                                TextField("Search Presets", text:$searchText).multilineTextAlignment(.center).autocorrectionDisabled(true).textInputAutocapitalization(.never).focused($focused).onChange(of: focused) { edit in
                                    if !edit {
                                        searchText = ""
                                    }
                                }
                            }.frame(height:h/5)
                            
                            Spacer()
                        }.padding(.horizontal).padding(.top)
                       
                        
                        // show each preset
                        ScrollView {
                            if handler.presets.isEmpty {
                                BorderRect("No Presets Found", .blue,padding: true).frame(maxHeight:h/5).padding()
                            }
                            else {
                                
                                VStack(spacing:10) {
                                    ForEach(handler.presets, id: \.self) { preset in
                                        // show preset
                                        PresetView(preset:preset,size:w).padding()
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                        }
                        .environmentObject(handler)
                    }.overlay {
                        // show search results
                        VStack(spacing:0) {
                            Rectangle().frame(height:h/5).background(.clear).foregroundStyle(.clear).padding()
                            HStack {
                                Spacer()
                                ForEach(searchResults) { result in
                                    BorderRect(result.name, .white, textColor: .black, padding: true).padding(.bottom).frame(width:w/1.5, height:h/5).onTapGesture {
                                        searchText = ""
                                        handler.applyPreset(preset: result)
                                        
                                        uiData.popupText = "Preset Applied"
                                        uiData.showPopup = true
                                    }
                                }
                            }
                           
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
            }.padding()
        }
        .onAppear() {
            handler.settings = settings
        }
    }
}

struct PresetPageView_Previews: PreviewProvider {
    static var previews: some View {
        PresetPageView()
    }
}
