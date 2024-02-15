//
//  AuthenticationView.swift
//  
//
//  Created by Wahidullah Rahimi on 9/20/23.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    @Binding var user : DatabaseUser?

    
    var body: some View {
        VStack(spacing:30){
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView, user:$user)// go to this view
            } label: {
                Text("Sign in with email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.top)
            }
            
            NavigationLink {
                SignUpEmailView(showSignInView: $showSignInView, user:$user)// go to this view
            } label: {
                Text("Sign up with email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign in")
    }
}
