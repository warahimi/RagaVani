//
//  PlaybackHandler.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/17/23.
//

import Foundation
import AudioKit
import AVFAudio

struct SavedRecording : Codable, Identifiable, Equatable {
    var id : String
    var userId : String
    var name : String
    var isPublic: Bool
    var URL : String
    var date_created : String
    var duration : Double
    
    enum CodingKeys: String, CodingKey {
        case id, userId, name, isPublic = "is_public", URL, date_created, duration
    }
}

struct UsernamelessRecording : Codable, Identifiable, Equatable {
    var id : String
    var name : String
    var isPublic: Bool
    var URL : String
    var date_created : String
    var duration : Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, isPublic, URL, date_created, duration
    }
}

class PlaybackHandler : ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    @Published var player = AudioPlayer()
    @Published var lastIndex = -1
    @Published var recordings : [SavedRecording]
    
    init(recordings: [SavedRecording]) {
        self.recordings = recordings
        engine.output = player
        try! engine.start()
    }
    
    // rename recording
    func renameRecording(name:String, _ index:Int) {
        recordings[index].name = name
        
        // save data
        UIData.updateData(recordings, key: "Saved Recordings")
    }
    
    // check if playing playing and not paused
    func isPlaying(_ index:Int) -> Bool {
        return player.isStarted && lastIndex == index
    }
    
    // Play the recorded audio file
    func playRecordedAudio(index:Int, startLocation:TimeInterval=0) -> Bool {
        // check if already playing
        if index == lastIndex && player.isPlaying {
            player.play()
            return true
        }
        
        // stop if other recording playing
        if player.isPlaying {
            player.stop()
            engine.stop()
            player = AudioPlayer()
            engine.output = player
            try! engine.start()
        }
        
        player.reset()
        
        // play new recording
        do {
            try player.load(url:getPath(index))
            player.play(from:startLocation)
        }
        catch {
            return false
        }
        
        return true
    }
    
    // play online audio
    func playOnlineRecordedAudio(index:Int) -> Bool {
        // check if already playing
        if index == lastIndex && player.isPlaying {
            player.play()
            return true
        }
        
        // stop if other recording playing
        if player.isPlaying {
            player.stop()
            engine.stop()
            player = AudioPlayer()
            engine.output = player
            try! engine.start()
        }
        
        player.reset()
        
        // play new recording
        do {
            try player.load(url: getOnlinePath(index))
            player.play()
        }
        catch {
            return false
        }
        
        return true
    }
    
    // stop playing audio
    func stopRecordedAudio() {
        player.stop()
    }
    
    // remove regular recording
    func removeFile(index:Int) {
        RecordingHandler.removeRecording(url: getPath(index))
    }
    
    // remove favorite recording
    func removeFavorite(index:Int) {
        RecordingHandler.removeRecording(url: getPath(index))
        recordings.remove(at: index)
        UIData.updateData(recordings, key: "Favorite Recordings")
    }
    
    // get local path at index
    func getPath(_ index:Int) -> URL {
        let path = RecordingHandler.getRecordingPath()
        return path.appendingPathComponent(recordings[index].URL + ".caf")
    }
    
    // get online path at index
    func getOnlinePath(_ index:Int) -> URL {
        let path = RecordingHandler.getTempRecordingPath()
        return path.appendingPathComponent(recordings[index].URL + ".caf")
    }
}
