//
//  NoteView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct NoteView : View {
    var w : CGFloat
    @EnvironmentObject var data : InstrumentSettings
    @EnvironmentObject var instrumentData : AudioSettings
    
    var notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    // get current note in western form
    var currentNote : String {
        let adjustedNote = Int(data.pitch - 24)
        
        let octave = adjustedNote / 12
        let noteLetter = adjustedNote % 12
        
        return "\(notes[noteLetter]) \(octave+1)"
    }
    
    var body : some View {
        ZStack {
            BorderRect("", .gray.opacity(0.8), lw:5,rad:30)
            
            VStack(spacing:0) {
                // show title
                Text("Sa Pitch").font(.system(size:w/7))
                
                // midi slider
                SliderView(title: "Note", min: 40, max: 80, cur: $data.pitch,size:w/2, intRnd:true)
                
                HStack {
                    // change note down
                    Button {
                        data.pitch = max(40, data.pitch-1)
                    } label: {
                        ZStack {
                            BorderRect("", .blue.opacity(0.3))
                            Image(systemName: "chevron.down").resizable().scaledToFit().foregroundColor(.black).frame(width: 32, height: 32).padding(3)
                        }
                    }
                    
                    // change note up
                    Button {
                        data.pitch = min(80, data.pitch+1)
                    } label: {
                        ZStack {
                            BorderRect("", .blue.opacity(0.3))
                            Image(systemName: "chevron.up").resizable().scaledToFit().foregroundColor(.black).frame(width: 32, height: 32).padding(3)
                        }
                    }
                    
                    BorderRect(currentNote, .blue.opacity(0.3),textColor: .black, padding: true)
                }.padding(.horizontal)
                
                // cent slider
                CentSliderView(title: "Cent", min: -300, max: 300, cur: $instrumentData.cent,size:w/2)
            }
            .padding(.top,5)
        }
        
    }
}
