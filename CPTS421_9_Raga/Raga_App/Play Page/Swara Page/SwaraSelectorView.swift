//
//  SwaraSelectorView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/3/23.
//

import SwiftUI

struct SwaraSelectorView: View {
    @EnvironmentObject var settings: InstrumentSettings
    @EnvironmentObject var db : RagaDatabase
    @EnvironmentObject var handler : TouchHandler
    @EnvironmentObject var ragaSettings: UserData
    @State var showingLoad = false // 1
    
    @State var selections = Array(repeating: 1, count: 7)
    @State var ragaCategory:String = ""
    @State var ragaName : String = ""
    
    @State var showingSaveAlert = false
    @State var showingSavedRagas = false
    @State var currentRagas = [Raga]()
    
    @State var loadLock = false
    
    var getRagas : [Raga] {
        let dbRagas = db.getAllRagas()
        let savedRagas = ragaSettings.savedRagas
        let createdRagas = ragaSettings.createdRagas
        
        var intersection = Set(dbRagas)
        intersection = intersection.union(savedRagas)
        intersection = intersection.union(createdRagas)
        
        return Array(intersection.filter {
            $0.inputs == selections
        })
    }
    
    var body: some View {
        GeometryReader { g in
            // get bounds
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            NavigationStack {
                VStack(spacing:0) {
                    HStack(spacing:0) {
                        NavigationLink {
                            ScrollView {
                                ForEach(currentRagas) { raga in
                                    HStack {
                                        TapImage(name: ragaName == raga.name ? "checkmark.circle.fill" : "checkmark.circle") {
                                            ragaSettings.selectedRaga = raga
                                            ragaName = raga.name
                                            ragaCategory = raga.category
                                        }
                                        RagaRect(raga, .blue,displayRect:false).padding(.horizontal).frame(width: w/1.25, height:h/4)
                                    }
                                }.padding()
                            }.frame(width:w)
                        } label : {
                            Image(systemName: "info.square.fill").resizable().scaledToFit().frame(width:20, height:20).foregroundStyle(.black)
                        }
                        
                        // list category, raga names
                        Text("Category:").bold().font(.system(size:15))
                        Text(ragaCategory).italic().font(.system(size:15)).padding(.trailing, 10)
                        Text("Raga:").bold().font(.system(size:15))
                        Text(ragaName).italic().font(.system(size:15)).padding(.trailing, 10)
                        
                        // create raga button
                        TapImage(name: "square.and.arrow.up.fill", padding: false) {
                            showingSaveAlert.toggle()
                        }
                        .popover(isPresented: $showingSaveAlert) {
                            SwaraSaveAlert(showingSaveAlert: $showingSaveAlert, ragaCategory: $ragaCategory, ragaName: $ragaName, selections: $selections, h: h, w: w).onChange(of: showingSaveAlert) { _ in
                                currentRagas = getRagas
                            }
                        }
                        
                        // select saved raga button
                        TapImage(name: "square.and.arrow.down", padding: false) {
                            showingSavedRagas.toggle()
                        }
                        .popover(isPresented: $showingSavedRagas) {
                            ShowSavedSwarasPopover(selections: $selections, showingSavedRagas: $showingSavedRagas, w: w, h: h)
                        }
                        Spacer()
                    }
                    
                    
                    // show swaras
                    HStack {
                        VStack {
                            SwaraButtonView(swaraName: "Ri", swaras: $selections,totalSwaras: 3, index: 1)
                            SwaraButtonView(swaraName: "Ma", swaras: $selections,totalSwaras: 2, index: 3)
                            SwaraButtonView(swaraName: "Da", swaras: $selections,totalSwaras: 3, index: 5)
                        }
                        Spacer()
                        VStack {
                            SwaraButtonView(swaraName: "Ga", swaras: $selections,totalSwaras: 3, index: 2)
                            SwaraButtonView(swaraName: "Pa", swaras: $selections,totalSwaras: 1, index: 4)
                            SwaraButtonView(swaraName: "Ni", swaras: $selections,totalSwaras: 3, index: 6)
                        }
                    }.padding(.bottom, 2)
                }
                .padding(.horizontal, 5)
            }
            .onAppear() {
                currentRagas = getRagas
                // set selections, raga name, category
                loadLock = true
                selections = settings.swaras
                if let raga = ragaSettings.selectedRaga {
                    ragaName = raga.name
                    ragaCategory = raga.category
                }
                else {
                    ragaName = db.findName(inputs: settings.swaras)
                    ragaCategory = db.findCategory(inputs: settings.swaras)
                }
            }
            .onChange(of: selections) { newVal in
                currentRagas = getRagas
                // attempt to update swaras
                if !handler.updateSwaras(currentSelections: selections, category: ragaCategory) {
                    selections = settings.swaras
                }
                
                if !loadLock {
                    ragaSettings.selectedRaga = nil
                    // update name, category
                    ragaName = db.findName(inputs: settings.swaras)
                    ragaCategory = db.findCategory(inputs: settings.swaras)
                }
                else {
                    loadLock = false
                }
            }
            .onChange(of: ragaSettings.selectedRaga) { _ in
                if let rag = ragaSettings.selectedRaga {
                    ragaName = rag.name
                    ragaCategory = rag.category
                }
            }
        }
    }
}


struct RagaPageSwaraSelector : View {
    @Binding var selections : [Int]
    var h : CGFloat
    var w : CGFloat
    
    var body: some View {
        HStack {
            // show all swaras
            VStack {
                // show swaras on left of page
                RagaPageSwaraButtonView(swaraName: "Ri", swaras: $selections,totalSwaras: 3, index: 1, w:w, h:h)
                RagaPageSwaraButtonView(swaraName: "Ma", swaras: $selections,totalSwaras: 2, index: 3, w:w, h:h)
                RagaPageSwaraButtonView(swaraName: "Da", swaras: $selections,totalSwaras: 3, index: 5, w:w, h:h)
            }
            Spacer()
            VStack {
                // show swaras on right of page
                RagaPageSwaraButtonView(swaraName: "Ga", swaras: $selections,totalSwaras: 3, index: 2, w:w, h:h)
                RagaPageSwaraButtonView(swaraName: "Pa", swaras: $selections,totalSwaras: 1, index: 4, w:w, h:h)
                RagaPageSwaraButtonView(swaraName: "Ni", swaras: $selections,totalSwaras: 3, index: 6, w:w, h:h)
            }
        }
    }
}

struct SwaraSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        SwaraSelectorView()
    }
}
