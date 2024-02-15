//
//  NewRagaView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/2/23.
//

import SwiftUI

struct MainRagaView : View {
    @EnvironmentObject var data : RagaDatabase
    @EnvironmentObject var userSettings : UserData
    
    @State var currentCategory = ""
    @State var currentScene = ""
    @State var searchText = ""
    
    @State var vadiFilter = ""
    @State var categoryFilter = ""
    @State var searchSwaras = [0,0,0,0,0,0,0]
    
    @FocusState var focused
    
    // show raga search results
    var searchResults: [Raga] {
        if searchText.isEmpty {
            return []
        } else {
            // get all ragas, created, saved
            var ragaSet = calculateFiltered()
            
            // filter by search text
            let filtered = ragaSet.filter { $0.name.lowercased().contains(searchText) }
            
            // if no sort
            if sortType == "None" {
                if filtered.isEmpty {
                    return Array(filtered)
                }
                
                // get top 4
                return Array(Array(filtered)[0..<min(4, filtered.count)])
            }
            
            // sort by input
            let sorted = filtered.sorted { r1, r2 in
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
            
            if sorted.isEmpty {
                return sorted
            }
            
            // get top 4
            return Array(Array(sorted)[0..<min(4, sorted.count)])
        }
    }
    
    func calculateFiltered() -> [Raga]{
        var ragaSet = Set(data.getAllRagas())
        ragaSet.formUnion(userSettings.createdRagas)
        ragaSet.formUnion(userSettings.savedRagas)
        
        if vadiFilter == "" && categoryFilter == "" && searchSwaras == [0,0,0,0,0,0,0] {
            return Array(ragaSet)
        }
        
        if sortType == "None" {
            return Array(ragaSet)
        }
        else if sortType == "Category" {
            return ragaSet.filter({$0.category == categoryFilter})
        }
        else if sortType == "Vadi" {
            return ragaSet.filter({$0.vadi == vadiFilter})
        }
        
        return ragaSet.filter({$0.inputs == searchSwaras})
    }
    
    var h = UIScreen.main.bounds.height
    var w = UIScreen.main.bounds.width
    
    @State var sortType = "None"
    @State var filterType = "None"
    
    var sortItems = ["Name", "Category","None"]
    var swaras = ["Ri", "Ga", "Ma", "Pa", "Da", "Ni"]
    
    var body : some View {
        GeometryReader { g in
            
            ScrollView {
                // show title
                Text("Ragas").font(.system(size:w/7))
                
                HStack {
                    ZStack {
                        BorderRect("", .white)
                        
                        // input to search ragas
                        TextField("Search Ragas", text:$searchText).multilineTextAlignment(.center).autocorrectionDisabled(true).textInputAutocapitalization(.never).focused($focused).onChange(of: focused) { edit in
                            if !edit {
                                searchText = ""
                            }
                        }
                    }.frame(height:h/14).padding(.horizontal).padding(.top)
                    
                    // menu to pick sort
                    Menu {
                        // picker to pick sort type
                        Picker("Sort By", selection: $sortType) {
                            ForEach(sortItems, id: \.self) {
                                Text(String($0))
                            }
                        }
                    } label : {
                        Image(systemName: "line.3.horizontal.decrease.circle").defaultStyle().padding(.vertical).padding(.trailing).foregroundColor(.black)
                    }
                    
                    // menu to pick sort
//                    Menu {
//                        Menu("Category") {
//                            // picker to pick sort type
//                            Picker("Category", selection: $categoryFilter) {
//                                ForEach(data.getCategories(), id: \.self) {
//                                    Text(String($0))
//                                }
//                            }
//                        }
//                        
//                        Menu("Swaras") {
//                            RagaPageSwaraSelector(selections: $searchSwaras, h: h, w: w)
//                        }
//                        
//                        Menu("Vadi") {
//                            // picker to pick sort type
//                            Picker("Vadi", selection: $vadiFilter) {
//                                ForEach(swaras, id: \.self) {
//                                    Text(String($0))
//                                }
//                            }
//                        }
//                    } label : {
//                        Image(systemName: "slider.vertical.3").defaultStyle().padding(.vertical).padding(.horizontal, 3).foregroundColor(.black)
//                    }
                }
                
                VStack(spacing:10) {
                    // show raga categories
                    RagaCategoryView(title: "Raga Categories", items: data.getCategories(), h: h).padding()
                    
                    // show all ragas
                    RagaListView(title: "Premade Ragas", items: .constant(data.getAllRagas()), h: h).padding()
                    
                    RagaListView(title: "Created Ragas", items: $userSettings.createdRagas, created:true,h: h).padding()
                    
                    RagaListView(title: "Saved Ragas", items: $userSettings.savedRagas, h: h).padding()
                }.overlay {
                    VStack {
                        // show search results
                        VStack(spacing:0) {
                            ForEach(searchResults) { result in
                                // show raga result
                                RagaRect(result, .gray).padding(.vertical, 3).padding(.horizontal).frame(width:w/1.2, height: h/10)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

