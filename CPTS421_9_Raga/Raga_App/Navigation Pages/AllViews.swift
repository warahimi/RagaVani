//
//  AllViews.swift
//  Raga_App
//
//  Created by Aiden Walker on 4/5/23.
//

import SwiftUI

// handles every view - determined by currentScene string
struct AllViews : View {
    @StateObject var data : UIData = UIData()
    @StateObject var settings : UserData
    @StateObject var engine : InstrumentConductor
    @StateObject var ragaStorage = RagaDatabase()
    
    @State var version : Version?
    
    @State var versionLoaded = false
    @State var loaded = 0
    @State var recLoaded = 0
    
    @State var user : DatabaseUser?
    
    @State var accClicked = false
    @State var showSignInView = false
    
    init(settings:UserData) {
        _settings = StateObject(wrappedValue: settings)
        
        _engine = StateObject(wrappedValue: InstrumentConductor(settings: settings.audioSettings))
    }

    var body : some View {
        GeometryReader { g in
            // get bounds
            let h = g.frame(in: .local).height
            let w = g.frame(in: .local).width
            
            ZStack {
                // check if loaded
                if loaded > 6 {
                    if self.isPortrait(w: w, h: h) {
                        
                        VStack(spacing:0) {
                            if data.currentScene == "Play" {
                                // play page
                                PlayPageView(settings: settings,accClicked: $accClicked)
                            }
                            else if data.currentScene == "Raga" {
                                // raga page
                                NavigationStack {
                                    MainRagaView() 
                                }
                                .environmentObject(settings.instrumentSettings)
                            }
                            else if data.currentScene == "Instrument" {
                                // sound page
                                NavigationStack {
                                    InstrumentBrowser()
                                }
                                .environmentObject(engine)
                            }
                            else if data.currentScene == "Recordings" {
                                // recording page
                                NavigationStack {
                                    RecordingPageView()
                                }
                            }
                            else if data.currentScene == "Settings" {
                                // settings page
                                SettingsView(accClicked:$accClicked)
                                    
                            }
                            else if data.currentScene == "Account Settings" {
                                // account settings page
                                if user != nil {
                                    // makes sure user is signed in
                                    TopProfileView(user:$user)
                                }
                            }
                            else if data.currentScene == "Sign In" {
                                // sign up view
                                NavigationStack {
                                    SignInEmailView(showSignInView: $showSignInView, user:$user)
                                }
                                
                                //SignUpEmailView(showSignInView:.constant(false))
                            }
                            else if data.currentScene == "Community" {
                                // community view
                                CommunityTopView()
                                    .environmentObject(settings.instrumentSettings)
                            }
                            
                            Spacer()
                            
                            // show nav bar at bottom
                            NavigationBarView().frame(maxHeight:h/10).padding(.horizontal).padding(.bottom).padding(.top, 3)
                            
                        }
                        
                        // show user icon in top right
                        UserIconView(accClicked:$accClicked, w: w, h: h,user:$user)
                        
                        // show popups
                        VStack {
                            LoginAlertView(popupController: $data.showPopup, popupText: data.popupText).frame(width: w/1.5, height:h/5)
                            Spacer()
                        }
                        
                        
                    }
                    else if data.currentScene == "Fullscreen" {
                        // show fullscreen, in landscape
                        FullScreenView(settings: settings)
                    }
                }
                else {
                    // not loaded yet, show splash screen
                    SplashScreenView(text1: "Welcome to",text2: "Raga Vani")
                }
            }
            .onChange(of: g.size) { _ in
                // rotate screen attemp
                if g.size.width > g.size.height && data.currentScene != "Fullscreen" {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                }
                
            }
            .onChange(of: recLoaded) { _ in
                // once recordings load, grab files
                Task {
                    if recLoaded == 2 {
                        await settings.setUpFiles()
                        loaded += 1
                    }
                }
                
            }
            .onChange(of: versionLoaded) { _ in
                loadRagaDB()
            }
            .onAppear() {
                Task {
                    // load user data
                    loadData()
                    
                    // get user
                    user = await UserManager.shared.getAuthUser()
                    
                    // get db raga version
                    await DatabaseManager.shared.getVersion(collectionName:"ragas") { version in
                        self.version = version
                        self.versionLoaded = true
                        loaded += 1
                    }
                }
            }
            .environmentObject(settings)
            .environmentObject(data)
            .environmentObject(ragaStorage)
        }
    }
    
    func loadRagaDB() {
        // check if version didnt load
        if version == nil {
            ragaStorage.setUpDB(fetchedRagas: nil)
            loaded += 1
            return
        }
        
        // get current version
        let savedVersion = UIData.initalizeData("", "DB Version") as! String
        
        // check if versions match
        // update this later, userdefaults not enough for storing all these ragas
        if let version = version, version.version == savedVersion {
            ragaStorage.setUpDB(fetchedRagas: nil)
            loaded += 1
            return
        }
        
        // get db ragas
        DatabaseManager.shared.fetchAllRagas { fetchedRagas in
            // save new ragas
            ragaStorage.setUpDB(fetchedRagas: fetchedRagas)
            loaded += 1
            
            // save local db version
            UIData.updateData(version?.version, key: "DB Version")
        }
    }
    
    // get user data
    func loadData() {
        // get created ragas
        DatabaseManager.shared.getCreatedRagas { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ragas) :
                    // set created ragas
                    settings.createdRagas = ragas
                    UIData.updateData(settings.createdRagas, key: "Created Ragas")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            loaded += 1
        }
        
        // get saved ragas
        DatabaseManager.shared.getSavedRagas { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ragas) :
                    // set saved ragas
                    settings.savedRagas = ragas
                    UIData.updateData(settings.savedRagas, key: "Saved Ragas")
                case .failure(let error):
                    print("saved" + error.localizedDescription)
                }
            }
            
            loaded += 1
        }

        // get recordings
        DatabaseManager.shared.getRecordings { r, s in
            DispatchQueue.main.async {
                if s {
                    // save recordings
                    settings.savedRecordings = r
                    UIData.updateData(settings.savedRecordings, key: "Favorite Recordings")
                }
                else {
                    print("ERROR")
                }
                loaded += 1
                recLoaded += 1
            }
        }
        
        // get favorite recordings
        DatabaseManager.shared.getFavoriteRecordings() { success, recs in
            DispatchQueue.main.async {
                if success {
                    // save favorite recordings
                    settings.favoriteRecordings = recs
                    UIData.updateData(settings.favoriteRecordings, key: "Favorite Recordings")
                }
                
                loaded += 1
                recLoaded += 1
            }
        }
    }
    
    // check if in portrait mode
    func isPortrait(w:CGFloat, h:CGFloat) -> Bool {
        return h > w && data.currentScene != "Fullscreen"
    }
}
