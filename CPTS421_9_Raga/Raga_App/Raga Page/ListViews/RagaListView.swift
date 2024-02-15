//
//  RagaListView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct RagaListView : View {
    var title:String
    @Binding var items:[Raga]
    var viewAll = true
    var created = false
    
    @State var h:CGFloat
    
    @EnvironmentObject var user: UserData
    @State var uploading = false
    
    @State var searchResults = [Raga]()
    
    // get listed items
    var getSearch: [Raga] {
        let curItems : [Raga]
        
        // check if want to list all items or top 3
        if !viewAll {
            curItems = items
        }
        else {
            let count = min(items.count, 3)
            curItems = Array(items[..<count])
        }
        
        // no sort, return
        if sortType == "None" {
            return curItems
        }
        
        // sort by given query
        let sorted = curItems.sorted { r1, r2 in
            switch(sortType) {
            case "Name" :
                return r1.name < r2.name
            case "Category" :
                return r1.category < r2.category
            default :
                break
            }
            return r1.name < r2.name
        }
        
        return sorted
    }
    
    @State var sortType = "None"
    
    var body : some View {
        ZStack {
        BorderRect("", .gray)
            VStack(spacing:0) {
                
                // if showing all ragas, show sort by
                if !viewAll {
                    HStack {
                        Text(title).padding()
                        
                        // sort menu
                        Menu {
                            // sort picker
                            Picker("Sort By", selection: $sortType) {
                                ForEach(["Name", "Category","None"], id: \.self) {
                                    Text(String($0))
                                }
                            }
                        } label : {
                            Image(systemName: "line.3.horizontal.decrease.circle").defaultStyle().padding().foregroundStyle(.black)
                        }
                    }
                }
                else {
                    // just show title otherwise
                    Text(title).padding()
                }
                
                if !searchResults.isEmpty {
                    VStack(spacing:5) {
                        // list all raga results
                        ForEach(0..<searchResults.count, id:\.self) { i in
                            HStack {
                                Spacer()
                                // show raga
                                RagaRect(searchResults[i], .blue).frame(height:h/10).padding(.horizontal)
                                
                                // if a created raga
                                if created {
                                    // delete button
                                    TapImage(name: "trash", padding: false) {
                                        handleDeletePress(i)
                                    }
                                    
                                    // share button
                                    TapImage(name: searchResults[i].is_public ? "shareplay" : "shareplay.slash", padding: false) {
                                        handleSharePress(i)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                        }
                        
                        // add view all button
                        if viewAll && items.count > 3 {
                            NavigationLink {
                                ScrollView {
                                    RagaListView(title: title, items: $items, viewAll: false,created: created, h: h).padding()
                                }
                            } label: {
                                BorderRect("View all " + title, .blue).frame(height:h/10).padding()
                            }
                        }
                        
                        Spacer()
                    }
                }
                else {
                    BorderRect("No \(title) found", .blue, padding: true).frame(height:h/10).padding()
                }
                
            }
        }
        .onAppear() {
            // get search results when first load in
            searchResults = getSearch
        }
        .onChange(of: sortType) {_ in
            // update search
            searchResults = getSearch
        }
        .onChange(of: items) { _ in
            searchResults = getSearch
        }
    }
    
    func handleSharePress(_ i : Int) {
        if uploading {
            return
        }
        
        uploading = true
        let index = user.createdRagas.firstIndex { rag in
            return rag.name == searchResults[i].name && rag.inputs == searchResults[i].inputs
        }
        
        if index != nil {
            var curRaga = searchResults[i]
            curRaga.is_public.toggle()
            DatabaseManager.shared.updateCreatedRaga(raga: curRaga) { result in
                if !result {
                    user.databaseTransactions.append(DatabaseTransaction(command: "Update", collection: "Created", raga: curRaga))
                    UIData.updateData(user.databaseTransactions, key: "Database Transactions")
                }
                
                print(result)
                uploading = false
            }
            user.createdRagas[index!].is_public.toggle()

            UIData.updateData(user.createdRagas, key: "Created Ragas")
        }
        else {
            uploading = false
        }
    }
    
    func handleDeletePress(_ i : Int) {
        if uploading {
            return
        }
        uploading = true
        let index = user.createdRagas.firstIndex { rag in
            return rag.name == searchResults[i].name && rag.inputs == searchResults[i].inputs
        }
        
        if index != nil {
            let curRaga = searchResults[i]
            DatabaseManager.shared.deleteRagaFromCreated(raga: curRaga) { result in
                switch(result) {
                case .success(let s) :
                    print(s)
                case .failure(let error) :
                    print(error.localizedDescription)
                    user.databaseTransactions.append(DatabaseTransaction(command: "Delete", collection: "Created", raga: curRaga))
                    UIData.updateData(user.databaseTransactions, key: "Database Transactions")
                }
                
                uploading = false
            }
            
            if user.savedRagas.contains(where: {r in return r.id == curRaga.id}) {
                DatabaseManager.shared.deleteRagaFromSaved(raga: curRaga) { _ in}
                user.savedRagas.remove(at: user.savedRagas.firstIndex(where: {r in return r.id == curRaga.id})!)
                UIData.updateData(user.createdRagas, key: "Saved Ragas")
            }
            
            user.createdRagas.remove(at: index!)

            UIData.updateData(user.createdRagas, key: "Created Ragas")
        }
        else {
            uploading = false
        }
    }
}
