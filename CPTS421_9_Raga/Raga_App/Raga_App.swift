//
//  Raga_App.swift
//  Raga_App
//
//  Created by Aiden Walker on 2/19/23.
//

import SwiftUI
import FirebaseCore

// starts app
@main
struct SwiftUI_RagaApp: App {
    @StateObject var settings : UserData = UserData()
    init()
    {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            AllViews(settings:settings).onAppear() {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                RecordingHandler.clearOnlineRecordings()
            }.onDisappear() {
                RecordingHandler.clearOnlineRecordings()
            }
            
        }
    }
}

// show preview in canvas
//struct Preview: PreviewProvider {
//    static var previews: some View {
//        AllViews()
//    }
//}
