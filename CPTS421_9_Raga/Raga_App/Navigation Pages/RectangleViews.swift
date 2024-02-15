//
//  RectangleViews.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/17/23.
//

import SwiftUI

struct BorderRect : View {
    var title:String
    var color:Color
    var lw:CGFloat
    var rad:CGFloat
    var op:CGFloat
    var textColor:Color
    var padding:Bool
    
    init(_ title: String, _ color:Color, lw:CGFloat=3, rad:CGFloat=15,op:CGFloat=1,textColor:Color=Color.white,padding:Bool=false) {
        self.title = title
        self.color = color
        self.rad = rad
        self.lw = lw
        self.op = op
        self.textColor = textColor
        self.padding = padding
    }
    
    var body : some View {
        ZStack {
            // display bordered rectangle
            RoundedRectangle(cornerRadius: CGFloat(rad))
                .fill(color.opacity(op))
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat(rad)).stroke(.black.opacity(op), lineWidth: CGFloat(lw))
            }
            
            // display text with or without padding
            if padding {
                Text(title).foregroundColor(textColor).padding()
            }
            else {
                Text(title).foregroundColor(textColor)
            }
            
                
        }
    }
}

// displays icon in rectangle
struct IconRect : View {
    var title:String
    var color:Color
    var lw:CGFloat
    var rad:CGFloat
    var op:CGFloat
    var textColor:Color
    var image:String
    
    init(_ title: String, _ color:Color, lw:CGFloat=3, rad:CGFloat=15,op:CGFloat=1,textColor:Color=Color.white,image:String) {
        self.title = title
        self.color = color
        self.rad = rad
        self.lw = lw
        self.op = op
        self.textColor = textColor
        self.image = image
    }
    
    var body : some View {
        ZStack {
            // bordered rectangle
            RoundedRectangle(cornerRadius: CGFloat(rad))
                .fill(color.opacity(op))
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat(rad)).stroke(.black.opacity(op), lineWidth: CGFloat(lw))
            }
            
            // display image, text
            HStack(spacing: 0) {
                Image(image).resizable().scaledToFit().frame(width: 32, height: 32)
                Spacer()
                Text(title).italic().foregroundColor(textColor)
            }.padding(.vertical, 2).padding(.horizontal, 5)
        }
    }
}
