//
//  SplashScreenView.swift
//  Raga_App
//
//  Created by Wahidullah Rahimi on 3/6/23.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State var text1 : String
    @State var text2 : String?
    @State private var isRotating = 0.0
    
    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            
            HStack {
                VStack{
                    // show upbeat labs logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                    
                    // show loading icon
                    Image("loading").resizable().scaledToFit().frame(width: w/2, height: w/2)
                        .rotationEffect(.degrees(isRotating))
                        .onAppear {
                            withAnimation(.linear(duration: 1)
                                .speed(0.1).repeatForever(autoreverses: false)) {
                                    isRotating = 360.0
                            }
                        }
                    
                    // show dispayed text
                    ZStack{
                        VStack{
                            Text(text1)
                            if let text = text2 {
                                Text(text)
                            }
                            
                        }
                        .foregroundColor(Color(hue: 1.0, saturation: 0.946, brightness: 0.629))
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding()
                        .background(Color(hue: 0.612, saturation: 0.357, brightness: 0.877).opacity(0.10))
                        .cornerRadius(10)
                    }
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear(){
                    withAnimation(.easeIn(duration: 1.2)){
                        self.size = 0.9
                        self.opacity = 1.0

                    }
                }
            }
        }
        
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(text1: "Welcome")
    }
}
