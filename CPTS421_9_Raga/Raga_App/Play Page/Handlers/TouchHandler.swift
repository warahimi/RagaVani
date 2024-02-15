//
//  TouchHandler.swift
//  Raga_App
//
//  Created by Aiden Walker on 10/10/23.
//

import Foundation
import UIKit
import Combine

class TouchHandler : ObservableObject {
    @Published var points = [CGPoint]()
    @Published var touches = [UITouch]()
    @Published var initialY = [CGFloat]()
    @Published var initialX = [CGFloat]()
    
    @Published var names = [Int]()
    @Published var pitches = [Int]()
    @Published var offsets = [Int]()
    
    @Published var upperLimits = [Float]()
    @Published var lowerLimits = [Float]()
    @Published var selectedKeys = [Int]()
    
    @Published var bounds = [Int]()
    @Published var yBounds = [Int]()
    
    @Published var xCount : Int = 0
    @Published var yCount : Int = 0
    
    @Published var xPadding: Int = 0
    @Published var yPadding: Int = 0
    
    @Published var yHeights = [Int]()
    
    @Published var oldFrame:CGRect? = nil
    
    @Published var keyboardData : KeyboardData
    @Published var uiSettings : UISettings
    
    @Published var fullscreen = false
    
    @Published var xSize = 0
    @Published var ySize = 0
    
    init(uiSettings:UISettings, keySettings:InstrumentSettings) {
        self.uiSettings = uiSettings
        self.keyboardData = KeyboardData(settings: keySettings, uiSetting: uiSettings)
        xCount = keyboardData.totalSwaras
        yCount = uiSettings.UI == "Keyboard" ? 1 : uiSettings.padRows
    }
    
    // update swaras, set up pads
    func updateSwaras(currentSelections:[Int], category:String) -> Bool {
        let rules = RagaRules(name: category)
        
        // tests input on current raga rules
        if rules.testAll(inputs: currentSelections) != nil {
            // save swaras
            keyboardData.instrumentSettings.swaras = currentSelections
            UIData.updateData(currentSelections, key: "Swaras")
            
            // set up pads
            keyboardData.setSwaras()
            setUp()
            return true
        }
        return false
    }
    
    // get key count
    func getKeyCount() -> Int {
        return self.bounds.count
    }
    
    // get key position
    func getPos(index:Int) -> CGPoint {
        return CGPoint(x: bounds[index], y: yBounds[index])
    }
    
    // check if touched keys contain certain y
    func containsY(y:Int) -> Bool {
        let target = yHeights[y]
        
        // go through each key
        for i in 0..<selectedKeys.count {
            // check if selected key y is same
            if yBounds[selectedKeys[i]] == target {
                return true
            }
        }
        
        return false
    }
    
    // get furthest key press for string
    func getMaxBend(y:Int) -> CGPoint {
        if (points.isEmpty) {
            return CGPoint()
        }
        
        var max:CGFloat = 0
        var maxIndex = 0
        
        let target = yHeights[y]
        
        // go through each touch
        for i in 0..<points.count {
            // check if key y matches
            if yBounds[selectedKeys[i]] != target {
                continue
            }
            
            // get difference from key to touch
            let diff = initialY[i] - points[i].y
            if (abs(diff) > abs(max)) {
                max = diff
                maxIndex = i
            }
        }
        
        // return max
        return points[maxIndex]
    }
    
    // check if key selected
    func isSelected(index: Int) -> Bool{
        return selectedKeys.contains(index)
    }
    
    // get key index of touch
    func touchIndex(location: CGPoint) -> Int {
        // go through each key
        for i in 0..<bounds.count {
            let bound = bounds[i]
            let yBound = yBounds[i]
            
            // check x,y distance to key
            if (abs(bound - Int(location.x)) <= xSize / 2) {
                if (abs(yBound - Int(location.y)) <= ySize / 2) {
                    return i
                }
                
            }
        }
        return -1
    }
    
    // updates the current coords of the user drag
    func updateDrag(idx:Int) {
        let index = selectedKeys[idx]
        // checks if above or below drag start, gets limit based on that
        lowerLimits[idx] = getLowerBendLimit(index: index) - 1
        upperLimits[idx] = getUpperBendLimit(index: index) + 1
    }
    
    // get upper key limit
    private func getUpperBendLimit(index:Int) -> Float {
        if index == getKeyCount() - 1 {
            if uiSettings.UI == "Guitar" {
                return 2
            }
            let pitchIndex = pitches[index]
            var diff = offsets[index]
            
            if pitchIndex == xCount - 1 {
                diff += 12
            }
            
            let nextIndex = getUpperOffset()
            
            let nextPitch = keyboardData.currentKeyboard[nextIndex].getPitch()
            
            let sa = keyboardData.instrumentSettings.pitch
            
            let p = nextPitch + Int(sa) + diff
            
            return Float(p) - getPitch(index)
        }
        print(index)
        return getPitch(index+1) - getPitch(index)
    }
    
