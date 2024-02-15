//
//  EditableInfoView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct EditableInfoView : View {
    @Binding var showRaga : Raga
    var swaras = ["Sa", "Ri", "Ga", "Ma", "Pa", "Da", "Ni"]
    
    var body : some View {
        GeometryReader { g in
            let h = g.size.height
            let w = g.size.width
            ZStack {
                BorderRect("", .gray)
                
                // show all raga info
                ScrollView {
                    VStack {
                        Spacer()
                            
                        // show name
                        RagaSection(text: "Raga", input: $showRaga.name).padding()
                        
                        // show category
                        RagaSection(text: "Category", input: $showRaga.category).padding()
                        
                        // show swaras
                        ZStack {
                            VStack {
                                Text("Swaras:").bold().padding(.top)
                                RagaPageSwaraSelector(selections: $showRaga.inputs, h:h, w:w/2.5)
                            }.padding()
                        }.padding()
                        
                        // show vadi
                        ZStack {
                            VStack {
                                Text("Vadi:").bold().padding(.top)
                                VadiView(vadi:$showRaga.vadi)
                            }
                        }.padding()
                        
                        // show samvadi
                        ZStack {
                            VStack {
                                Text("Samvadi:").bold().padding(.top)
                                VadiView(vadi:$showRaga.samvadi)
                            }
                        }.padding()
                        
                        // show description
                        ZStack {
                            BorderRect("", .blue)
                            VStack {
                                Text("Description:").bold().padding(.top)
                                TextField("", text: $showRaga.description, axis:.vertical).italic().border(.black).padding()
                            }
                        }.padding()
                        Spacer()
                    }
                }
                
            }.padding()
        }
        
    }
}
