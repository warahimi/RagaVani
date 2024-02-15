//
//  LoadingView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/25/23.
//

import SwiftUI

struct LoadingView: View {
    @State private var isRotating = 0.0
    
    var body: some View {
        GeometryReader { g in
            // get size
            let w = g.size.width
            
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Spacer()
                    // loading text
                    Text("Loading...").font(.system(size:60))
                    
                    // rotation loading icon
                    Image("loading").resizable().scaledToFit().frame(width: w/3, height: w/3)
                        .rotationEffect(.degrees(isRotating))
                        .onAppear {
                            withAnimation(.linear(duration: 1)
                                .speed(0.1).repeatForever(autoreverses: false)) {
                                    isRotating = 360.0
                                }
                        }
                    Spacer()
                }
                Spacer()
            }
        }
        
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
