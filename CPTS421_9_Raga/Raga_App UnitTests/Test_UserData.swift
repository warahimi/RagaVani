//
//  Test_UserData.swift
//  Raga_App UnitTests
//
//  Created by Aiden Walker on 10/21/23.
//

import XCTest

final class Test_UserData: XCTestCase {
    let data = UserData()

    func testReset() {
        data.instrumentSettings.pitch = 30
        data.reset()
        XCTAssert(data.instrumentSettings.pitch == 60)
    }
}
