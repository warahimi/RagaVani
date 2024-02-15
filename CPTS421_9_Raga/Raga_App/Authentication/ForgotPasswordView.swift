//
//  ForgotPasswordView.swift
//  Raga_App
//
//  Created by Wahidullah Rahimi on 11/21/23.
//



import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email_address = ""
    @State private var showingAlert = false
    @State private var showingEmailNotRegisteredAlert = false
    @EnvironmentObject var data : UIData


    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter your email", text: $email_address)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)

            Button("Reset Password") {
                Task {
                    await resetPassword()
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(isValidEmail(email_address) ? Color.blue : Color.gray)
            .cornerRadius(10)
            .disabled(!isValidEmail(email_address))
            .alert("A password reset link sent to your email. Please check your email.", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    data.currentScene = "Play"
                }
            }
            .alert("Email address not registered", isPresented: $showingEmailNotRegisteredAlert) {
                Button("OK", role: .cancel) {}
            }
        }
        .padding()
    }

    func resetPassword() async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email_address)
            showingAlert = true
        } catch let error as NSError {
            if error.code == AuthErrorCode.userNotFound.rawValue {
                showingEmailNotRegisteredAlert = true
            } else {
                print("Error in sending password reset email: \(error)")
            }
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
