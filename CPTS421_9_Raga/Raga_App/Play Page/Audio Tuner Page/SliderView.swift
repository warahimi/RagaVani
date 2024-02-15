//
//  SliderView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/3/23.
//

import SwiftUI

struct SliderView: View {
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
            
            // slider title
            HStack {
                Spacer()
                Text(title).font(.system(size:size/7))
                Spacer()
                Spacer()
                Spacer()
            }
            
            // show slider + text
            HStack {
                ZStack {
                    BorderRect("", .blue.opacity(0.2), rad:30)
                    
                    // slider
                    Slider(
                        value: $cur,
                        in: Float(min)...Float(max),
                        step: 0.1
                    ) {
                    } minimumValueLabel: {
                        Text(String(Int(min)))
                    } maximumValueLabel: {
                        Text(String(Int(max)))
                    }.onChange(of: cur) { newVal in
                        // save updated value
                        UIData.updateData(cur, key: title)
                    }
                    .padding()
                    
                }.frame(width:size*1.25).padding(.leading, 5)
                
                Spacer()
                
                // show slider value
                ZStack {
                    BorderRect("", .blue.opacity(0.2), rad:30)
                        .onTapGesture {
                            showingAlert = true
                        }
                        .alert("Enter " + title.lowercased(), isPresented: $showingAlert) {
                            // get user input for slider value
                            TextField("...", text: $input)
                            Button("OK", action: submit)
                        }
                    
                    // show text rounded to int or 2 decimals
                    if intRnd {
                        Text(String(Int(cur))).underline(true).bold(true)
                            .allowsHitTesting(false)
                    }
                    else {
                        Text(String(round(cur*100)/100)).underline(true).bold(true)
                            .allowsHitTesting(false)
                    }
                }.padding(.trailing)
            }
            
            Spacer()
        }
    }
    
    // set slider value
    func submit() {
        // checks input is valid
        if Int(input) != nil {
            cur = Float(input)!
        }
        
        showingAlert = false
        input = ""
    }
}
