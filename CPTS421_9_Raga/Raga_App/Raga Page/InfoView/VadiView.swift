//
//  VadiView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct VadiView : View {
    @Binding var vadi : String
    @State var swaras = ["Sa", "Ri", "Ga", "Ma", "Pa", "Da", "Ni"]
    
    var body : some View {
        HStack {
            // show each vadi
            ForEach(swaras, id:\.self) { swara in
                ZStack {
                    // show vadi, blue if selected
                    BorderRect("", vadi == swara ? .blue : .white)
                    Text(swara).foregroundColor(.black).padding(.vertical)
                }.onTapGesture {
                    // change vadi
                    vadi = swara
                }
            }
        }
    }
}
