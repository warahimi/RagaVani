//
//  NormalInfoView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct NormalInfoView : View {
    @State var showRaga : Raga
    @State var expanded = false
    @EnvironmentObject var settings : UserData
    
    var body : some View {
        GeometryReader { g in
            let h = g.size.height
            let w = g.size.width
            
            ZStack {
                BorderRect("", .gray)
                ScrollView {
                    VStack(spacing:0) {
                        Spacer()
                        
                        // show raga
                        HStack {
                            NormalRagaBlock(text: "Raga", input: showRaga.name).padding()
                            TapImage(name:settings.selectedRaga != nil && settings.selectedRaga!.id == showRaga.id ? "checkmark.circle.fill" : "checkmark.circle") {
                                settings.selectedRaga = showRaga
                                settings.instrumentSettings.swaras = showRaga.inputs
                            }
                        }
                        
                        
                        // show category
                        NormalRagaBlock(text: "Category", input: showRaga.category).padding()
                        
                        // show swaras
                        ZStack {
                            VStack {
                                Text("Swaras:").bold().padding(.top)
                                RagaPageSwaraSelector(selections: $showRaga.inputs, h:h, w:w/2.5).allowsHitTesting(false)
                            }
                        }.padding()
                        
                        // show vadi
                        ZStack {
                            VStack {
                                Text("Vadi:").bold().padding(.top)
                                VadiView(vadi:$showRaga.vadi).allowsHitTesting(false)
                            }
                        }.padding()
                        
                        // show samvadi
                        ZStack {
                            VStack {
                                Text("Samvadi:").bold().padding(.top)
                                VadiView(vadi:$showRaga.samvadi).allowsHitTesting(false)
                            }
                        }.padding()
                        
                        // show description
                        ZStack {
                            BorderRect("", .blue)
                            
                            // show expand button
                            if showRaga.description.count > 100 {
                                TapImage(name: expanded ? "chevron.up" : "chevron.down") {
                                    expanded.toggle()
                                }.topRight()
                            }

                            // show description
                            VStack {
                                Text("Description:").bold()
                                
                                // if expanded to show whole text
                                if expanded {
                                    // show whole text
                                    Text(showRaga.description)
                                }
                                else {
                                    // show first 100 chars
                                    let text = showRaga.description.count <= 100 ? showRaga.description : showRaga.description.prefix(100) + "..."
                                    
                                    Text(text)
                                }
                                
                                
                            }.padding()
                        }.padding()
                        Spacer()
                    }
                }
                
            }.padding()
        }
        
    }
}
