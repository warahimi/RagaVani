//
//  Test_Preset.swift
//  Raga_App UnitTests
//
//  Created by Aiden Walker on 10/10/23.
//

import XCTest

final class Test_Preset: XCTestCase {
    var handler = PresetHandler()
    var data = UserData()
    
    override func setUp() async throws {
        data.reset()
        handler = PresetHandler()
        handler.settings = data
        handler.clearPresets()
    }
    
    func testAdd() {
        XCTAssert(handler.presets.isEmpty)
        handler.addPreset(name: "preset1",category: "m")
        
        let pitch = data.instrumentSettings.pitch
        XCTAssert(handler.presets[0].name == "preset1")
        XCTAssert(handler.presets[0].pitch == pitch)
        
        data.instrumentSettings.pitch = 50
        let pitch2 = data.instrumentSettings.pitch
        
        handler.addPreset(name: "preset2",category: "m")
        
        XCTAssert(handler.presets[1].name == "preset2")
        XCTAssert(handler.presets[1].pitch == pitch2)
    }
    
    func testRemove() {
        XCTAssert(handler.presets.isEmpty)
        handler.addPreset(name: "preset1",category: "m")
        handler.addPreset(name: "preset2",category: "m")
        
        XCTAssert(handler.presets[0].name == "preset1")
        
        handler.removePreset(preset: handler.presets[0])
        
        XCTAssert(handler.presets.count == 1)
        XCTAssert(handler.presets[0].name == "preset2")
    }
    
    func testReplace() {
        XCTAssert(handler.presets.isEmpty)
        handler.addPreset(name: "preset1",category: "m")
        
        let pitch = data.instrumentSettings.pitch
        XCTAssert(handler.presets[0].name == "preset1")
        XCTAssert(handler.presets[0].pitch == pitch)
        
        data.instrumentSettings.pitch = 50
        let pitch2 = data.instrumentSettings.pitch
        
        handler.replacePreset(preset: handler.presets[0])
        
        XCTAssert(handler.presets[0].name == "preset1")
        XCTAssert(handler.presets[0].pitch == pitch2)
        
        
    }
    
    func testRename() {
        XCTAssert(handler.presets.isEmpty)
        handler.addPreset(name: "preset1",category: "m")
        
        let pitch = data.instrumentSettings.pitch
        XCTAssert(handler.presets[0].name == "preset1")
        XCTAssert(handler.presets[0].pitch == pitch)
        
        handler.renamePreset(preset: handler.presets[0], name: "preset2")
        
        XCTAssert(handler.presets[0].name == "preset2")
        XCTAssert(handler.presets[0].pitch == pitch)
    }
    
    func testApply() {
        XCTAssert(handler.presets.isEmpty)
        handler.addPreset(name: "preset1",category: "m")
        
        let pitch = data.instrumentSettings.pitch
        XCTAssert(handler.presets[0].name == "preset1")
        XCTAssert(handler.presets[0].pitch == pitch)
        
        data.instrumentSettings.pitch = pitch - 10
        
        handler.applyPreset(preset: handler.presets[0])
        XCTAssert(data.instrumentSettings.pitch == pitch)
    }
}
