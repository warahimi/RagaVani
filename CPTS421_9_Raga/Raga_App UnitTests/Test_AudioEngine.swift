//
//  Test_AudioEngine.swift
//  Raga_App UnitTests
//
//  Created by Aiden Walker on 10/10/23.
//

import XCTest

final class Test_AudioEngine: XCTestCase {
    var engine = InstrumentConductor(settings: AudioSettings())
    let data = UserData()
    
    override func setUp() async throws {
        data.reset()
        RecordingHandler.clearRecordings()
        engine = InstrumentConductor(settings: data.audioSettings)
    }
    
    func testADSR() {
        data.audioSettings.attack = 1
        engine.setADSR()
        XCTAssert(engine.envelopes[0].attackDuration == 1)
    }
    
    func testBend() {
        engine.bend(offset: 1, index: 5)
        XCTAssertEqual(engine.engines[5].tuning, 1)
    }
    
    func testRecord() {
        let before = RecordingHandler.getFiles().count
        engine.record()
        XCTAssert(engine.isRecording)
        sleep(1)
        engine.stopRecord()
        XCTAssert(before + 1 == RecordingHandler.getFiles().count)
    }
}
