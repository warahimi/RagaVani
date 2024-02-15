//
//  NavigationView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/4/23.
//

import SwiftUI

struct NavigationBarView: View {
    @EnvironmentObject var data: UIData
    var body: some View {
        GeometryReader { g in
            // get bounds
            let h = g.frame(in:.local).height
            let w = g.frame(in:.local).width
            
            ZStack {
                HStack {
                    // play page
                    NavButton(text: "Play", img: "music",size:w/35,frm:w/7,frm2:w/7).frame(height: h)
                    
                    // raga page
                    ZStack {
                        BorderRect("", "Raga" == data.currentScene ? .blue.opacity(0.3) : .white)
                        VStack(spacing:1) {
                            // show icon, text
                            Text("SA").font(.system(size:w/10)).frame(width:w/7,height: w/7)
                            Text("Raga").font(.system(size:w/35))
                            Spacer()
                        }.padding(.top, 5)
                    }.onTapGesture {
                        // set current page
                        data.currentScene = "Raga"
                    }
                    
                    // sound page
                    NavButton(text:"Instrument", img:"Guitar",size:w/35,frm:w/7).frame(height: h)
                    
                    // recording page
                    NavButton(text: "Recordings", img: "record",size:w/35,frm:w/7).frame(height: h)
                    
                    // community page
                    NavButton(text: "Community", img: "globe",size:w/35,frm:w/7).frame(height: h)
                }
            }
        }
        
    }
}

struct NavButton : View {
    @EnvironmentObject var data: UIData
    var text:String
    var img:String
    var frm:CGFloat
    var frm2:CGFloat
    var size: CGFloat
    
    init(text: String, img: String, size:CGFloat,frm:CGFloat=0,frm2:CGFloat=0) {
        self.text = text
        self.img = img
        self.size = size
        self.frm = frm
        self.frm2 = frm2
    }
    
    var body: some View {
        ZStack {
            // color if selected
            BorderRect("", text == data.currentScene ? .blue.opacity(0.3) : .white)
            
            VStack(spacing:1) {
                // show image
                if frm == 0 {
                    Image(img)
                }
                else {
                    Image(img).resizable().frame(width:frm, height:frm2 == 0 ? frm : frm2)
                }
                
                // show text
                Text(text).font(.system(size:size))
                
                Spacer()
            }.padding(.top, 5)
            
        }.onTapGesture {
            // set current page
            data.currentScene = text
        }
    }
}

struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView()
    }
}
