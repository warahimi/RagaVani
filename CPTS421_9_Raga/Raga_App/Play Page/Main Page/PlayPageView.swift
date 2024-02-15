//
//  PlayPageView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/3/23.
//

import SwiftUI

struct PlayPageView: View {
    @State var reset = false
    @State var dropdownEnabled = false
    @State var instruclicked = false
    @State var recordClicked = false
    @Binding var accClicked : Bool
    
    @EnvironmentObject var uiData:UIData
    @StateObject var touchHandler : TouchHandler
    @StateObject var engine : InstrumentConductor
    @StateObject var settings : UserData
    
    init(settings:UserData, accClicked:Binding<Bool>) {
        _accClicked = accClicked
        _settings = StateObject(wrappedValue: settings)
        _touchHandler = StateObject(wrappedValue: TouchHandler(uiSettings: settings.uiSettings, keySettings: settings.instrumentSettings))
        _engine = StateObject(wrappedValue: InstrumentConductor(settings: settings.audioSettings))
    }
    
    var body: some View {
        GeometryReader { g in
            // get size
            let h = g.frame(in:.local).height
            let w = g.frame(in:.local).width
            
            ZStack {
                VStack(spacing:0) {
                    // display touch view
                    TapView(reset:$reset)
                        .onChange(of: reset) { _ in
                            resetOverlays()
                        }
                    
                    Spacer()
                    
                    // display rest of play page
                    VStack (spacing:0) {
                        // display button menu
                        PlayButtonsView(dropdownEnabled: $dropdownEnabled, instruclicked: $instruclicked, w: w, h: h)
                            .simultaneousGesture(TapGesture().onEnded { _ in accClicked = false })
                        
                        // preset page
                        if uiData.currentEditor == "Presets" {
                            PresetPageView()
                                .simultaneousGesture(TapGesture().onEnded { _ in resetOverlays()})
                        }
                        // audio tuner page
                        else if uiData.currentEditor == "Tuner" {
                            SliderPageView()
                                .environmentObject(settings.audioSettings)
                                .environmentObject(settings.instrumentSettings)
                                .onChange(of: settings.audioSettings.attack) { val in updateADSR(val, "Attack")}
                                .onChange(of: settings.audioSettings.decay) { val in updateADSR(val, "Decay")}
                                .onChange(of: settings.audioSettings.sustain) { val in updateADSR(val, "Sustain")}
                                .onChange(of: settings.audioSettings.release) { val in updateADSR(val, "Release")}
                                .simultaneousGesture(TapGesture().onEnded { _ in resetOverlays()})
                        }
                        // swara page
                        else {
                            SwaraSelectorView().padding(.top, 2)
                                .environmentObject(settings.instrumentSettings)
                                
                        }
                    }
                    .overlay {
                        PlayButtonsOverlayView(editorButtonClicked: $dropdownEnabled, uiButtonClicked: $instruclicked, w: w, h: h)
                            .simultaneousGesture(TapGesture().onEnded { _ in accClicked = false })
                    }
                    
                }
                .environmentObject(engine)
                .environmentObject(touchHandler)
            
                // display full screen button
                FullscreenButtonView()
                    .simultaneousGesture(TapGesture().onEnded { _ in resetOverlays()})
            }.onDisappear() {
                // stop recording
                if engine.isRecording {
                    engine.recorder.stop()
                    engine.isRecording = false
                }
            }
        }
    }
    
    // reset ui dropdowns
    func resetOverlays() {
        if reset {
            reset = false
        }
        
        // reset overlay controllers
        accClicked = false
        dropdownEnabled = false
        instruclicked = false
    }
    
    // set adsr of audio engine, save
    func updateADSR(_ val:Float, _ key:String) {
        engine.setADSR()
        UIData.updateData(val, key: key)
    }
}
