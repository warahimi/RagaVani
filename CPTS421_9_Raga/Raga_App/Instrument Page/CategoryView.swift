//
//  CategoryView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct CategoryView : View {
    var title:String
    var items:[String]
    @State var h:CGFloat
    @Binding var currentSound : String
    @EnvironmentObject var data : InstrumentHandler
    @EnvironmentObject var uiData : UIData
    @EnvironmentObject var engine : InstrumentConductor
    
    // items to display to user
    var showItems : [String] {
        if items.isEmpty {
            return items
        }
        
        return Array(items[0..<min(3, items.count)])
    }
    
    var body : some View {
        ZStack {
            BorderRect("", .gray)
            VStack(spacing:0) {
                Text(title).padding()
                VStack(spacing:5) {
                    // show all sounds
                    ForEach(0..<showItems.count, id:\.self) { i in
                        // get image
                        let img = title.contains("Synthetic") ? "Music Icon" : showItems[i]
                        
                        // display sound selector
                        InstrumentRect(items[i], .blue, h:h,sound:$currentSound,image:img).frame(height: h/10).padding()
                    }
                    
                    // navigation to show all sounds
                    NavigationLink {
                        Text(title).font(.system(size:60))
                        ScrollCategory(title:title,items:items).padding()
                            .environmentObject(data)
                    } label: {
                        BorderRect("View all " + title, .blue).frame(height: h/10).padding(.horizontal)
                    }
                    
                    
                }
                Spacer()
            }
        }
        .onAppear() {
            // set sound
            currentSound = engine.settings.sound
        }
        .onDisappear() {
            // turn on engine
            engine.soundPageOff()
        }
    }
    
    // set engine sound
    func setSound(sound:String) {
        // get current path, ext
        let currentPath = data.getSound(sound)
        let currentExtension = data.extensions[sound]!
        
        engine.setUpEngine(instrument: sound, path: currentPath, ext: currentExtension)
    }
}
