//
//  ShowSavedSwarasPopover.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct ShowSavedSwarasPopover: View {
    @EnvironmentObject var ragaSettings : UserData
    
    @Binding var selections : [Int]
    @Binding var showingSavedRagas : Bool
    
    var w : CGFloat
    var h : CGFloat
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Spacer()
                ZStack {
                    BorderRect("", .gray)
                    
                    VStack {
                        Text("Saved Ragas").font(.largeTitle)
                        // show all saved ragas
                        Text("Select Saved Raga").italic()
                        ScrollView {
                            if ragaSettings.savedRagas.isEmpty {
                                BorderRect("No Saved Ragas Yet", .blue, padding: true).padding()
                            }
                            else {
                                ForEach(ragaSettings.savedRagas) { raga in
                                    SmallRagaInfoTapable(raga: raga, h: h, w: w) {
                                        // select raga
                                        ragaSettings.selectedRaga = raga
                                        selections = raga.inputs
                                        showingSavedRagas = false
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
                
                // leave page
                Button("Back") {
                    showingSavedRagas = false
                }.padding()
               
            }
            Spacer()
        }.padding()
    }
}