    func getLowerOffset() -> Int {
        return xCount - 1 - (2*keyboardData.instrumentSettings.extraKeys)
    }
    
    func getUpperOffset() -> Int {
        return 2 * keyboardData.instrumentSettings.extraKeys
    }
    
    // get lower key limit
    private func getLowerBendLimit(index: Int) -> Float {
        if index == 0 {
            if uiSettings.UI == "Guitar" {
                return -2
            }
            let pitchIndex = pitches[index]
            var diff = offsets[index]
            
            if pitchIndex == 0 {
                diff -= 12
            }
            
            let nextIndex = getLowerOffset()
            
            let nextPitch = keyboardData.currentKeyboard[nextIndex].getPitch()
            let sa = keyboardData.instrumentSettings.pitch
            
            let p = nextPitch + Int(sa) + diff
            
            return Float(p) - getPitch(index)
        }
        
        // get pitch delta
        return getPitch(index-1) - getPitch(index)
    }
    
    // check if touch in bounds
    func inBounds(location: CGPoint) -> Bool {
        return touchIndex(location: location) != -1
    }
    
    func getUpperMarkerLocation(_ idx: Int) -> CGFloat {
        let index = selectedKeys.firstIndex(of:idx)!
        
        let pitchRange = getUpperBendLimit(index: idx)
        
        let pitchPercent = pitchRange / (pitchRange + 1)
        
        return initialY[index] - (CGFloat(pitchPercent) * CGFloat(ySize / 2))
    }
    
    func getLowerMarkerLocation(_ idx: Int) -> CGFloat {
        let index = selectedKeys.firstIndex(of:idx)!
        
        let pitchRange = abs(getLowerBendLimit(index: idx))
        
        let pitchPercent = pitchRange / (pitchRange + 1)
        
        return initialY[index] + (CGFloat(pitchPercent) * CGFloat(ySize / 2))
    }
    
    // gets current offset from beginning of drag
    func getPitchBend(_ index:Int) -> Float {
        if uiSettings.UI == "Pad" {
            return 0
        }
        
        updateDrag(idx: index)
        
        // gets current y, and distance from initial y
        var distance = abs(initialY[index] - points[index].y)
        let keySize = ySize / 2
        
        if uiSettings.UI == "Guitar" {
            distance *= (1.0 / CGFloat(yCount))
        }
        
        let percentTravelled = min(1, distance / CGFloat(keySize))
        
        var shift : CGFloat
        
        if initialY[index] >= points[index].y {
            shift = percentTravelled * CGFloat(upperLimits[index])
        } else {
            shift = percentTravelled * CGFloat(lowerLimits[index])
        }
        
        // get x axis bend
        if uiSettings.UI == "Guitar" {
            shift += getXBend(index)
        }
        
        return Float(shift)
    }
    
    // reset pads
    private func reset() {
        bounds = Array()
        yBounds = Array()
        names = Array()
        yHeights = Array()
        pitches = Array()
        offsets = Array()
        upperLimits = [0,0,0,0,0]
        lowerLimits = [0,0,0,0,0]
        xCount = keyboardData.totalSwaras
    }
    
    // sets up piano, pads with fill screen
    private func setUpRegularKeysFill(frame:CGRect) {
        reset()
        
        // set padding
        xPadding = 50
        yPadding = 0
        
        // get sizes
        xSize = Int((frame.width - CGFloat((2 * xPadding))) / CGFloat(xCount))
        ySize = Int((frame.height) / CGFloat(yCount))
        
        // starting location
        var curXLocation = (xSize / 2) + xPadding
        var curYLocation = (ySize / 2) + yPadding
        
        // pitch offset
        var yOffset = 0
        
        // save y heights
        for _ in 0..<yCount {
            yHeights.append(curYLocation)
            curYLocation += ySize
        }
        
        curYLocation = (ySize / 2) + yPadding
        yOffset = 0
        for _ in 0..<yCount {
            curXLocation = (xSize / 2) + xPadding
            
            for i in 0..<xCount {
                names.append(i)
                pitches.append(i)
                offsets.append(yOffset)
                
                // append location
                bounds.append(curXLocation)
                yBounds.append(curYLocation)
                
                // update location
                curXLocation += xSize
            }
            yOffset += 12
            curYLocation += ySize
        }
        
        // save old frame for later use
        if !fullscreen {
            self.oldFrame = frame
        }
    }
    
