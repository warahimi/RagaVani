//
//  RagaCategoryView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct RagaCategoryView : View {
    @State var title:String
    @State var items:[String]
    @EnvironmentObject var ragaDB : RagaDatabase
    
    var viewAll = true
    var h:CGFloat
    
    // display category results
    var searchItems : [String] {
        // show all if not showing preview
        if !viewAll {
            return items
        }
        
        // show top 3 otherwise
        let count = min(items.count, 3)
        
        return Array(items[0..<count])
    }
    
    var body : some View {
        ZStack {
            BorderRect("", .gray)
            VStack(spacing:0) {
                // show title
                Text(title).padding()
                
                VStack(spacing:5) {
                    // show all categories
                    ForEach(0..<searchItems.count, id:\.self) { i in
                        // display links to show category ragas
                        NavigationLink {
                            ScrollView {
                                RagaListView(title: searchItems[i] + " Ragas", items: .constant(ragaDB.categories[searchItems[i]]!), viewAll: false, h: h)
                            }
                            
                        } label: {
                            BorderRect(searchItems[i], .blue).frame(height:h/10).padding(.horizontal)
                        }
                    }
                    
                    // link to show all categories
                    if viewAll {
                        NavigationLink {
                            ScrollView {
                                RagaCategoryView(title: "Raga Categories", items: items, viewAll: false,h: h).padding()
                            }
                            
                        } label : {
                            BorderRect("View all " + title, .blue)
                                .frame(height:h/10).padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}
