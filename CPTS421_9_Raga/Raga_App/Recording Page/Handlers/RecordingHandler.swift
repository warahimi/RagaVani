//
//  RecordingHandler.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/17/23.
//

import Foundation

class RecordingHandler {
    static let documentPath = getRecordingPath()
    static let onlinePath = getTempRecordingPath()
    static let manager = FileManager.default
    
    // creates local recording path
    static func getRecordingPath() -> URL {
        let path = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let newPath = path.appending(path:"/recordings")
        if !manager.fileExists(atPath: newPath.path) {
            try? manager.createDirectory(atPath: newPath.path, withIntermediateDirectories: false)
        }
        
        return newPath
    }
    
    // create temp recording path for online files
    static func getTempRecordingPath() -> URL {
        let path = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let newPath = path.appending(path:"/temp")
        if !manager.fileExists(atPath: newPath.path) {
            try? manager.createDirectory(atPath: newPath.path, withIntermediateDirectories: false)
        }
        
        return newPath
    }
    
    // clear local recordings
    static func clearRecordings() {
        for url in self.getFiles() {
            removeRecording(url: url)
        }
    }
    
    // clear online recordings
    static func clearOnlineRecordings() {
        for url in self.getOnlineFiles() {
            removeRecording(url: url)
        }
    }
    
    // moev file
    static func moveAudioFile(sourceURL: URL, destinationDirectoryURL: URL, newFileName: String) throws {
        // Create a file manager
        let fileManager = FileManager.default

        print(sourceURL.pathExtension)
        // Check if the source file exists
        if fileManager.fileExists(atPath: sourceURL.path) {
            // Create the destination directory if it doesn't exist
            if !fileManager.fileExists(atPath: destinationDirectoryURL.path) {
                try fileManager.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            }

            // Create the destination URL for the renamed file
            let destinationURL = destinationDirectoryURL.appendingPathComponent(newFileName + ".caf")

            // Copy the source file to the destination URL
            try fileManager.copyItem(at: sourceURL, to: destinationURL)

            // Optionally, you can remove the source file if needed
            try fileManager.removeItem(at: sourceURL)

            // Verify that the file was successfully copied and renamed
            if fileManager.fileExists(atPath: destinationURL.path) {
                print("File copied and renamed successfully.")
            } else {
                print("Failed to copy and rename the file.")
            }
        } else {
            print("Source file does not exist.")
        }
    }
    
    // add online file
    static func addOnlinefile(sourceURL: URL) throws {
        try moveAudioFile(sourceURL: sourceURL, destinationDirectoryURL: documentPath, newFileName: sourceURL.lastPathComponent)
    }
    
    // remove given recording
    static func removeRecording(url:URL) {
        do {
            try FileManager.default.removeItem(at: url)
        }
        catch {}
    }
    
    // get all local files
    static func getFiles() -> [URL] {
        return try! manager.contentsOfDirectory(at: RecordingHandler.documentPath, includingPropertiesForKeys: [])
    }
    
    // get all online files
    static func getOnlineFiles() -> [URL] {
        return try! manager.contentsOfDirectory(at: RecordingHandler.onlinePath, includingPropertiesForKeys: [])
    }
    
    // convert string to url
    static func urlAt(_ str:String) -> URL {
        return URL(string: str)!
    }
}
