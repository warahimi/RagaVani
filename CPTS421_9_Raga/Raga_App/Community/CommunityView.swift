//
//  CommunityView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/12/23.
//

import SwiftUI

struct CommunityView : View {
    @State var users : [DBUserData]
    @EnvironmentObject var settings : UserData
    
    // get few ragas from users
    var exploreRagas : [Raga] {
        var ragas = [Raga]()
        
        // go through each user
        for user in users {
            let userRagas = user.favoriteRagas
            
            // get first user item
            if !userRagas.isEmpty {
                ragas.append(userRagas[0])
            }
            
            // save until have 3 ragas
            if ragas.count > 2 {
                return ragas
            }
        }
        
        return ragas
    }
    
    // get few recordings from users
    var exploreRecordings : [SavedRecording] {
        var recs = [SavedRecording]()
        
        // go through each yser
        for user in users {
            let rec = user.recordings
            
            // get first user item
            if !rec.isEmpty {
                recs.append(rec[0])
            }
            
            // save until have 3 recordings
            if recs.count > 2 {
                return recs
            }
        }
        
        return recs
    }
    
    // get few users
    var exploreUsers : [DBUserData] {
        let len = min(3, users.count)
        
        // get top 3 users
        return Array(users[0..<len])
    }
    
    // get all ragas
    var allRagas : [Raga] {
        var ragas = [Raga]()
        
        // go through each user, get ragas
        for user in users {
            ragas.append(contentsOf: user.favoriteRagas)
        }
        
        return ragas
    }
    
    // get all recordings
    var allRecordings : [SavedRecording] {
        var recordings = [SavedRecording]()
        
        // go through each user, get recording
        for user in users{
            recordings.append(contentsOf: user.recordings)
        }
        
        return recordings
    }
    
    var h = UIScreen.main.bounds.height
    var w = UIScreen.main.bounds.width
    
    var body: some View {
        ScrollView {
            VStack {
                // show title
                Text("Raga Community").font(.largeTitle)
                
                ZStack {
                    BorderRect("",.gray)
                    VStack(spacing:0) {
                        // show ragas
                        Text("Explore Ragas").padding()
                        
                        ForEach(exploreRagas) { raga in
                            // display raga
                            RagaRect(raga, .blue).frame(height:h/10).padding(.horizontal).padding(.vertical, 5)
                        }
                        
                        // show link to all ragas
                        NavigationLink {
                            RagaListView(title: "All User Ragas", items: .constant(allRagas), viewAll: false, h: h)
                        } label: {
                            BorderRect("Explore All Ragas", .blue,padding: true).padding()
                        }
                        
                        
                    }
                }.padding()
                
                ZStack {
                    BorderRect("", .gray)
                    VStack(spacing:0) {
                        // show recordings
                        Text("Explore Recordings").padding()
                        CommunityRecordingPageView(w: w, recordings: exploreRecordings,fullpage:false)
                        
                        // show link to all recordings
                        NavigationLink {
                            CommunityRecordingPageView(w: w, recordings: allRecordings)
                        } label: {
                            BorderRect("Explore All Recordings", .blue,padding: true).padding()
                        }
                        
                        
                    }
                }.padding()
                
                // show explore users
                ZStack {
                    BorderRect("",.gray)
                    VStack(spacing:0) {
                        // show title
                        Text("Explore Users").padding()
                        
                        ForEach(exploreUsers) { user in
                            NavigationLink {
                                UserPageView(user: user.user, recordings: user.recordings, ragas: user.favoriteRagas)
                            } label: {
                                ZStack {
                                    BorderRect("", .blue)
                                    VStack {
                                        Text(user.user.firstName).foregroundColor(.white)
                                    }.padding()
                                }
                            }.padding()
                        }
                        
                        // show link to all users
                        NavigationLink {
                            DisplayUsersView(users: users)
                        } label: {
                            BorderRect("Explore All Users", .blue,padding: true).padding()
                        }
                        
                    }
                }.padding()
            }
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityTopView()
    }
}
