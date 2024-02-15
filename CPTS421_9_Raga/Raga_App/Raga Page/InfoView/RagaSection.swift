//
//  RagaSection.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct RagaSection : View {
    var text : String
    @Binding var input : String
    
    var body : some View {
        ZStack {
            BorderRect("", .blue)
            HStack {
                // show title, text
                Text(text).bold().padding(.vertical)
                
                // change field
                TextField("", text: $input).italic().border(.black).frame(width: 100).padding(.vertical)
            }.onChange(of: input) { newVal in
                // max input length
                if input.count > 16 {
                    input = String(input.prefix(16))
                }
            }
        }
        
    }
}
