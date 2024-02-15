//
//  FullScreenView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/8/23.
//

import SwiftUI

struct FullScreenView: View {
    @StateObject var engine : InstrumentConductor
    @EnvironmentObject var data:UIData
    @StateObject var touchHandler : TouchHandler
    @State var reset = false
    
    init(settings:UserData) {
        _engine = StateObject(wrappedValue: InstrumentConductor(settings: settings.audioSettings))
        _touchHandler = StateObject(wrappedValue: TouchHandler(uiSettings: settings.uiSettings, keySettings: settings.instrumentSettings))
    }
    
    var body: some View {
        GeometryReader { g in
            // get screen bounds
            let h = g.frame(in: .local).height
            let w = g.frame(in: .local).width
            
            ZStack {
                // make sure we are lanscape
                if w > h {
                    // touch view
                    TapView(reset:$reset)
                        .environmentObject(touchHandler)
                        .environmentObject(engine)
                    
                    VStack {
                        HStack {
                            Spacer()
                            
                            // record button
                            RecordButton(engine: engine, w:w/8, h:h/10)
                            
                            // go back to portrait
                            TapImage(name: "arrow.down.forward.and.arrow.up.backward.square.fill") {
                                rotate(.portrait)
                                touchHandler.setUp()
                                data.currentScene = "Play"
                            }
                            
                        }
                        
                        Spacer()
                    }
                }
                
            }.onAppear() {
                // rotate screen to landscape
                rotate(.landscape)
                
            }.onDisappear() {
                // stop recording
                if engine.isRecording {
                    engine.recorder.stop()
                    engine.isRecording = false
                }
            }.onChange(of: g.size) { _ in
                // update rotation
                rotate(.landscape)
            }
        }
        
    }
    
    func rotate(_ orientation : UIInterfaceOrientationMask) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
    }
}



