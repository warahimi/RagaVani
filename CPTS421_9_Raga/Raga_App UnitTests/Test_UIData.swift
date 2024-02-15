//
//  Raga_App_UnitTests.swift
//  Raga_App UnitTests
//
//  Created by Aiden Walker on 10/10/23.
//

import XCTest

// 100% test coverage
final class Test_UIData: XCTestCase {
    let settings = UserData()
    
    override func setUp() async throws {
        settings.reset()
    }
    
    
    func testUserdefaults() {
        var pitch = UIData.getData(Float.self, "Pitch") as? Float
        XCTAssert(pitch != nil)
        XCTAssertEqual(pitch!, 60)
        
        pitch = UIData.getData(Float.self, "Pitch") as? Float
        XCTAssert(pitch != nil)
        XCTAssertEqual(pitch!, 60)
        
        //data.currentInstrument = "test"
        let instrument = UIData.getData(String.self, "Sound") as? String
        XCTAssert(instrument != nil)
        XCTAssertEqual(instrument!, "Guitar")
    }
    
    func testUpdateData() {
        UIData.updateData(30, key: "Pitch")
        let pitch = UIData.getData(Float.self, "Pitch") as? Float
        XCTAssert(pitch != nil)
        XCTAssertEqual(pitch!, 30)
    }
    
    func testContainsData() {
        XCTAssert(!UIData.containsData("test"))
        XCTAssert(UIData.containsData("UI"))
    }
}
