//
//  NormalRagaBlock.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct NormalRagaBlock : View {
    var text : String
    var input : String
    
    var body : some View {
        ZStack {
            BorderRect("", .blue)
            VStack {
                // show title, text
                Text(text).bold().padding(.horizontal)
                Text(input).italic().padding(.horizontal)
            }.padding()
        }
    }
}

