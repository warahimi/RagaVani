//
//  TestView.swift
//  Raga_App
//
//  Created by Aiden Walker on 9/17/23.
//
import SwiftUI
import UIKit
import Keyboard

struct TapView : View {
    @EnvironmentObject var touchHandler : TouchHandler
    @EnvironmentObject var audioEngine : InstrumentConductor
    @Binding var reset : Bool
    
    var body : some View {
        if touchHandler.uiSettings.UI == "Guitar" {
            GuitarView(reset: $reset)
        }
        else if touchHandler.uiSettings.UI == "Keyboard" {
            PianoView(reset: $reset)
        }
        else {
            PianoView(reset: $reset)
        }
    }
}

struct GuitarView : View {
    @EnvironmentObject var touchHandler : TouchHandler
    @EnvironmentObject var audioEngine : InstrumentConductor
    @EnvironmentObject var settings : UserData
    @Binding var reset : Bool
    
    var body : some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            ZStack {
                
                // puts a glow effect on the touch locations
                ForEach(0..<touchHandler.touches.count, id: \.self) { index in
                    let location = touchHandler.points[index]
                    Circle().fill(Color.white)
                        .frame(width: 50, height: 50)
                        .shadow(color: .red, radius: 10)
                        .position(location)
                        .rotationEffect(.degrees(360))
                }
                
                let bnds = touchHandler.yHeights
                
                // go through each row, display string
                ForEach(0..<bnds.count, id: \.self) { yIndex in
                    // check if touching on this y
                    if (!touchHandler.containsY(y: yIndex)) {
                        // not touching, draw straight line
                        
                        // draw line based on y height
                        let control1 = CGPoint(x:-10,y:bnds[yIndex])
                        let control2 = CGPoint(x:-10,y:bnds[yIndex])
                        Path { path in
                            path.move(to: CGPoint(x:-10, y:bnds[yIndex]))
                            path.addCurve(to: CGPoint(x: Int(width)+10,y:bnds[yIndex]), control1: control1, control2: control2)
                            //path.closeSubpath()
                        }.stroke(settings.uiSettings.stringColor,lineWidth: 10)
                    }
                    else {
                        // touching key, draw curved line
                        
                        // get max distance from line
                        let touchLocation = touchHandler.getMaxBend(y: yIndex)
                        let control1 = CGPoint(x:touchLocation.x*0.75, y:touchLocation.y)
                        let control2 = CGPoint(x:touchLocation.x*1.25,y:touchLocation.y)
                        ZStack {
                            
                            Path { path in
                                path.move(to: CGPoint(x:-10, y:bnds[yIndex]))
                                path.addCurve(to: CGPoint(x: Int(width)+10,y:bnds[yIndex]), control1: control1, control2: control2)
                                //path.closeSubpath()
                            }.stroke(settings.uiSettings.stringColor,lineWidth: 10)
                        }
                        
                    }
                }
                ForEach(0..<touchHandler.bounds.count, id: \.self) { index in
                    let pos = touchHandler.getPos(index:index)
                    let activated = touchHandler.selectedKeys.contains(index)
                    ZStack {
                        KeyboardKey(pitch: Pitch(intValue: 5), isActivated: activated, text:"", whiteKeyColor: settings.uiSettings.keyColor, blackKeyColor: settings.uiSettings.keyColor)
                            .frame(width: CGFloat(touchHandler.xSize), height: CGFloat(touchHandler.uiSettings.ySize))
                            .position(pos)
                        Text(touchHandler.getName(index))
                            .foregroundColor(settings.uiSettings.keyTextColor)
                            .position(pos)
                            .accessibilityLabel("Piano Button \(index)")
                    }
                }
                
                let frame = geometry.frame(in: CoordinateSpace.local)
                TouchView(reset:$reset, frame: frame)
                
            }
            .onAppear() {
                if touchHandler.oldFrame == nil {
                    self.touchHandler.setUp(frame: geometry.frame(in: CoordinateSpace.local))
                }
            }
        }
        
    }
}

struct PianoView : View {
    @EnvironmentObject var touchHandler : TouchHandler
    @EnvironmentObject var audioEngine : InstrumentConductor
    @EnvironmentObject var settings : UserData
    @Binding var reset : Bool
    
    var body : some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            
            ZStack {
                ForEach(0..<touchHandler.bounds.count, id: \.self) { index in
                    let pos = touchHandler.getPos(index:index)
                    let activated = touchHandler.selectedKeys.contains(index)
                    
                    ZStack {
                        KeyboardKey(pitch: Pitch(intValue: 5), isActivated: activated, text:"", whiteKeyColor: settings.uiSettings.keyColor, blackKeyColor:  settings.uiSettings.keyColor)
                            .frame(width: CGFloat(touchHandler.xSize), height: CGFloat(touchHandler.ySize))
                            .position(pos)
                        Text(touchHandler.getName(index))
                            .foregroundColor( settings.uiSettings.keyTextColor)
                            .position(pos)
                        
                        if touchHandler.uiSettings.UI == "Keyboard" {
                            if activated {
                                let offset = touchHandler.getUpperMarkerLocation(index)
                                if offset > pos.y - CGFloat(touchHandler.ySize / 2) {
                                    let newPos = CGPoint(x:pos.x, y:offset)
                                    ZStack {
                                        Circle().fill(.white).frame(width:min(CGFloat(touchHandler.xSize), 20), height:min(CGFloat(touchHandler.xSize), 20))
                                        Text(touchHandler.getName(index == touchHandler.xCount - 1 ? touchHandler.getUpperOffset() : index + 1))
                                            .font(.system(size: 13))
                                            .foregroundColor(.black)
                                    }.position(newPos)
                                }
                                
                                let lowerOffset = touchHandler.getLowerMarkerLocation(index)
                                if lowerOffset < pos.y + CGFloat(touchHandler.ySize / 2) {
                                    let newPos = CGPoint(x:pos.x, y:lowerOffset)
                                    ZStack {
                                        Circle().fill(.white).frame(width:min(CGFloat(touchHandler.xSize), 20), height:min(CGFloat(touchHandler.xSize), 20))
                                        Text(touchHandler.getName(index == 0 ? touchHandler.getLowerOffset() : index - 1))
                                            .font(.system(size: 13))
                                            .foregroundColor(.black)
                                    }.position(newPos)
                                    
                                }
                                
                            }
                        }
                        
                    }
                }
                
                let frame = geometry.frame(in: CoordinateSpace.local)
                TouchView(reset:$reset, frame: frame)
                
            }
            .onAppear() {
                if touchHandler.oldFrame == nil {
                    self.touchHandler.setUp(frame: geometry.frame(in: CoordinateSpace.local))
                }
            }
        }
        
    }
}
