//
//  RegularProfileView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct RegularProfileView: View {
    @Binding var user : DatabaseUser?
    @EnvironmentObject var data : UIData
    @EnvironmentObject var settings : UserData
    
    @Binding var editing : Bool
    
    var body: some View {
        GeometryReader  { g in
            let h = g.size.height
            
            ZStack {
                // edit button
                TapImage(name:"pencil") {
                    editing = true
                }.topLeft()
                
                VStack {
                    // show title
                    Text("Profile")
                    
                    ZStack {
                        BorderRect("", .gray)
                        
                        // show user details
                        VStack {
                            Text("User Details")
                            
                            // show email
                            HStack {
                                if let email = user?.email{
                                    BorderRect("User Email: \(email)",.blue)
                                }
                                Spacer()
                                
                            }
                            
                            // show name
                            HStack {
                                if let firstName = user?.firstName{
                                    if let lastName = user?.lastName{
                                        BorderRect("Name: \(firstName) \(lastName)",.blue)
                                    }
                                }
                            }
                        }.padding()
                    }.frame(height: h/3).padding()
                    
                    Spacer()
                }
            }
        }

    }
}
