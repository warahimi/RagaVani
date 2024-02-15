//
//  CommunityRecordingPageView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct CommunityRecordingPageView: View {
    @State var handler : PlaybackHandler
    @State var recordIndex = -1
    @State var w : CGFloat
    var fullpage : Bool
    
    init(recordIndex: Int = 1, w: CGFloat, recordings:[SavedRecording],fullpage:Bool=true) {
        self.handler = PlaybackHandler(recordings: recordings)
        self.recordIndex = recordIndex
        self.w = w
        self.fullpage=fullpage
    }
    
    var body: some View {
        // check if fullpage or not
        if fullpage {
            VStack(alignment: .center) {
                // show title
                Text("Recordings").font(.system(size:w/7))
                ScrollView {
                    // show all recordings
                    VStack {
                        ForEach(0..<handler.recordings.count, id: \.self) { index in
                            // show recording
                            RecorderViewOnline(recordIndex: $recordIndex, index: index, curRecording: handler.recordings[index]).frame(width:w/1.15)
                        }.padding()
                        Spacer()
                    }.environmentObject(handler)
                }
            }
        }
        else {
            VStack(alignment: .center) {
                // show all recordings
                ForEach(0..<handler.recordings.count, id: \.self) { index in
                    // show recording
                    RecorderViewOnline(recordIndex: $recordIndex, index: index, curRecording: handler.recordings[index])
                }.padding()
                Spacer()
            }
            .environmentObject(handler)
            
        }
    }
}
