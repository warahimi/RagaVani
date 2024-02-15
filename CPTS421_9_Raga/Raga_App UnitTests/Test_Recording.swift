//
//  Test_Recording.swift
//  Raga_App UnitTests
//
//  Created by Aiden Walker on 10/21/23.
//

import XCTest

final class Test_Recording: XCTestCase {
    func testGetFiles() {
        XCTAssert(!RecordingHandler.getFiles().isEmpty)
        
    }
    
    func testGetPath() {
        XCTAssert(RecordingHandler.getRecordingPath().lastPathComponent == "recordings")
    }
}
