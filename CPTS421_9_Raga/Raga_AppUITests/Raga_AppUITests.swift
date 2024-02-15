//
//  Raga_AppUITests.swift
//  Raga_AppUITests
//
//  Created by Aiden Walker on 10/10/23.
//

import XCTest
@testable import Raga_App
final class Raga_AppUITests: XCTestCase {
    override func setUp() async throws {
        let data = UserData()
        data.reset()
        sleep(5)
    }
    
    func testRecording() {
        
        let app = XCUIApplication()
        app.launch()
        sleep(5)
        print(XCUIApplication().debugDescription)
        
      // 1
        var recordBut = app.staticTexts["Record"].firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        recordBut.tap()
        
        //let key = app.otherElements.containing(.any, identifier: "Piano Button 1").firstMatch
        var key = app.staticTexts.matching(.any, identifier: "Piano Button 1").firstMatch
        print(key.exists)
        key = app.staticTexts["Piano Button 1"]
        print(key.exists)
        key.coordinate(withNormalizedOffset: .zero).tap()
        sleep(2)
        
        recordBut = app.staticTexts["Recording"].firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        recordBut.tap()
        let val = app.images["Stop Icon"]
        XCTAssert(!val.exists)
        
        let recordingButton = app.images["record"]
        recordingButton.tap()
        
        sleep(3)
        let stop = app.images["Stop Icon"].firstMatch
        XCTAssert(stop.exists)
        
        let start = app.images["Play Icon"].firstMatch
        start.tap()
        sleep(2)
        stop.tap()
        sleep(1)
        
        let rename = app.images["pencil"].firstMatch
        rename.tap()
        sleep(2)
        let field = app.textFields["..."]
        let ok = app.buttons["Record Name Ok"]
        
        field.typeText("Name")
        ok.tap()
        sleep(3)
        XCTAssert(app.staticTexts["Name"].exists)
        
        let delete = app.images["Name del"]
        delete.firstMatch.tap()
        sleep(2)
        app.buttons["Yes"].firstMatch.tap()
        sleep(3)
        XCTAssert(!app.staticTexts["Name"].exists)
        app.terminate()
    }
    
    func matchingKeys(_ app :XCUIApplication) -> Int {
        var i = 0
        var search = "Piano Button \(i)"
        var count = 0
        while app.staticTexts.matching(identifier: search).firstMatch.exists {
            count += 1
            i += 1
            search = "Piano Button \(i)"
        }
        
        return count
    }
    
    func testSettings() {
        let app = XCUIApplication()
        app.launch()
        sleep(5)
        let button = app.staticTexts["UI"].firstMatch
        button.coordinate(withNormalizedOffset: .zero).tap()
        
        let pad = app.staticTexts["Pad"].firstMatch
        pad.coordinate(withNormalizedOffset: .zero).tap()
        
        let beforeCount = matchingKeys(app)
      // 1
        let val = app.images["user icon"]
       
        val.tap()
        
        let settings = app.staticTexts["Settings"]
        settings.tap()
        
        
        app.staticTexts["Pad Rows"].firstMatch.tap()
        app.buttons["2"].firstMatch.tap()
        
        app.staticTexts["Key Width"].firstMatch.tap()
        app.buttons["40"].firstMatch.tap()
        
        
        
        let play = app.staticTexts["Play"].firstMatch.coordinate(withNormalizedOffset: .zero)
        play.tap()
        sleep(2)
        
        let afterCount = matchingKeys(app)
        print(beforeCount)
        print(afterCount)
        XCTAssert(afterCount < beforeCount)
        
        val.tap()
        settings.tap()
        
        while !app.buttons["Reset All"].exists {
            app.swipeUp()
        }
        
        
        app.buttons["Reset All"].firstMatch.tap()
        
        play.tap()
        
        app.terminate()
    }
    
    func testInstrumentPage() {
        let app = XCUIApplication()
        app.launch()
        sleep(5)
        var key = app.staticTexts["Piano Button 1"].firstMatch
        print(key.exists)
        key.coordinate(withNormalizedOffset: .zero).tap()
        sleep(2)
        
        
        let instrumentPage = app.staticTexts["Instrument"].firstMatch
        instrumentPage.tap()
        
        print(XCUIApplication().debugDescription)
        
        let instrumentButton = app.staticTexts["Sitar instrument"].firstMatch.coordinate(withNormalizedOffset: .zero).tap()
        
        app.staticTexts["Play"].firstMatch.tap()
        sleep(1)
        key = app.staticTexts["Piano Button 1"].firstMatch
        key.coordinate(withNormalizedOffset: .zero).tap()
        sleep(2)
        app.terminate()
    }
    
    func testRagaChange() {
        let app = XCUIApplication()
        app.launch()
        sleep(5)
        
        let button = app.staticTexts["Ri 3 Button"].firstMatch
        button.coordinate(withNormalizedOffset: .zero).tap()
        
        let ragaPage = app.staticTexts["Raga"].firstMatch
        ragaPage.tap()
        
        let allRagas = app.buttons["All Ragas"].firstMatch
        allRagas.tap()
        
        sleep(1)
        
        let kanakangi = app.buttons["Kanakangi"].firstMatch
        kanakangi.tap()
        sleep(1)
        
        let select = app.buttons["Set Raga"].firstMatch
        select.tap()
        
        app.staticTexts["Play"].firstMatch.tap()
        
        sleep(2)
        XCTAssert(matchingKeys(app) > 1)
        
        app.terminate()
    }
    
    func testPerformance() {
        let app = XCUIApplication()
        app.launch()
    }
}
