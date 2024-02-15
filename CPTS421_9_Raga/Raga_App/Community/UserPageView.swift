//
//  UserPageView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct UserPageView : View {
    var user : User2
    var recordings : [SavedRecording]
    var ragas : [Raga]
    
    @State var handler : PlaybackHandler
    @State var recordIndex = -1
    @EnvironmentObject var settings : UserData
    
    @State var w : CGFloat = UIScreen.main.bounds.width
    
    init(user: User2, recordings: [SavedRecording], ragas: [Raga]) {
        self.user = user
        self.recordings = recordings
        self.ragas = ragas
        self.handler = PlaybackHandler(recordings:recordings)
    }
    
    var body : some View {
        ScrollView {
            HStack {
                VStack {
                    // display username
                    BorderRect(user.firstName + " " + user.lastName, .blue,padding: true).padding()
                    
                    // display all created ragas
                    ZStack {
                        BorderRect("", .gray)
                        VStack(spacing:0) {
                            Text("Created Ragas").padding()
                            ForEach(ragas) { raga in
                                // display raga
                                RagaRect(raga, .blue).padding()
                            }.padding()
                        }
                    }.padding()
                    
                    // display all recordings
                    ZStack {
                        BorderRect("", .gray).frame(maxWidth: w/1.1)
                        VStack(spacing:0) {
                            Text("Created Recordings").padding()
                            ForEach(0..<handler.recordings.count, id: \.self) { index in
                                // display recording
                                RecorderViewOnline(recordIndex: $recordIndex, index:index,curRecording:handler.recordings[index])
                                    
                            }.padding()
                        }.padding()
                    }
                    .frame(maxWidth: w/1.1)
                    .padding()
                    .environmentObject(handler)
                }
            }.padding()
            
        }
        
    }
}
