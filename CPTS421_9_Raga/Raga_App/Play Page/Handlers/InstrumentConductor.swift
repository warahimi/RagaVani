//
//  InstrumentConductor.swift
//  Raga_App
//
//  Created by Aiden Walker on 4/5/23.
//

import SwiftUI

import AudioKit
import Tonic
import SoundpipeAudioKit
import AVFoundation
// plays sounds when an input is given
class InstrumentConductor : ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    
    @Published var envelopes = [AmplitudeEnvelope]()
    @Published var recorder:NodeRecorder!
    
    let mixer = Mixer()
    
    @Published var engines = [MIDISampler]()
    
    @Published var isRecording = false
    @Published var paused = false
    
    @Published var settings : AudioSettings
    
    @Published var oldPitches : [Float] = [0,0,0,0,0]
    
    let totalNodes = 5
    
    // set adsr
    func setADSR() {
        for i in 0..<totalNodes {
            // set envelopes to adsr setting
            envelopes[i].attackDuration = settings.attack
            envelopes[i].decayDuration = settings.decay
            envelopes[i].sustainLevel = settings.sustain
            envelopes[i].releaseDuration = settings.release
        }
    }
    
    // load instrument for sond page
    func loadSoundPageInstrument(instrument:String,path:String, ext:String) {
        // load each node
        for i in 0..<totalNodes {
            do {
                if let fileURL = Bundle.main.url(forResource: path, withExtension: ext) {
                    // load exs
                    if ext == "exs" {
                        try engines[i].loadInstrument(at: fileURL)
                    }
                    else {
                        // load wav file
                        let file = try AVAudioFile(forReading: fileURL)
                        try engines[i].loadAudioFile(file)
                    }
                    
                    
                } else {
                    Log("Could not find file")
                }
            } catch {
                Log("Could not load instrument")
            }

        }
    }
    
    // load instrument
    func setUpEngine(instrument:String,path:String, ext:String) {
        // save data
        UIData.updateData(path, key: "Path")
        UIData.updateData(instrument, key: "Sound")
        UIData.updateData(ext, key: "Ext")
        
        // set up engines
        for i in 0..<totalNodes {
            do {
                if let fileURL = Bundle.main.url(forResource: path, withExtension: ext) {
                    // load exs fuke
                    if ext == "exs" {
                        try engines[i].loadInstrument(at: fileURL)
                    }
                    else {
                        // load wav file
                        let file = try AVAudioFile(forReading: fileURL)
                        try engines[i].loadAudioFile(file)
                    }
                    
                    
                } else {
                    Log("Could not find file")
                }
            } catch {
                Log("Could not load instrument")
            }

        }
    }
    
    // plays given pitch
    func on(pitch: Float, index:Int) {
        // stop engine at touch index
        engines[index].stop(noteNumber: UInt8(oldPitches[index]), channel: 0)
        
        // play engine at index
        engines[index].play(noteNumber: UInt8(pitch), velocity: 100, channel: 0)
        
        // set cent
        engines[index].tuning = settings.cent
        
        // open envelope
        envelopes[index].openGate()
    }
    
    // turn off note
    func off(pitch: Float, index:Int) {
        // save old pitch for turning off
        oldPitches[index] = pitch
        
        // close envelope
        envelopes[index].closeGate()
    }
    
    // play note on sound page
    func soundPageOn() {
        engines[0].play(noteNumber: UInt8(60), velocity: 100, channel: 0)
        envelopes[0].openGate()
    }
    
    // turn off note from sound page
    func soundPageOff() {
        engines[0].stop(noteNumber: 60, channel: 0)
        envelopes[0].closeGate()
    }
    
    // bends the pitch
    func bend(offset:Float,index:Int) {
        // gets current midi offset
        engines[index].tuning = offset + settings.cent
        //dunnes[index].pitchBend = offset
    }
    
    // record playing
    func record() {
        recorder = try! NodeRecorder(node:self.engine.output!)
        try? recorder.record()
        isRecording = true
    }
    
    // pause recoding
    func pauseRecord() {
        if recorder.isPaused {
            recorder.resume()
            paused = false
        }
        else {
            recorder.pause()
            paused = true
        }
        
    }
    
    // stop recording
    func stopRecord(name:String) {
        let url = UUID().uuidString
        
        // try to move file
        do {
            try RecordingHandler.moveAudioFile(sourceURL: recorder.audioFile!.url, destinationDirectoryURL: RecordingHandler.documentPath, newFileName: url)
        }
        catch {
            isRecording = false
        }
        
        // stop recording
        isRecording = false
        
        // get locally saved recordings
        var recordings = UIData.initalizeData([SavedRecording](), "Saved Recordings") as! [SavedRecording]
        
        // get audio file
        let file = try! AVAudioFile(forReading: RecordingHandler.documentPath.appendingPathComponent(url + ".caf"))
        
        // get userid
        let userId = DatabaseManager.shared.getID()
        
        // save recording
        var recording = SavedRecording(id: UUID().uuidString, userId: userId ?? "local", name: name, isPublic: false, URL: url, date_created: Date.now.description, duration: file.duration)
        
        // add recording to db
        DatabaseManager.shared.addRecording(recording: recording) { id, success in
            recording.id = id
            recordings.append(recording)
            UIData.updateData(recordings, key: "Saved Recordings")
            print(success)
        }
        
        RecordingDBHandler.shared.uploadRecording(recording: recording, url: file.url) { success in}
    }
    
    // starts instrument
    init(settings:AudioSettings) {
        self.settings = settings
        
        // setup audio engine
        for _ in 0..<totalNodes {
            // create node
            let newEngine = MIDISampler()
            let env = AmplitudeEnvelope(newEngine)
            
            // set adsr
            env.attackDuration = settings.attack
            env.decayDuration = settings.decay
            env.sustainLevel = settings.sustain
            env.releaseDuration = settings.release
            
            // save node
            envelopes.append(env)
            engines.append(newEngine)
            
            // add to mixer
            mixer.addInput(env)
        }
        // start instrument
        engine.output = mixer
        try! engine.start()
        
        // set up engine
        setUpEngine(instrument: settings.sound, path: settings.path, ext: settings.ext)
    }
}
