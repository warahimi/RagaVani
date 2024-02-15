//
//  ScrollCategory.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct ScrollCategory : View {
    var title:String
    var items:[String]
    
    @State var currentSound : String = ""
    @EnvironmentObject var engine : InstrumentConductor
    @EnvironmentObject var data : InstrumentHandler
    
    var h = UIScreen.main.bounds.height
    
    var body : some View {
        ZStack {
            BorderRect("", .gray)
            
            // show all items
            ScrollView {
                VStack(spacing:0) {
                    Text("All " + title).padding()
                    
                    // list items
                    VStack(spacing:5) {
                        ForEach(0..<items.count, id:\.self) { i in
                            // set image
                            let img = title.contains("Synthetic") ? "Music Icon" : items[i]
                            
                            // show sound select block
                            InstrumentRect(items[i], .blue, h:h,sound:$currentSound,image:img).frame(height: h/10).padding()
                        }
                    }
                    Spacer()
                }
                
            }
        }.onAppear() {
            // set current sound
            currentSound = engine.settings.sound
        }
        .onDisappear() {
            // turn off audio
            engine.soundPageOff()
        }
    }
}
