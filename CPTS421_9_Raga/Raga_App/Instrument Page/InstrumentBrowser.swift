//
//  InstrumentBrowser.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/7/23.
//

import SwiftUI

struct InstrumentBrowser: View {
    @State var data = InstrumentHandler()
    
    @EnvironmentObject var uiData : UIData
    @EnvironmentObject var engine : InstrumentConductor
    
    @State var searchText = ""
    @State var currentSound : String = ""
    
    @FocusState var focused:Bool
    
    // all search
    var searchResults: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return data.getAll().filter { $0.lowercased().contains(searchText) }
        }
    }
    
    var h = UIScreen.main.bounds.height
    var w = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(spacing:0) {
            // show title
            Text("Sounds").font(.system(size:w/7))
            
            ZStack {
                BorderRect("", .white)
                
                // show sound search box
                TextField("Search Sounds", text:$searchText).multilineTextAlignment(.center).autocorrectionDisabled(true).textInputAutocapitalization(.never).focused($focused).onChange(of: focused) { edit in
                    if !edit {
                        // reset search
                        searchText = ""
                    }
                }
            }.frame(height:h/14).padding(.horizontal).padding(.top)
            
            VStack {
                // show instrument + synthetic sounds
                ScrollView {
                    CategoryView(title:"Instruments",items:data.getInstruments(),h:h, currentSound: $currentSound).padding()
                    CategoryView(title:"Synthetic Sounds", items:data.getNoises(),h:h, currentSound: $currentSound).padding()
                }
                .onAppear() {
                    currentSound = engine.settings.sound
                }
                
                Spacer()
            }.overlay {
                VStack {
                    // show search results
                    VStack(spacing:0) {
                        ForEach(searchResults, id: \.self) { result in
                            // show each result
                            BorderRect(result, .white,textColor: .black).frame(height:h/14).padding(.horizontal).onTapGesture {
                                setSound(sound: result)
                                searchText = ""
                            }
                        }
                    }
                    Spacer()
                }
            }
        }.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
        .environmentObject(data)
        
    }
    
    // set audio engine sound
    func setSound(sound:String) {
        // get sound path, ext
        let currentPath = data.getSound(sound)
        let currentExtension = data.extensions[sound]!
        
        // set up engine
        engine.setUpEngine(instrument: sound, path: currentPath, ext: currentExtension)
    }
}

struct InstrumentBrowser_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentBrowser()
    }
}