    private func setUpRegularKeys(frame:CGRect) {
        // reset
        reset()
    
        // calculate padding
        xPadding = (Int(frame.width) - ((uiSettings.xSize * xCount)+((xCount-1) * uiSettings.xSpacing))) / 2
        yPadding = (Int(frame.height) - ((uiSettings.ySize * yCount)+((yCount-1) * uiSettings.ySpacing))) / 2
        
        // get start location
        var curXLocation = (uiSettings.xSize / 2) + xPadding
        var curYLocation = (uiSettings.ySize / 2) + yPadding
        
        // pitch offset
        var yOffset = 0
        
        // save y heights
        for _ in 0..<yCount {
            yHeights.append(curYLocation)
            curYLocation += uiSettings.ySpacing + uiSettings.ySize
        }
        
        // go through each x
        for i in 0..<xCount {
            curYLocation = (uiSettings.ySize / 2) + yPadding
            yOffset = 0
            
            // go through each y
            for _ in 0..<yCount {
                // save name, pitch
                names.append(i)
                pitches.append(i)
                
                offsets.append(yOffset)
                
                // save location
                bounds.append(curXLocation)
                yBounds.append(curYLocation)
                
                // update location
                curYLocation += uiSettings.ySpacing + uiSettings.ySize
                
                // update pitch offset
                yOffset += 12
            }
            
            // update location
            curXLocation += uiSettings.xSpacing + uiSettings.xSize
            
        }
        
        if !fullscreen {
            self.oldFrame = frame
        }
    }
    
    // get name of key at index
    func getName(_ index:Int) ->String {
        return keyboardData.currentKeyboard[names[index]].name
    }
    
    // set up frame
    func setUp(frame:CGRect?=nil,fullscreen:Bool = false) {
        var curFrame:CGRect
        
        // set frame
        if frame == nil {
            if oldFrame == nil {
                return
            }
            curFrame = oldFrame!
        }
        else {
            curFrame = frame!
        }
        
        self.fullscreen = fullscreen
        
        // set up frame given ui
        if uiSettings.UI == "Keyboard" {
            yCount = 1
            setUpRegularKeysFill(frame: curFrame)
        }
        else if uiSettings.UI == "Pad" {
            yCount = uiSettings.padRows
            setUpRegularKeysFill(frame: curFrame)
        }
        else if uiSettings.UI == "Guitar" {
            yCount = uiSettings.padRows
            setUpGuitarFrame(frame: curFrame)
        }
    }
    
