//
//  MultitouchView.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/17/23.
//

import SwiftUI
import UIKit

struct TouchView : UIViewRepresentable {
    @EnvironmentObject var handler : TouchHandler
    @EnvironmentObject var engine : InstrumentConductor
    @Binding var reset : Bool
    var frame : CGRect
    
    // convert uikit to swiftui
    func makeUIView(context: Context) -> TouchableView {
        TouchableView(frame: frame, handler: handler, engine:engine,reset:$reset)
    }
    
    func updateUIView(_ view: TouchableView, context: Context) {
    }
}


class TouchableView: UIView {
    @Published var handler : TouchHandler
    @Published var engine: InstrumentConductor
    @Binding var reset : Bool
    var resetY = true
    
    required init(frame:CGRect, handler:TouchHandler, engine: InstrumentConductor, reset:Binding<Bool>) {
        _reset = reset
        self.handler = handler
        self.engine = engine
        super.init(frame:frame)
        isMultipleTouchEnabled = true
    }
    
    // default init - not used
    override init(frame: CGRect) {
        handler = TouchHandler(uiSettings: UISettings(), keySettings: InstrumentSettings())
        engine = InstrumentConductor(settings: AudioSettings())
        _reset = .constant(false)
        super.init(frame: frame)
        isMultipleTouchEnabled = true
    }
    
    // default init - not used
    required init?(coder aDecoder: NSCoder) {
        engine = InstrumentConductor(settings: AudioSettings())
        handler = TouchHandler(uiSettings: UISettings(), keySettings: InstrumentSettings())
        _reset = .constant(false)
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
    }
    
    // new touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // reset overlays
        reset = true
        
        touches.forEach {
            // if touch in bounds of key
            if (handler.inBounds(location: $0.location(in: self))) {
                // get key, check can play
                let selectedIndex = handler.touchIndex(location: $0.location(in: self))
                if !handler.canPlay(selectedIndex) {
                    return
                }
                
                // check not -1
                if (selectedIndex != -1) {
                    if (!handler.selectedKeys.contains(selectedIndex)) {
                        // get pitch, turn key on
                        let pitch = handler.getPitch(selectedIndex)
                        engine.on(pitch: pitch, index: handler.selectedKeys.count)
                        engine.bend(offset: 0, index:handler.selectedKeys.count)
                        handler.selectedKeys.append(selectedIndex)
                        handler.updateDrag(idx: handler.selectedKeys.count-1)
                    }
                }
                
                // add key, location
                self.handler.touches.append($0)
                self.handler.points.append($0.location(in: self))
                self.handler.initialY.append($0.location(in: self).y)
                self.handler.initialX.append($0.location(in: self).x)
            }
        }
    }
    
    // touch moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            if let index = self.handler.touches.firstIndex(of: $0) {
                // get update touch
                self.handler.points[index] = $0.location(in: self)
                
                // get selected key of previous and new location
                let selectedIndex = self.handler.selectedKeys[index]
                let newSelectedIndex = handler.touchIndex(location: handler.points[index])
                
                // checks if new location
                if (newSelectedIndex != -1 && selectedIndex != newSelectedIndex) {
                    if !handler.canPlay(newSelectedIndex) {
                        let offset = handler.getPitchBend(index)
                        engine.bend(offset: offset, index:index)
                        return
                    }
                    
                    // get original pitch
                    let pitch1 = handler.getPitch(selectedIndex)
                    self.handler.selectedKeys[index] = newSelectedIndex
                    
                    // get new pitch
                    let pitch2 = handler.getPitch(newSelectedIndex)
                    
                    // turn off old, play new putcg
                    engine.off(pitch: pitch1, index: index)
                    engine.on(pitch: pitch2, index: index)
                    
                    // if want to reset Y when changing keys in pitch bending
                    if (self.resetY) {
                        self.handler.initialY[index] = $0.location(in: self).y
                    }
                    
                    // new x bend start location
                    self.handler.initialX[index] = $0.location(in: self).x
                }
                else if (newSelectedIndex == -1 || selectedIndex == newSelectedIndex) {
                    // only pitch bend
                    let offset = handler.getPitchBend(index)
                    print(handler.getPitch(selectedIndex))
                    print(offset)
                    engine.bend(offset: offset, index:index)
                }
            }
        
        }
    }
    
    // touch ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            if let index = self.handler.touches.firstIndex(of: $0) {
                // get key index, pitch
                let selectedIndex = handler.selectedKeys[index]
                let pitch = handler.getPitch(selectedIndex)
                
                // turn off
                engine.off(pitch: pitch, index: index)
                
                // remove touch
                self.handler.touches.remove(at: index)
                self.handler.points.remove(at: index)
                self.handler.initialY.remove(at:index)
                self.handler.initialX.remove(at: index)
                self.handler.selectedKeys.remove(at: index)
            }
        }
    }
}

