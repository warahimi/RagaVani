//
//  RagaInfoView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/16/23.
//

import SwiftUI

struct RagaInfoView : View {
    @State var showRaga : Raga
    @EnvironmentObject var settings : UserData
    @State var editing = false
    @State var editRaga : Raga
    
    var body : some View {
        ZStack {
            // get raga index in created
            let index = settings.createdRagas.firstIndex(of: showRaga)
            
            // show editable view or normal view
            if editing {
                EditableInfoView(showRaga: $editRaga)
            }
            else {
                NormalInfoView(showRaga: showRaga)
            }
            
            // if created raga, show edit
            if let index = index {
                VStack {
                    HStack {
                        // edit button
                        TapImage(name: "pencil") {
                            editing.toggle()
                            editRaga = settings.createdRagas[index]
                        }

                        // display save button if editing
                        if editing {
                            TapImage(name: "square.and.arrow.down") {
                                handleSaveInfo(index)
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
    
    func handleSaveInfo(_ index : Int) {
        // toggle editing mode
        editing.toggle()
        
        // set created raga
        settings.createdRagas[index] = editRaga
        showRaga = editRaga
        
        // update created raga in database
        DatabaseManager.shared.updateCreatedRaga(raga: editRaga) { result in
            if !result {
                settings.databaseTransactions.append(DatabaseTransaction(command: "Update", collection: "Created", raga: editRaga))
                UIData.updateData(settings.databaseTransactions, key: "Database Transactions")
            }
        }

        UIData.updateData(settings.createdRagas, key: "Created Ragas")
    }
}
