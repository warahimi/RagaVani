//
//  UserIconView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/17/23.
//

import SwiftUI

struct UserIconView: View {
    @Binding var accClicked : Bool
    var w : CGFloat
    var h: CGFloat
    @EnvironmentObject var data : UIData
    @Binding var user : DatabaseUser?
    @StateObject private var viewModel = SettingsViewUserModel()
    
    @EnvironmentObject var settings : UserData
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment:.trailing,spacing:5) {
                TapImage(name: "person.circle.fill") {
                    accClicked.toggle()
                }.foregroundStyle(.gray)

                // if clicked account button
                if accClicked {
                    // check if user signed in
                    if user == nil {
                        // user not signed in
                        
                        // display sign in button
                        IconRect("Sign In", .blue, image: "user icon").onTapGesture {
                            data.currentScene = "Sign In"
                            accClicked = false
                        }.frame(width:w/2.5, height:h/17).padding(.vertical, 2)
                    }
                    else {
                        // display account settings button
                        IconRect("Account", .blue, image: "user icon").onTapGesture {
                            data.currentScene = "Account Settings"
                            accClicked = false
                        }.frame(width:w/2.5, height:h/17).padding(.vertical, 2)
                        
                        // show sign out button
                        IconRect("Sign Out", .blue, image: "user icon").onTapGesture {
                            Task {
                                signOut()
                                settings.resetEverything()
                                
                                data.popupText = "Signed Out"
                                data.showPopup = true
                            }
                        }.frame(width:w/2.5, height:h/17).padding(.vertical, 2)
                    }
                    
                    // display settings button
                    IconRect("Settings", .blue, image: "settings").onTapGesture {
                        data.currentScene = "Settings"
                        accClicked = false
                    }.frame(width:w/2.5, height:h/17).padding(.vertical, 2)
                }
                
                Spacer()
            }.padding(.horizontal)
            
        }
    }
    
    // sign out button action
    func signOut() {
        do {
            // try to sign out
            try viewModel.signOut()
            
            // show popup
            data.popupText = "Signed Out"
            data.showPopup = true
            
            // remove current user
            user = nil
        } catch{
            print(error)
        }
        
        // go to play page
        if data.currentScene == "Account Settings" {
            data.currentScene = "Play"
        }
        
        // remove dropdown
        accClicked = false
    }
}

