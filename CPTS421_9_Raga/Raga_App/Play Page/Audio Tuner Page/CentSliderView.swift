//
//  CentSliderView.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct CentSliderView: View {
    var title:String
    @State var input:String = ""
    @State var showingAlert = false
    var min:Double
    var max:Double
    @Binding var cur:Float
    var size:CGFloat
    var intRnd = false
    
    var body: some View {
        VStack(spacing:0) {
            Spacer()
            HStack {
                Spacer()
                Text(title).font(.system(size:size/7))
                Spacer()
                Spacer()
                Spacer()
            }
            
            HStack {
                ZStack {
                    BorderRect("", .blue.opacity(0.2), rad:30)
                    Slider(
                        value: $cur,
                        in: Float(min/100)...Float(max/100),
                        step: 0.01
                    ) {
                    } minimumValueLabel: {
                        Text(String(Int(min)))
                    } maximumValueLabel: {
                        Text(String(Int(max)))
                    }.onChange(of: cur) { newVal in
                        UIData.updateData(cur, key: title)
                    }
                    .padding()
                    
                }.frame(width:size*1.25).padding(.leading, 5)
                Spacer()
                ZStack {
                    BorderRect("", .blue.opacity(0.2), rad:30)
                        .onTapGesture {
                            showingAlert = true
                        }
                        .alert("Enter " + title.lowercased(), isPresented: $showingAlert) {
                            TextField("...", text: $input)
                            Button("OK", action: submit)
                        }
                    if intRnd {
                        Text(String(Int(cur))).underline(true).bold(true)
                            .allowsHitTesting(false)
                    }
                    else {
                        Text(String(round(cur*100))).underline(true).bold(true)
                            .allowsHitTesting(false)
                    }
                    
                    
                }.padding(.trailing)
                
                
            }
            
            Spacer()
        }
    }
    
    func submit() {
        if Int(input) != nil {
            cur = Float(input)!
        }
        showingAlert = false
        input = ""
    }
}
