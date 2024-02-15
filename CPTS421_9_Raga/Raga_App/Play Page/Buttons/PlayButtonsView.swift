//
//  PlayButtonsView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/17/23.
//

import SwiftUI

struct PlayButtonsView: View {
    @Binding var dropdownEnabled : Bool
    @Binding var instruclicked : Bool
    @EnvironmentObject var engine : InstrumentConductor
    @State var showingAlert = false
    @State var input = ""
    var w : CGFloat
    var h : CGFloat
    
    var body: some View {
        HStack {
            // editor dropdown button
            BorderRect("Editor", .blue)
                .onTapGesture {
                    instruclicked = false
                    dropdownEnabled.toggle()
                }
                .frame(width: w/4,height:h/20)
            
            // ui dropdown button
            BorderRect("UI", Color.blue)
                .onTapGesture {
                    dropdownEnabled = false
                    instruclicked.toggle()
                }
                .frame(width: w/4,height:h/20)
            
            Spacer()
            
            // recording button
            RecordButton(engine: engine, w: w/4, h: h/20)
            
                
        }.padding(.leading)
    }
}
