//
//  DisplayUsersView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct DisplayUsersView : View {
    @State var users : [DBUserData]
    var body : some View {
        ZStack {
            BorderRect("",.gray)
            ScrollView {
                VStack {
                    // show title
                    Text("Explore Users").padding()
                    
                    // show all users
                    ForEach(users) { user in
                        // display link to uer page
                        NavigationLink {
                            UserPageView(user: user.user, recordings: user.recordings, ragas: user.favoriteRagas)
                        } label: {
                            ZStack {
                                BorderRect("", .blue)
                                VStack {
                                    // show user name
                                    Text(user.user.firstName).foregroundColor(.black)
                                }.padding()
                            }
                        }.padding()
                    }
                    
                }
            }
            
        }.padding()
    }
}
