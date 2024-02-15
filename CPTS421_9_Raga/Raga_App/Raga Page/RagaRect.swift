//
//  RagaRect.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct RagaRect : View {
    var raga:Raga
    var color:Color
    @State var uploading = false
    var h:CGFloat = UIScreen.main.bounds.width
    var displayRect : Bool
    
    @EnvironmentObject var settings: InstrumentSettings
    @EnvironmentObject var user: UserData
    
    @State var isActive = false
    
    init(_ raga: Raga, _ color:Color, displayRect:Bool=true) {
        self.raga = raga
        self.color = color
        self.displayRect = displayRect
    }
    
    var body : some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(color)
            .overlay {
                RoundedRectangle(cornerRadius:15).stroke(.black, lineWidth: 3)
            }
            
            HStack(spacing: 0) {
                // favorite button
                
                TapImage(name: user.savedRagas.contains { r in return raga.id == r.id} ? "star.fill" : "star", padding: false) {
                    handleFavorite()
                }.padding(.horizontal)
                
                // info button
                NavigationLink {
                    RagaInfoView(showRaga: raga, editRaga : raga).environmentObject(user)
                } label: {
                    HStack(spacing:0) {
                        Text(raga.name).foregroundColor(.white)
                        Image(systemName: "info.circle").defaultStyle().foregroundStyle(.black).padding(4)
                    }
                }

                // select button
                Spacer()
                if displayRect {
                    BorderRect("", raga.inputs == settings.swaras ? .green : .white).frame(width:h/10, height: h/10).padding(.bottom, 5).padding(.top, 5).padding(.trailing).onTapGesture {
                        // set swaras
                        settings.swaras = raga.inputs
                        user.selectedRaga = raga
                    }
                }
                
            }
        }
    }
    
    func handleFavorite() {
        // avoid upload spamming
        if uploading {
            return
        }
        
        uploading = true
        
        // check if removing or adding
        if user.savedRagas.contains(raga) {
            // get remove index
            let index = user.savedRagas.firstIndex { saved in
                return saved.id == raga.id
            }
            
            // remove saved, update
            user.savedRagas.remove(at: index!)
            UIData.updateData(user.savedRagas, key: "Saved Ragas")
            
            // update database
            DatabaseManager.shared.deleteRagaFromSaved(raga: raga) { result in
                switch(result) {
                case .success(let s) :
                    print(s)
                case .failure(let error) :
                    print(error.localizedDescription)
                    user.databaseTransactions.append(DatabaseTransaction(command: "Delete", collection: "Saved", raga: raga))
                    UIData.updateData(user.databaseTransactions, key: "Database Transactions")
                }
                
                uploading = false
            }
        }
        else {
            // add saved raga
            user.savedRagas.append(raga)
            UIData.updateData(user.savedRagas, key: "Saved Ragas")
            
            // update database
            DatabaseManager.shared.addRagaToSaved(raga: raga) { result in
                switch result {
                case .success(let success) :
                    print(success)
                case .failure(let error):
                    print(error.localizedDescription)
                    user.databaseTransactions.append(DatabaseTransaction(command: "Add", collection: "Saved", raga: raga))
                    UIData.updateData(user.databaseTransactions, key: "Database Transactions")
                }
                
                uploading = false
            }
        }
    }
}
