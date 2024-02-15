//
//  FullscreenButtonView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/17/23.
//

import SwiftUI

struct FullscreenButtonView: View {
    @EnvironmentObject var uiData : UIData
    var body: some View {
        TapImage(name: "arrow.down.left.and.arrow.up.right") {
            uiData.currentScene = "Fullscreen"
        }
        .topLeft()
    }
}

struct FullscreenButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FullscreenButtonView()
    }
}
