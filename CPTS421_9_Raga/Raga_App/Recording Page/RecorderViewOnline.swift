//
//  RecorderViewOnline.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct RecorderViewOnline: View {
    @EnvironmentObject var handler:PlaybackHandler
    @EnvironmentObject var settings : UserData
    @EnvironmentObject var data : UIData
    
    @State var playing = false
    @State var input = ""
    @State var showingAlert = false
    @State var timeElapsed: TimeInterval = 0
    @State var startDate = Date.now
    @Binding var recordIndex : Int
    @State var deleteAlertOn = false
    
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var timerPlaying = false
    @State var index : Int
    @State var curRecording: SavedRecording
    @State var paused = false
    
    @State var startTime = 0
    
    var w = UIScreen.main.bounds.width
    
    var timerString : String {
        let time = Int(timeElapsed)
        
        if !timerPlaying {
            return "0  "
        }
        if timeElapsed > 10 {
            if timeElapsed > 100 {
                return String(time)
            }
            else {
                return "\(time) "
            }
        }
        else {
            return "\(time)  "
        }
    }
    
    var body: some View {
        ZStack {
            BorderRect("", .blue)
            
            VStack {
                // show recording title
                Text(curRecording.name)
                Spacer()
                
                // show playback bar
                ZStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 15).fill(.white).frame(width:w/1.6)
                            .overlay {
                                // overlay progress over white bar
                                if timerPlaying && recordIndex == index {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 15).fill(.black).frame(width:((w/1.6)*timeElapsed/curRecording.duration))
                                        Spacer()
                                    }
                                }
                            }
                    }
                    
                    HStack {
                        // show time elapsed
                        
                        Text(timerString)
                        
                        Spacer()
                        
                        // show duration
                        Text("\(Int(curRecording.duration))")
                    }
                }.onReceive(timer) { firedDate in
                    handleTimer()
                }
                
                
                HStack {
                    // play/pause
                    if playing && !paused {
                        // pause show up
                        TapImage(name: "pause.circle") {
                            if recordIndex == index && handler.isPlaying(index){
                                handler.player.pause()
                                paused = true
                            }
                        }
                    }
                    else if !playing || paused {
                        // play icon showing
                        TapImage(name:"play") {
                            handlePlay()
                        }
                    }
                    
                    // stop icon
                    TapImage(name: "stop.circle") {
                        if recordIndex == index {
                            handler.stopRecordedAudio()
                            
                            // reset timer
                            playing = false
                            timerPlaying = false
                            paused = false
                        }
                    }
                    
                    let isFavorited = settings.favoriteRecordings.contains { rec in
                        return rec.id == curRecording.id
                    }
                    
                    TapImage(name: isFavorited ? "star.fill" : "star") {
                        handleFavorite(isFavorited)
                    }
                    
                    Spacer()
                }
            }.padding()

        }
    }
    
    // handle timer
    func handleTimer() {
        // dont update if paused
        if paused {
            return
        }
        
        // increment time
        timeElapsed += 0.1
        
        // check index
        if recordIndex != index {
            playing = false
            timerPlaying = false
        }
        
        // make sure timer is playing
        if playing {
            timerPlaying = true
        }
        
        // check to stop
        if playing && timeElapsed > curRecording.duration {
            // stop audio
            handler.stopRecordedAudio()
            
            // reset timer
            playing = false
            timerPlaying = false
            paused = false
            startTime = 0
        }
    }
    
    // handle when play pressed
    func handlePlay() {
        // if paused, resume
        if paused && index == handler.lastIndex {
            handler.player.resume()
            paused = false
        }
        else if !handler.isPlaying(index) {
            paused = false
            
            // checks if need to download file
            if !containsFile(url: curRecording.URL) {
                // download file
                RecordingDBHandler.shared.downloadOnlineFile(url:curRecording.URL) {_ in
                    let success = handler.playOnlineRecordedAudio(index:index)
                    if success {
                        // reset timer
                        timeElapsed = 0
                        playing = true
                        
                        recordIndex = index
                        handler.lastIndex = index
                        
                        paused = false
                    }
                    else {
                        // show failed popup
                        data.popupText = "Recording not found"
                        data.showPopup = true
                    }
                }
            }
            else {
                // try to play
                let success = handler.playOnlineRecordedAudio(index:index)
                
                if success {
                    // reset timer
                    timeElapsed = 0
                    playing = true
                    
                    // set index of recording
                    recordIndex = index
                    handler.lastIndex = index
                    
                    paused = false
                }
                else {
                    // show failed popup
                    data.popupText = "Recording not found"
                    data.showPopup = true
                }
            }
        }
    }
    
    // handle when favorite pressed
    func handleFavorite(_ isFavorited : Bool) {
        if isFavorited {
            // remove favorite
            
            // get index to remove
            let idx = settings.favoriteRecordings.firstIndex { rec in
                return rec.id == curRecording.id
            }
            
            // update database
            DatabaseManager.shared.removeFavoriteRecording(recording: curRecording) { success in
                print(String(success))
            }
            
            // update local settings
            settings.favoriteRecordings.remove(at: idx!)
            UIData.updateData(settings.favoriteRecordings, key: "Favorite Recordings")
        }
        else {
            // add favorite
            
            // update database
            DatabaseManager.shared.addFavoriteRecording(recording: curRecording) { success in
                print(String(success))
            }
            
            // update local settings
            settings.favoriteRecordings.append(curRecording)
            UIData.updateData(settings.favoriteRecordings, key: "Favorite Recordings")
        }
    }
    
    // check if contains online file to download
    func containsFile(url:String) -> Bool {
        // get online files that are downlaoded
        let files = RecordingHandler.getOnlineFiles()
        
        return files.contains { file in
            return file.absoluteString.contains(url)
        }
    }
}
