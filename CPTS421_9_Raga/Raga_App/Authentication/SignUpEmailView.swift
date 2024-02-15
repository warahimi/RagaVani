//
//  SignUpEmailViewModel.swift
//
//
//  Created by Wahidullah Rahimi on 9/21/23.
//


import SwiftUI


struct SignUpEmailView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = SignUpEmailViewModel()
    @EnvironmentObject var data : UIData
    @EnvironmentObject var settings : UserData
    @State private var showAlert = false // To show an alert when passwords don't match
    @FocusState private var isEmailFieldFocused: Bool
    
    @State private var isFirstNameValid: Bool = true
    @State private var isLastNameValid: Bool = true
    
    @StateObject private var signOut = SettingsViewUserModel();
    @Binding var user : DatabaseUser?
    
    var body: some View {
        ScrollView {
            VStack(spacing:30) {
                Text("Sign Up").font(.system(size: 60))
                TextField("Email", text: $viewModel.email)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .focused($isEmailFieldFocused)
                    .onChange(of: isEmailFieldFocused) { isFocused in
                        if !isFocused {
                            validateEmail()
                        }
                    }
                
                if !viewModel.isEmailValid {
                    Text("Invalid email address")
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                VStack(alignment: .leading, spacing: 30) {
                    TextField("First Name", text: $viewModel.firstName)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(10)
                        .onChange(of: viewModel.firstName) { value in
                            isFirstNameValid = !value.trimmingCharacters(in: .whitespaces).isEmpty
                        }
                    
                    if !isFirstNameValid {
                        Text("First name is required")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    TextField("Last Name", text: $viewModel.lastName)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(10)
                        .onChange(of: viewModel.lastName) { value in
                            isLastNameValid = !value.trimmingCharacters(in: .whitespaces).isEmpty
                        }
                    
                    if !isLastNameValid {
                        Text("Last name is required")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                
                
                SecureField("Password", text: $viewModel.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .cornerRadius(10)
                    .background(Color.gray.opacity(viewModel.doPasswordsMatch ? 0.4 : 0.7)) // Make it reddish if passwords don't match
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(viewModel.doPasswordsMatch ? Color.clear : Color.red, lineWidth: 2)
                    )
                
                
                Button {
                    Task {
                        if !viewModel.checkPasswordsMatch() {
                            showAlert = true
                        } else {
                            do {
                                try await viewModel.signUp()
                                user = await UserManager.shared.getAuthUser()
                                data.popupText = "Signed In"
                                data.showPopup = true
                                settings.uploadData()
                                data.currentScene = "Play"
                                showSignInView = true
                            } catch let error as AuthError {
                                // Handle the custom error
                                data.popupText = error.localizedDescription
                                data.showPopup = true
                                do {
                                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3 seconds
                                    data.showPopup = false
                                } catch {
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                } label: {
                    Text("Sign up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                    //.background(Color.blue)
                        .background(isButtonActive ? Color.blue : Color.gray)
                    
                        .cornerRadius(10)
                        .opacity(isButtonActive ? 1 : 0.5)
                }
                .disabled(!isButtonActive)
                
                Spacer()
            }
        }
        .padding()
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error"), message: Text("Passwords do not match. Please confirm your password."), dismissButton: .default(Text("OK")))
        })
        .onReceive(KeyboardHandler.shared.$keyboardFrame) { keyboardFrame in
            if let keyboardFrame = keyboardFrame, keyboardFrame != .zero {
                data.showNav = false
            } else {
                data.showNav = true
            }
        }
    }
    
    func validateEmail() {
        viewModel.isEmailValid = viewModel.isValidEmail(viewModel.email)
    }
    var isButtonActive: Bool {
        !viewModel.firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !viewModel.lastName.trimmingCharacters(in: .whitespaces).isEmpty
        &&
        viewModel.isEmailValid
        &&
        isFirstNameValid
        &&
        isLastNameValid
        &&
        !viewModel.password.isEmpty
        &&
        !viewModel.confirmPassword.isEmpty
    }
}





