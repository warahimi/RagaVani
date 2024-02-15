//
//  SingnInEmailView.swift
// 
//
//  Created by Wahidullah Rahimi on 9/20/23.
//

import SwiftUI


struct SignInEmailView: View {
    @Binding var showSignInView:Bool
    @Binding var user : DatabaseUser?
    @StateObject var viewModel = SignInEmailViewModel()
    
    @EnvironmentObject var data : UIData
    @EnvironmentObject var settings : UserData
    
    var body: some View {
        VStack(spacing: 30){
            Text("Sign In").font(.system(size: 60))
            TextField("Email ...", text: $viewModel.email)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password ...", text: $viewModel.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
                .background(Color.gray.opacity(viewModel.isPasswordCorrect ? 0.4 : 0.7)) // Make it reddish if passwords don't match
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.isPasswordCorrect ? Color.clear : Color.red, lineWidth: 2)
                )
            
            NavigationLink {
                SignUpEmailView(showSignInView: $showSignInView, user: $user)
            } label: {
                HStack(spacing: 0) {
                    Text("Don't have an account? ").italic().foregroundColor(.black)
                    Text("Sign Up").italic().underline().foregroundColor(.black)
                }
                
            }
            
            NavigationLink {
                ForgotPasswordView()
            } label: {
                HStack(spacing: 0) {
                    Text("Forgot password? ").italic().foregroundColor(.black)
                    
                }
                
            }
            
            Button {
                Task{
                    do{
                        try await viewModel.signIn()
                        user = await UserManager.shared.getAuthUser()
                        showSignInView = false
                        
                        settings.loadData()
                        
                        data.popupText = "Signed In"
                        data.showPopup = true
                        data.currentScene = "Play"
                        // if successfully signed in
                        //return
                    } catch{
                        viewModel.isPasswordCorrect = false
                        viewModel.password = ""
                        print(error)
                    }
                    
                    // we hit here if sign in was not successful
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

