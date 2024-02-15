//
//  LoginAlertView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/20/23.
//

import SwiftUI

struct LoginAlertView: View {
    @Binding var popupController : Bool
    let timer = Timer.publish(every:0.5, on: .main, in: .common).autoconnect()
    
    @State var displayTime = 0.0
    var popupText : String
    var popupTime = 2.0
    
    var body: some View {
        ZStack {
            // if can display
            if popupController {
                BorderRect("", .white)
                
                // show text
                Text(popupText).foregroundColor(.black).padding()
                
                // close button
                TapImage(name: "xmark") {
                    displayTime = 0.0
                    popupController = false
                }
                .topRight()
                .onReceive(timer) { _ in
                    // decrement time left
                    displayTime -= 0.5
                    
                    // disable popup if no time left
                    if displayTime < 0 {
                        popupController = false
                    }
                }
                
            }
        }
        .onChange(of: popupController) { _ in
            // if controller turns on, display for 2 secs
            if popupController {
                displayTime = popupTime
            }
        }
    }
}
