//
//  TopRight.swift
//  Raga_App
//
//  Created by Aiden Walker on 11/29/23.
//

import SwiftUI

struct TopRight: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            HStack {
                Spacer()
                content
            }
            Spacer()
        }
    }
}

struct TopLeft: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            HStack {
                content
                Spacer()
            }
            Spacer()
        }
    }
}

struct ImageSize : ViewModifier {
    var width : CGFloat
    var height : CGFloat
    func body(content: Content) -> some View {
        content.frame(width:width, height: height)
    }
}

extension Image {
    func imageSize(_ width: CGFloat, _ height: CGFloat) -> some View {
        modifier(ImageSize(width: width, height: height))
    }
}


extension View {
    func topLeft() -> some View {
        modifier(TopLeft())
    }
}

extension View {
    func topRight() -> some View {
        modifier(TopRight())
    }
}

extension Image {
    func defaultStyle() -> some View {
        self.resizable().scaledToFit().frame(width: 32, height: 32)
    }
}
