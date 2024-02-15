//
//  SliderGroupView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/3/23.
//

import SwiftUI

struct SliderPageView: View {
    @EnvironmentObject var instrumentData : AudioSettings

    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            
            ScrollView {
                ZStack {
                    VStack(spacing:20) {
                        // show sa pitch
                        NoteView(w: w)
                        
                        // show adsr settings
                        ZStack {
                            BorderRect("", .gray.opacity(0.8), lw:5,rad:30)
                            VStack(spacing:0) {
                                Text("ADSR Settings").font(.system(size:w/7))
                                
                                // show adsr sliders
                                SliderView(title: "Attack", min: 0, max: 3, cur: $instrumentData.attack,size:w/2)
                                SliderView(title: "Decay", min: 0, max: 3, cur: $instrumentData.decay,size:w/2)
                                SliderView(title: "Sustain", min: 0, max: 1, cur: $instrumentData.sustain,size:w/2)
                                SliderView(title: "Release", min: 0, max: 3, cur: $instrumentData.release,size:w/2)
                            }
                        }
                    }.padding(.horizontal,5).padding(.vertical,3)
                }
            }.padding(.top)
        }
        
    }
}

struct SliderPageView_Previews: PreviewProvider {
    static var previews: some View {
        SliderPageView()
    }
}
