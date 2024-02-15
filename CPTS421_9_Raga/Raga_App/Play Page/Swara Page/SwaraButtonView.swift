//
//  SwaraButtonView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/3/23.
//

import SwiftUI

struct SwaraButtonView: View {
    var swaraName:String
    @Binding var swaras: [Int]
    var totalSwaras:Int
    var index:Int
    
    var body: some View {
        GeometryReader { g in
            let w = g.frame(in:.local).width
            ZStack(alignment:.center) {
                BorderRect("",Color.blue.opacity(0.8))
                
                VStack(spacing: 0) {
                    // show full swara name
                    Text(swaraName)
                        .font(.system(size:w/6))
                    
                    ZStack {
                        BorderRect("",Color.gray,rad:30)
                        
                        // show each sub swara
                        HStack(spacing:0) {
                            ForEach(0..<totalSwaras, id:\.self) { i in
                                let color = i+1 == swaras[index] ? 1.0 : 0
                                
                                // show sub swara
                                BorderRect("",Color.blue.opacity(0.3),rad:30,op:color)
                                    .frame(width:w/CGFloat(totalSwaras))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        swaras[index] = i+1 == swaras[index] ? 0 : i + 1
                                    }
                                    .accessibilityLabel("\(swaraName) \(i+1) Button")
                            }
                                
                        }
                        
                        // show subswara text
                        HStack(spacing: 0) {
                            ForEach(0..<totalSwaras, id:\.self) {i in
                                Spacer()
                                Text(String(swaraName[0]) + String(i+1))
                                    .font(.system(size:w/7))
                                    .allowsHitTesting(false)
                                
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                }
                
            }
        }
        
    }
}

struct RagaPageSwaraButtonView: View {
    var swaraName:String
    @Binding var swaras: [Int]
    var totalSwaras:Int
    var index:Int
    var w : CGFloat
    var h : CGFloat
    
    var body: some View {
        ZStack(alignment:.center) {
            BorderRect("",Color.blue.opacity(0.8))
            
            VStack(spacing: 0) {
                // display name
                Text(swaraName)
                    .font(.system(size:w/6))
                ZStack {
                    BorderRect("",Color.gray,rad:30)
                    HStack(spacing:0) {
                        // show each subswara
                        ForEach(0..<totalSwaras, id:\.self) {i in
                            let color = i+1 == swaras[index] ? 1.0 : 0
                            
                            // show subswara
                            BorderRect("",Color.blue.opacity(0.3),rad:30,op:color)
                                .frame(width:w/CGFloat(totalSwaras))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // update selection
                                    swaras[index] = i+1 == swaras[index] ? 0 : i + 1
                                }
                                .accessibilityLabel("\(swaraName) \(i+1) Button")
                        }
                            
                    }
                    
                    // show swara text
                    HStack(spacing: 0) {
                        ForEach(0..<totalSwaras, id:\.self) {i in
                            Spacer()
                            Text(String(swaraName[0]) + String(i+1))
                                .font(.system(size:w/7))
                                .allowsHitTesting(false)
                            
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            
        }
        
    }
}

//struct SwaraButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwaraButtonView2(swaraName: "Ri", totalSwaras: 3, index: 0,value:0)
//    }
//}
