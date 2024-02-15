//
//  Test_InstrumentStorage.swift
//  Raga_App UnitTests
//
//  Created by Aiden Walker on 10/10/23.
//

import XCTest

final class Test_InstrumentStorage: XCTestCase {
    var handler = InstrumentHandler()
    
    override func setUp() async throws {
        handler = InstrumentHandler()
    }
    
    func testGet() {
        let noises = handler.getNoises()
        XCTAssert(noises.contains("Pad"))
        XCTAssert(!noises.contains("Guitar"))
        
        let instruments = handler.getInstruments()
        XCTAssert(!instruments.contains("Pad"))
        XCTAssert(instruments.contains("Guitar"))
        
        let all = handler.getAll()
        XCTAssert(all.contains("Pad"))
        XCTAssert(all.contains("Guitar"))
        XCTAssert(!all.contains("test"))
        
        let empty = handler.getSound("test")
        XCTAssert(empty == "")
        let sound = handler.getSound("Pad")
        XCTAssert(sound == "Sounds/Synthetic Sounds/Pad")
    }
}
