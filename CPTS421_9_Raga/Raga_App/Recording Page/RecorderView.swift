//
//  RecorderView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/7/23.
//

import SwiftUI
import AudioKit

struct RecorderView: View {
    @EnvironmentObject var handler:PlaybackHandler
    @EnvironmentObject var data : UIData
    @EnvironmentObject var userData : UserData
    
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
    var w = UIScreen.main.bounds.width
    
    @State var paused = false
    
    @State var startTime = 0
    
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
            BorderRect("", .blue).frame(width:w/1.15)
            
            VStack {
                // show recording name
                HStack {
                    Text(curRecording.name)
                    // share button
                    TapImage(name: curRecording.isPublic ? "shareplay" : "shareplay.slash", padding: false)  {
                        handleShare()
                    }.padding(.horizontal, 3)
                }
                
                Spacer()
                
                // show playback bar
                ZStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 15).fill(.white).frame(width:w/1.6)
                            .overlay {
                                // show playback amount with bar
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
                    // pause/play icon
                    if playing && !paused {
                        // pause icon showing
                        TapImage(name: "pause.circle", padding: false) {
                            if recordIndex == index && handler.isPlaying(index){
                                handler.player.pause()
                                paused = true
                            }
                        }.padding(.horizontal, 3)
                    }
                    else if !playing || paused {
                        // play icon showing
                        TapImage(name:"play", padding: false)  {
                            handlePlay()
                        }.padding(.horizontal, 3)
                    }
                    
                    // stop icon
                    TapImage(name: "stop.circle", padding: false)  {
                        if recordIndex == index {
                            handler.stopRecordedAudio()
                            playing = false
                            timerPlaying = false
                            paused = false
                        }
                    }.padding(.horizontal, 3)
                    
                    // trash button
                    TapImage(name: "trash", padding: false)  {
                        deleteAlertOn.toggle()
                    }.padding(.horizontal, 3)
                    .alert("Are You Sure", isPresented: $deleteAlertOn) {
                        makeDeleteAlert()
                    }
                    
                    // rename button
                    TapImage(name: "pencil", padding: false) {
                        showingAlert.toggle()
                    }.padding(.horizontal, 3)
                    .alert("Enter Name", isPresented: $showingAlert) {
                        makeAlert()
                    }
                    
                    let isFavorited = userData.favoriteRecordings.contains { rec in
                        return rec.id == curRecording.id
                    }
                    
                    TapImage(name: isFavorited ? "star.fill" : "star") {
                        handleFavorite(isFavorited)
                    }
                    
                }
            }.padding()
        }
    }
    
    @ViewBuilder
    func makeDeleteAlert() -> some View {
        // yes to remove
        Button("Yes") {
            let url = handler.getPath(index)
            Task {
                // remove recording in database
                DatabaseManager.shared.removeRecording(recording:curRecording) { val in
                    print(val)
                }
                
                RecordingDBHandler.shared.removeRecording(recording:curRecording,url:url) { val in
                    DispatchQueue.main.async {
                        // remove file
                        
                        // reset alert
                        deleteAlertOn = false
                    }
                }
            }
            handler.removeFile(index:index)
            userData.savedRecordings.remove(at: userData.savedRecordings.firstIndex(of: curRecording)!)
            UIData.updateData(userData.savedRecordings, key: "Saved Recordings")
            
        }
        
        // leave alert
        Button("No") {
            deleteAlertOn = false
        }
    }
    
    @ViewBuilder
    func makeAlert() -> some View {
        // name input
        TextField("...", text: $input)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        
        // set name
        Button("OK") {
            if input != "" {
                // rename recording
                handler.renameRecording(name: input, index)
                curRecording.name = input
                
                // update database
                DatabaseManager.shared.updateRecording(recording: curRecording) { success in
                    UIData.updateData(handler.recordings, key: "Saved Recordings")
                    print(success)
                }
                
            }
            
            // reset alert
            input = ""
            showingAlert = false
        }
        
        // leave alert
        Button("Back") {
            input = ""
            showingAlert = false
        }
    }
    
    // handle share or unshare command
    func handleShare() {
        let toggled = !curRecording.isPublic
        
        // toggle sharing
        handler.recordings[index].isPublic = toggled
        curRecording.isPublic = toggled
        
        // update database
        DatabaseManager.shared.updateRecording(recording: curRecording) { success in
            UIData.updateData(handler.recordings, key: "Saved Recordings")
            print(success)
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
                RecordingDBHandler.shared.downloadUserFile(url:curRecording.URL) {_ in
                    let downloadSuccess = handler.playRecordedAudio(index:index)
                    if downloadSuccess {
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
                let success = handler.playRecordedAudio(index:index)
                
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
                    data.popupText = "Recording not loaded"
                    data.showPopup = true
                }
            }
        }
    }
    
    // check if contains online file to download
    func containsFile(url:String) -> Bool {
        // get online files that are downlaoded
        let files = RecordingHandler.getFiles()
        
        return files.contains { file in
            return file.absoluteString.contains(url)
        }
    }
    
    // handle when favorite pressed
    func handleFavorite(_ isFavorited : Bool) {
        if isFavorited {
            // remove favorite
            
            // get index to remove
            let idx = userData.favoriteRecordings.firstIndex { rec in
                return rec.id == curRecording.id
            }
            
            // update database
            DatabaseManager.shared.removeFavoriteRecording(recording: curRecording) { success in
                print(String(success))
            }
            
            // update local settings
            userData.favoriteRecordings.remove(at: idx!)
            UIData.updateData(userData.favoriteRecordings, key: "Favorite Recordings")
        }
        else {
            // add favorite
            
            // update database
            DatabaseManager.shared.addFavoriteRecording(recording: curRecording) { success in
                print(String(success))
            }
            
            // update local settings
            userData.favoriteRecordings.append(curRecording)
            UIData.updateData(userData.favoriteRecordings, key: "Favorite Recordings")
        }
    }
}

