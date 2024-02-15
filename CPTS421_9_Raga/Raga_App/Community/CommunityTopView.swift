//
//  CommunityTopView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct CommunityTopView: View {
    @State var users = [DBUserData]()
    @State var loaded = 0
    
    var body: some View {
        ZStack {
            // wait for loading
            if loaded >= 1 {
                // show community
                NavigationStack {
                    CommunityView(users: users)
                }
                
            }
            else {
                // show loading
                LoadingView()
            }
            
        }.onAppear() {
            Task {
                // get all user data
                CommunityDBHandler.shared.getAllUserData { fetchedUserData in
                    var newFetched = [DBUserData]()
                    
                    // goes through fetched user data, clears out private ragas
                    for fetch in fetchedUserData {
                        var filtered = fetch
                        var ragas = [Raga]()
                        
                        // goes through favorite ragas
                        for rag in filtered.favoriteRagas {
                            if rag.is_public {
                                ragas.append(rag)
                            }
                        }
                        
                        // saves filtered ragas
                        filtered.favoriteRagas = ragas
                        newFetched.append(filtered)
                    }
                    
                    users = newFetched
                    loaded += 1
                }
            }
        }
    }
}
