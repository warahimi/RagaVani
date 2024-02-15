//
//  ProfileView.swift
//  
//
//  Created by Wahidullah Rahimi on 9/21/23.
//

import SwiftUI
import Firebase

@MainActor
final class ProfileViewMode: ObservableObject{
    
    @Published private(set) var user: DatabaseUser? = nil
    
    // loads current user
    func loadCurrentUser() async throws {
        let authDataResult = try AutheticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
}

struct TopProfileView : View {
    @EnvironmentObject var data : UIData
    @EnvironmentObject var settings : UserData
    
    @State var editing = false
    @State var showChangeData = false
    @State var showSignIn = false
    
    @Binding var user : DatabaseUser?
    
    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            let h = g.size.height
            ZStack {
                // show editable version or regular version if not editing
                if showChangeData {
                    EditableProfileView(user:$user, editing: $showChangeData)
                }
                else {
                    RegularProfileView(user:$user, editing: $editing)
                }
                
                // if need to sign in to edit
                if showSignIn {
                    ZStack {
                        BorderRect("", .gray)
                        
                        ReAuthView(showSignInView: $showSignIn, success: $showChangeData, editing: $editing).padding()
                    }.frame(width:w/1.5, height:h/2).padding()
                   
                }
                
            }.onChange(of: editing) { _ in
                if editing {
                    showSignIn = true
                }
            }
        }
        
    }
}

