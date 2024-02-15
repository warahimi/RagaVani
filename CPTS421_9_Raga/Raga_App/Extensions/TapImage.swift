//
//  TapImage.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct TapImage : View {
    var name : String
    var height: CGFloat = 32
    var width : CGFloat = 32
    var padding : Bool = true
    var tapped : () -> Void
    
    var body : some View {
        if padding {
            Image(systemName: name).defaultStyle().padding().onTapGesture {
                self.tapped()
            }
        }
        else {
            Image(systemName: name).defaultStyle().onTapGesture {
                self.tapped()
            }
        }
        
    }
}

struct RegularImageStyle : View {
    var name : String
    var height: CGFloat = 32
    var width : CGFloat = 32
    
    var body : some View {
        Image(systemName: name).resizable().scaledToFit().frame(width: 32, height: 32).padding()
    }
}

#Preview {
    TapImage(name:"xmark") {}
}
