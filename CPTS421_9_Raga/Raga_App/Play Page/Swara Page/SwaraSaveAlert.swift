//
//  SwaraSaveAlert.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct SwaraSaveAlert: View {
    @EnvironmentObject var ragaSettings : UserData
    @State var input = ""
    @State var uploading = false
    
    @Binding var showingSaveAlert : Bool
    @Binding var ragaCategory : String
    @Binding var ragaName : String
    @Binding var selections : [Int]
    
    var h : CGFloat
    var w : CGFloat
    
    var body: some View {
        Spacer()
        VStack(alignment: .center) {
            Spacer()
            ZStack {
                BorderRect("", .gray)
                
                VStack {
                    Text("Create a Raga").font(.largeTitle)
                    Spacer()
                    Text("Created Ragas").italic()
                    // display all created ragas
                    ScrollView {
                        if ragaSettings.createdRagas.isEmpty {
                            BorderRect("No Created Ragas Yet", .blue, padding: true).padding()
                        }
                        else {
                            ForEach(ragaSettings.createdRagas) { raga in
                                SmallRagaInfo(raga: raga, h: h, w: w)
                            }
                        }
                        
                    }
                }
            }
            
            // text input for name
            TextField("Raga Name", text: $input)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .background(.gray.opacity(0.2))
                .foregroundColor(.black)
                .frame(width:w/2, height:h/3)
            
            HStack {
                Spacer()
                // save button
                Button("OK") {
                    addToCreated()
                }
                Spacer()
                // reset button
                Button("Back") {
                    input = ""
                    showingSaveAlert = false
                }
                Spacer()
            }
            Spacer()
        }.padding()
        Spacer()
    }
    
    func addToCreated() {
        // dont allow multiple uploads at once
        if uploading {
            return
        }
        
        uploading = true
        
        // check if name matches any ragas in created
        let hasRaga = ragaSettings.createdRagas.contains { raga in
            return raga.name == input
        }
        
        // get id, create new raga
        let userId = DatabaseManager.shared.getID() ?? "local user"
        var newRaga = Raga(id:UUID().uuidString,userId:userId,inputs: selections, samvadi: "Sa", vadi: "Pa", name: input, description: "Created Raga", category: ragaCategory,is_public: false)
        
        // check if doesnt have this raga yet
        if !hasRaga {
            // add to db
            DatabaseManager.shared.addRagaToCreated(rag: newRaga) { result in
                switch result {
                case .success(let id) :
                    newRaga.id = id
                    
                case .failure(let error):
                    // save failed upload
                    print(error.localizedDescription)
                    ragaSettings.databaseTransactions.append(DatabaseTransaction(command: "Add", collection: "Created", raga: newRaga))
                    UIData.updateData(ragaSettings.databaseTransactions, key: "Database Transactions")
                }
                
                // add raga to created
                ragaSettings.createdRagas.append(newRaga)
                
                // update data
                UIData.updateData(ragaSettings.createdRagas, key: "Created Ragas")
                
                // stop showing
                showingSaveAlert = false
                uploading = false
                
            }
            
        }
        else {
            uploading = false
        }
        
        // reset input
        input = ""
    }
}

struct SmallRagaInfo : View {
    @State var raga : Raga
    @State var expanded = false
    
    var h : CGFloat
    var w : CGFloat
    
    var body : some View {
        ZStack {
            BorderRect("", .blue)
            TapImage(name: expanded ? "chevron.up" : "chevron.down") {
                expanded.toggle()
            }.topRight()
            
            VStack {
                // display name, swaras
                Text(raga.name).italic().font(.largeTitle)
                if expanded {
                    ZStack {
                        BorderRect("", .gray)
                        RagaPageSwaraSelector(selections: $raga.inputs, h:h, w:w/2.5).allowsHitTesting(false)
                    }
                    
                }
                
            }.padding()
        }.padding()
    }
}

struct SmallRagaInfoTapable : View {
    @State var raga : Raga
    @State var expanded = false
    
    var h : CGFloat
    var w : CGFloat
    
    var tapped : () -> Void
    
    var body : some View {
        ZStack {
            BorderRect("", .blue)
            TapImage(name: expanded ? "chevron.up" : "chevron.down") {
                expanded.toggle()
            }.topRight()
            
            VStack {
                // display name, swaras
                Text(raga.name).italic().font(.largeTitle).underline().onTapGesture {
                    tapped()
                }
                if expanded {
                    ZStack {
                        BorderRect("", .gray)
                        RagaPageSwaraSelector(selections: $raga.inputs, h:h, w:w/2.5).allowsHitTesting(false)
                    }
                    
                }
                
            }.padding()
        }.padding()
    }
}
