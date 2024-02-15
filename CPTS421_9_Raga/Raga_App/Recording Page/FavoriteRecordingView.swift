//
//  FavoriteRecordingView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct FavoriteRecordingView : View {
    @State var handler : PlaybackHandler
    @State var recordIndex = -1
    @EnvironmentObject var settings : UserData
    var w : CGFloat
    
    init(w : CGFloat, recordings: [SavedRecording]) {
        self.w = w
        self.handler = PlaybackHandler(recordings: recordings)
    }
    
    var body : some View {
        VStack(alignment: .center) {
            // show title
            Text("Recordings").font(.system(size:w/7))
            
            ScrollView {
                // show all recordings
                VStack() {
                    ForEach(handler.recordings) { recording in
                        // show recording
                        RecorderViewOnline(recordIndex: $recordIndex, index:handler.recordings.firstIndex(of: recording)!,curRecording:recording).frame(width:w/1.15)
                    }.padding()
                    Spacer()
                }.environmentObject(handler)
            
            }
        }
        .onChange(of: settings.favoriteRecordings) { _ in
            // set recordings when changed
            handler.recordings = settings.favoriteRecordings
        }
    }
}
