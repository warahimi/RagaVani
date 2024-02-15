//
//  RecordingPageView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/7/23.
//

import SwiftUI
import AudioKit
import AVFAudio

struct RecordingPageView: View {
    @StateObject var handler : PlaybackHandler
    
    @State var recordIndex = -1
    @State var user = UserManager.shared
    @EnvironmentObject var data : UIData
    @EnvironmentObject var settings : UserData
    
    init() {
        _handler = StateObject(wrappedValue: PlaybackHandler(recordings: [SavedRecording]()))
    }
    
    var body: some View {
        GeometryReader { g in
            let w = g.frame(in:.local).width
            
            VStack(alignment: .center) {
                // show recording title
                Text("Recordings").font(.system(size:w/7))
                
                ScrollView {
                    // show all recordings
                    VStack {
                        ForEach(handler.recordings) { recording in
                            // show recording
                            RecorderView(recordIndex: $recordIndex, index:handler.recordings.firstIndex(of: recording)!,curRecording:recording).padding().frame(width:w/1.15)
                        }.padding()
                        Spacer()
                    }.environmentObject(handler)
                    
                    // show link to favorite recordings
                    NavigationLink {
                        FavoriteRecordingView(w: w, recordings: settings.favoriteRecordings)
                    } label: {
                        BorderRect("View Favorites", .blue, padding: true).padding()
                    }
                }
            }.onAppear() {
                settings.savedRecordings = UIData.initalizeData([SavedRecording](), "Saved Recordings") as! [SavedRecording]
                handler.recordings = settings.savedRecordings
            }.onChange(of: settings.savedRecordings) { _ in
                handler.recordings = settings.savedRecordings
            }
        }
    }
}




struct RecordingPageView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingPageView()
    }
}
