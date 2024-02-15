//
//  EditableProfileView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct EditableProfileView: View {
    @Binding var user : DatabaseUser?
    @StateObject private var viewModel = SettingsViewUserModel()
    @EnvironmentObject var data : UIData
    @EnvironmentObject var settings : UserData
    
    @Binding var editing : Bool
    
    @State var showEmailAlert : Bool = false
    @State var showPasswordAlert : Bool = false
    @State var input : String = ""
    
    var body: some View {
        GeometryReader  { g in
            let h = g.size.height
            
            ZStack {
                VStack(alignment:.center) {
                    // show title
                    Text("Profile")
                    ZStack {
                        BorderRect("", .gray)
                        
                        // show user detauls
                        VStack {
                            Text("User Details")
                            
                            // show user email
                            HStack {
                                if let email = user?.email{
                                    BorderRect("User Email: \(email)",.blue)
                                }
                                
                                Spacer()
                                
                                // reset button
                                Button {
                                    showEmailAlert = true
                                } label: {
                                    BorderRect("Reset", .blue, padding: true)
                                }
                                
                            }
                            
                            // show user name
                            HStack {
                                if let firstName = user?.firstName{
                                    if let lastName = user?.lastName{
                                        BorderRect("Name: \(firstName) \(lastName)",.blue)
                                    }
                                }
                                
                                Spacer()
                                
                                // reset name
                                Button {
                                    
                                } label: {
                                    BorderRect("Reset", .blue, padding: true)
                                }
                            }
                        }.padding()
                        .alert("Enter Email", isPresented: $showEmailAlert) {
                            TextField("...", text: $input)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            Button("OK") {
                                Task {
                                    await changeEmail()
                                    user = await UserManager.shared.getAuthUser()
                                }
                            }
                            Button("Back") {
                                input = ""
                                showEmailAlert = false
                            }
                        }
                        
                        
                        
                    }.frame(height: h/3).padding()
                
                    VStack(spacing:0) {
                        // delete account button
                        BorderRect("Delete Account", .red).onTapGesture {
                            Task {
                                await deleteAccount()
                            }
                        }.padding()
                        
                        // reset password button
                        BorderRect("Reset Account Password", .red).onTapGesture {
                            showPasswordAlert = true
                        }.padding()
                        
                        .alert("Enter Password", isPresented: $showPasswordAlert) {
                            // input password
                            SecureField("...", text: $input)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            
                            // change password
                            Button("OK") {
                                Task {
                                    await changePassword()
                                }
                            }
                            
                            // leave alert
                            Button("Back") {
                                input = ""
                                showPasswordAlert = false
                            }
                        }
                    }.frame(height:h/3)
                    Spacer()
                }
            }
        }
    }
    
    // delete account
    func deleteAccount() async {
        do {
            // get user id
            let userId = try UserManager.shared.getSignedInUserId()
            try await viewModel.deleteUser()
            
            // try to delete profile
            viewModel.deleteUserProfile(userId: userId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("User profile successfully deleted.")
                        settings.resetEverything()
                        
                        data.popupText = "Account Deleted"
                        data.showPopup = true
                        data.currentScene = "Play"
                    case .failure(let error):
                        print("Error deleting user profile: \(error.localizedDescription)")
                    }
                }
            }
        } catch{
            print(error)
        }
    }
    
    // change password
    func changePassword() async {
        if input != "" {
            do {
                // try to change password
                try await viewModel.updatePassword(password: input)
                user = await UserManager.shared.getAuthUser()
                
                // show popup
                data.popupText = "Password was reset"
                data.showPopup = true
            } catch {
                // show failed popup
                data.popupText = "Password reset failure"
                data.showPopup = true
            }
            
        }
        
        // reset alert
        input = ""
        showPasswordAlert = false
    }
    
    // change email
    func changeEmail() async {
        if input != "" {
            do {
                // attempt to updat email
                try await viewModel.updateEmail(email: input)
                user = await UserManager.shared.getAuthUser()
                
                // show popup
                data.popupText = "Updated Email"
                data.showPopup = true
            } catch {
                // show failed popup
                data.popupText = "Email reset failure"
                data.showPopup = true
            }
            
        }
        
        // reset alert
        input = ""
        showEmailAlert = false
    }
}
