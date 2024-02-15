//
//  InstrumentRect.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct InstrumentRect : View {
    var title:String
    var color:Color
    var image:String
    
    @Binding var sound:String
    
    var h:CGFloat
    
    @EnvironmentObject var engine : InstrumentConductor
    @EnvironmentObject var data : InstrumentHandler
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var startTime =  Date.now
    @State var elapsed:TimeInterval = 0
    @State var running = false
    
    init(_ title: String, _ color:Color,h:CGFloat, sound:Binding<String>,image:String="Music Icon") {
        self.title = title
        self.color = color
        self.h = h
        self._sound = sound
        self.image = image
    }
    
    var body : some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(color)
            .overlay {
                RoundedRectangle(cornerRadius: 15).stroke(.black, lineWidth: 3)
            }
            
            HStack(spacing: 20) {
                // display instrument, play test
                Image(image).resizable().scaledToFit().frame(width:h/12, height:h/12).padding(3).onTapGesture {
                    playInstrument()
                }
                .onReceive(timer) { time in
                    // update running time
                    if running {
                        elapsed = time.timeIntervalSince(startTime)
                        
                        // turn off after 3 seconds
                        if elapsed > 3 {
                            running = false
                            engine.soundPageOff()
                        }
                    }
                }
                
                // show title
                Text(title).foregroundColor(.white)
                Spacer()
            }
            
            // show instrument selection
            HStack {
                Spacer()
                BorderRect("", title == sound ? .green : .white).frame(width:h/15,height:h/15).padding().onTapGesture {
                    // set sound of engine
                    setSound()
                }
                .accessibilityLabel("\(title) instrument")
            }
        }.padding()
    }
    
    // plays test instrument
    func playInstrument() {
        // play sound
        engine.loadSoundPageInstrument(instrument: title, path: data.getSound(title), ext: data.extensions[title]!)
        engine.soundPageOn()
        
        // set start time of playing
        startTime = Date.now
        elapsed = 0
        running = true
    }
    
    // sets instrument sound
    func setSound() {
        // set sound
        engine.settings.sound = title
        sound = title
        
        // get path, ext
        let currentPath = data.getSound(title)
        let currentExtension = data.extensions[title]!
        
        // save instrument
        engine.settings.path = currentPath
        engine.settings.ext = currentExtension
        engine.setUpEngine(instrument: title, path: currentPath, ext: currentExtension)
    }
}
