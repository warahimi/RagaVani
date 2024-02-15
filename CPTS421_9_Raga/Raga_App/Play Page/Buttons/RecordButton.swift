//
//  RecordButton.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct RecordButton : View {
    @StateObject var engine : InstrumentConductor
    @State var showingAlert = false
    @State var input = ""
    
    @EnvironmentObject var settings : UserData
    
    var w : CGFloat
    var h : CGFloat
    
    var body : some View {
        // get color, text for record button
        let color = engine.isRecording ? Color.green : Color.red
        let text = engine.isRecording ? "Recording" : "Record"
        
        // button to tap
        BorderRect(text, Color.white,textColor: color)
            .onTapGesture {
                // check if recording
                if engine.isRecording {
                    engine.recorder.stop()
                    engine.isRecording = false
                    showingAlert = true
                }
                else {
                    engine.record()
                }
            }
            .frame(width: w,height:h)
            .alert("Enter Name", isPresented: $showingAlert) { //rename alert
                TextField("...", text: $input)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                Button("OK") {
                    // stop recording, save input
                    if input != "" {
                        engine.stopRecord(name:input)
                    }
                    
                    // reset alert
                    input = ""
                    showingAlert = false
                }
                Button("Back") {
                    // reset alert
                    input = ""
                    showingAlert = false
                    
                    // stop audio engine
                    engine.recorder.stop()
                    engine.isRecording = false
                }
            }
        
        if engine.isRecording {
            TapImage(name: "pause.circle", padding: false) {
                engine.pauseRecord()
            }.foregroundColor(engine.paused ? .red : .black)
        }
    }
}