    // set up guitar
    private func setUpGuitarFrame(frame:CGRect) {
        // reset pads
        reset()
        
        // get padding
        xPadding = 50
        yPadding = (Int(frame.height) - ((uiSettings.ySize * yCount)+((yCount-1) * uiSettings.ySpacing))) / 2
        
        // pitch difference of last to first key
        let pitchRange = CGFloat(keyboardData.currentKeyboard.last!.getPitch() - keyboardData.currentKeyboard[0].getPitch())
        var pitchShift = 0
        
        // width of pad area
        let size = frame.width - CGFloat((2 * xPadding))
        
        // start y location
        var curYLocation = (uiSettings.ySize / 2) + yPadding
        
        // save y heights
        for _ in 0..<yCount {
            yHeights.append(curYLocation)
            curYLocation += uiSettings.ySpacing + uiSettings.ySize
        }
        
        curYLocation = (uiSettings.ySize / 2) + yPadding
        
        xSize = min(uiSettings.xSize, Int((CGFloat(1) / pitchRange) * size))
        ySize = uiSettings.ySize
        
        let extra = keyboardData.instrumentSettings.extraKeys
        
        var padIndex = Int(pitchRange)
        
        let keyboard = Array(keyboardData.currentKeyboard[0+extra..<keyboardData.currentKeyboard.count - extra])
        let newCount = xCount - (2*extra)
        var keyIndex =  mod(0 - extra,newCount)
        // at first row, start at end and add keys downward
        
        if extra > 0 {
            pitchShift = -12
        }
        
        while padIndex >= 0 {
            // get pitch
            let pitch = keyboard[keyIndex].getPitch() + pitchShift
            
            // get x location
            let xLocation = (CGFloat(padIndex) / pitchRange) * size
            
            // save location
            self.bounds.append(xPadding + Int(xLocation))
            self.yBounds.append(curYLocation)
            
            // save name, pitch, offset
            self.names.append(keyIndex+extra)
            self.pitches.append(keyIndex+extra)
            self.offsets.append(pitchShift)

            // check if pitch needs shifting down
            if keyIndex == 0 {
                pitchShift -= 12
            }
            
            // update index
            keyIndex = mod(keyIndex-1,newCount)

            // get next pitch location
            var nextPitch = keyboard[keyIndex].getPitch() + pitchShift
            
            while nextPitch == pitch {
                // while pitches are same, skip
                keyIndex = mod(keyIndex-1,newCount)
                
                if keyIndex == 0 {
                    pitchShift -= 12
                }
                
                // get next pitch location
                nextPitch = keyboard[keyIndex].getPitch() + pitchShift
            }
            
            // update index
            padIndex -= (pitch - nextPitch)
        }
        // fix indices for pitch bending
        self.bounds.reverse()
        self.yBounds.reverse()
        self.names.reverse()
        self.pitches.reverse()
        self.offsets.reverse()

        // reset shift, index
        pitchShift = 0
        keyIndex = 0
        curYLocation += uiSettings.ySpacing + uiSettings.ySize
        
        padIndex = 0
        
        for key in keyboard {
            print(key.getPitch())
            print(key.name)
        }
        
        // go through each key in row
        while padIndex <= Int(pitchRange) {
            // get pitch
            let pitch = keyboardData.currentKeyboard[keyIndex].getPitch()
            
            let location = (CGFloat(padIndex) / pitchRange) * size

            // save location
            self.bounds.append(xPadding + Int(location))
            self.yBounds.append(curYLocation)
            
            // save name, pitch, offset
            self.names.append(keyIndex)
            self.pitches.append(keyIndex)
            self.offsets.append(pitchShift)
            
            // get next key
            keyIndex += 1
            
            if keyIndex == xCount {
                break
            }
            
            // get next pitch
            var nextPitch = keyboardData.currentKeyboard[keyIndex].getPitch()

            // get new pad index
            padIndex -= (pitch - nextPitch)
        }
        
        print(padIndex)
        
        pitchShift = 0
        
        // move key down 1
        keyIndex = mod(newCount - 1 + extra, newCount)
        
        if extra > 0 {
            pitchShift = 12
        }
        
        // update location
        curYLocation += uiSettings.ySpacing + ySize
        
        // start at 2nd row, apply to each after
        for _ in 2..<yCount {
            padIndex = 0
            
            // go through each key in row
            while padIndex <= Int(pitchRange) {
                // get pitch
                let pitch = keyboard[keyIndex].getPitch() + pitchShift
                
                let location = (CGFloat(padIndex) / pitchRange) * size

                // save location
                self.bounds.append(xPadding + Int(location))
                self.yBounds.append(curYLocation)
                
                // save name, pitch, offset
                self.names.append(keyIndex+extra)
                self.pitches.append(keyIndex+extra)
                self.offsets.append(pitchShift)
                 
                // check if need to shift pitch for next octave
                if keyIndex == newCount - 1 {
                    pitchShift += 12
                }
                
                // get next key
                keyIndex = mod(keyIndex + 1, newCount)
                
                // get next pitch
                var nextPitch = keyboard[keyIndex].getPitch() + pitchShift
                
                // skip duplicates
                while nextPitch == pitch {
                    keyIndex = mod(keyIndex + 1, newCount)
                    
                    // check if need to shift pitch for next octave
                    if keyIndex == newCount - 1{
                        pitchShift += 12
                    }
                    
                    // get next pitch again
                    nextPitch = keyboard[keyIndex].getPitch() + pitchShift
                }
                    
                // get new pad index
                padIndex -= (pitch - nextPitch)
            }
            
            // check if need to reset shift
            if keyIndex < 1 {
                pitchShift -= 12
            }
            
            // move key down 1
            keyIndex = mod(keyIndex-1,newCount)
            
            // update location
            curYLocation += uiSettings.ySpacing + ySize
        }
        
        // save frame for later use
        if !fullscreen {
            self.oldFrame = frame
        }
        
    }
    
    // checks can play key
    func canPlay(_ index:Int) -> Bool {
        // if not guitar, good to go
        if uiSettings.UI != "Guitar" {
            return true
        }
        
        // checks not on the same y as another touch
        let y = yBounds[index]
        
        for key in selectedKeys {
            if yBounds[key] == y {
                return false
            }
        }
        
        return true
    }
    
    // gets pitch at key
    func getPitch(_ index:Int) -> Float {
        let pVal = Float(keyboardData.currentKeyboard[pitches[index]].getPitch())
        let offset = Float(offsets[index])
        let sa = keyboardData.instrumentSettings.pitch
        
        return pVal + sa + offset
    }
    
    // get x axis bending
    private func getXBend(_ idx:Int) -> CGFloat {
        let range = keyboardData.currentKeyboard.last!.getPitch() - keyboardData.currentKeyboard.first!.getPitch()
        let delta = points[idx].x - initialX[idx]
        let sft = delta / (oldFrame!.width - CGFloat(2 * xPadding))
        
        return sft * CGFloat(range)
    }
}

func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}
