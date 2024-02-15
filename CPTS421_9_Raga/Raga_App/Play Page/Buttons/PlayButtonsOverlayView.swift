//
//  PlayButtonsOverlayView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/17/23.
//

import SwiftUI

struct PlayButtonsOverlayView: View {
    @Binding var editorButtonClicked : Bool
    @Binding var uiButtonClicked : Bool
    @EnvironmentObject var uiData : UIData
    @EnvironmentObject var touchHandler : TouchHandler
    @EnvironmentObject var settings : UserData
    
    var w : CGFloat
    var h : CGFloat
    
    var options = ["Swaras", "Tuner", "Presets"]
    var uis = ["Keyboard", "Pad", "Guitar"]
    
    var body: some View {
        ZStack {
            // if editor button clicked
            if editorButtonClicked {
                VStack(spacing:0) {
                    // ghost button to fix alignment
                    BorderRect("Swaras", Color.clear).opacity(0).frame(width: w/4,height:h/20)
                    
                    // list each editor option
                    ForEach(options, id: \.self) { name in
                        HStack {
                            let color = editorButtonClicked ? 1.0 : 0
                            
                            // show editor option
                            BorderRect(name, Color.blue,op:color)
                                .allowsHitTesting(editorButtonClicked)
                                .frame(width: w/4,height:h/20)
                                .onTapGesture {
                                    if editorButtonClicked {
                                        // change current editor
                                        editorButtonClicked = false
                                        uiData.currentEditor = name
                                    }
                                }
                            
                            Spacer()
                        }
                        
                    }
                    Spacer()
                }.padding(.leading)
                
            }
            
            // if ui dropdown enabled
            if uiButtonClicked {
                HStack {
                    // put in clear button to fix position
                    BorderRect("Swaras", Color.clear).opacity(0).frame(width: w/4,height:h/20)
                    
                    VStack(spacing:0) {
                        // put in clear button to fix position
                        BorderRect("UI", Color.clear).opacity(0).frame(width: w/4,height:h/20)
                        
                        // list each ui
                        ForEach(uis, id: \.self) { ui in
                            // show ui button
                            BorderRect(ui, Color.blue)
                                .frame(width: w/4,height:h/20)
                                .onTapGesture {
                                    if uiButtonClicked {
                                        // apply ui
                                        touchHandler.uiSettings.UI = ui
                                        UIData.updateData(ui, key: "UI")
                                        touchHandler.setUp()
                                        uiButtonClicked = false
                                    }
                                }
                        }
                        Spacer()
                    }.padding(.leading)
                    Spacer()
                }
            }
        }
    }
}

