//
//  ReAuthView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct ReAuthView: View {
    @Binding var showSignInView:Bool
    @Binding var success : Bool
    @Binding var editing: Bool
    
    @StateObject var viewModel = SignInEmailViewModel()
    
    @EnvironmentObject var data : UIData
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    
                    // close out of reauth
                    TapImage(name:"xmark") {
                        showSignInView = false
                        success = false
                        editing = false
                    }
                }
                Spacer()
            }
            
            VStack(spacing: 30){
                // show title
                Text("Reauthenticate")
                
                // password field
                SecureField("Password ...", text: $viewModel.password)
                    .padding()
                    .background(Color.white) // Make it reddish if passwords don't match
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(viewModel.isPasswordCorrect ? Color.clear : Color.red, lineWidth: 2)
                    )
                
                Button {
                    Task{
                        await authenticate()
                    }
                } label: {
                    HStack {
                        Text("Sign in")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                }

                Spacer()
                
            }
            .padding() // padding to whole vstack
        }
    }
    
    func authenticate() async {
        do{
            // get user
            let user = await UserManager.shared.getAuthUser()
            
            // try to sign in
            viewModel.email = user!.email!
            try await viewModel.signIn()
            
            // show sucess
            showSignInView = false
            success = true
            editing = false
        } catch{
            // incorrect password
            viewModel.isPasswordCorrect = false
            viewModel.password = ""
        }
    }
}
