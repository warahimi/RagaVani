//
//  Test_TouchHandler.swift
//  Raga_App UnitTests
//
//  Created by Aiden Walker on 10/10/23.
//

import XCTest

final class Test_TouchHandler: XCTestCase {
    var data = UserData()
    var handler = TouchHandler(uiSettings: UISettings(), keySettings: InstrumentSettings())
    
    override func setUp() async throws {
        data.reset()
        data.uiSettings.UI = "Pad"
        handler = TouchHandler(uiSettings: data.uiSettings, keySettings: data.instrumentSettings)
        handler.setUp(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
    }
    
    func testUpdateSwaras() {
        print(handler.keyboardData.instrumentSettings.swaras)
        XCTAssert(handler.keyboardData.instrumentSettings.swaras == [1,1,1,1,1,1,1])
        
        handler.keyboardData.instrumentSettings.swaras = [1,2,1,1,1,1,1]
        handler.updateSwaras(currentSelections: [1,2,1,1,1,1,1], category: "test")
        
        XCTAssert(handler.keyboardData.instrumentSettings.swaras == [1,2,1,1,1,1,1])
        
        handler.updateSwaras(currentSelections: [0,0,0,0,0,0,0], category: "test")
        
        XCTAssert(handler.keyboardData.instrumentSettings.swaras == [1,2,1,1,1,1,1])
    }
    
    func testBend() {
        var x = handler.bounds[0]
        var y = handler.yBounds[0]
        
        var point = CGPoint(x: x, y: y)
        
        handler.selectedKeys.append(0)
        handler.points.append(point)
        handler.initialX.append(point.x)
        handler.initialY.append(point.y)
        
        x = handler.bounds[3]
        y = handler.yBounds[3]
        
        point = CGPoint(x: x, y: y)
        
        handler.selectedKeys.append(3)
        handler.points.append(point)
        handler.initialX.append(point.x)
        handler.initialY.append(point.y)
        
        handler.points[0].y += 50
        
        XCTAssert(handler.getPitchBend(0) != 0)
    }
    
    func testGetPos() {
        var x = handler.bounds[0]
        var y = handler.yBounds[0]
        
        var point = CGPoint(x: x, y: y)
        
        XCTAssert(handler.getPos(index: 0).x == point.x && handler.getPos(index: 0).y == point.y)
    }
    
    func testIsSelected() {
        handler.selectedKeys.append(5)
        XCTAssert(handler.isSelected(index: 5))
        XCTAssert(!handler.isSelected(index: 0))
    }
    
    func testInYBounds() {
        handler.selectedKeys.append(0)
        XCTAssert(handler.containsY(y: 0))
        XCTAssert(!handler.containsY(y: 1))
    }
    
    func testTouchIndex() {
        var x = handler.bounds[0]
        var y = handler.yBounds[0]
        
        var point = CGPoint(x: x, y: y)
        
        XCTAssert(handler.touchIndex(location: point) == 0)
        
        point = CGPoint(x:x, y:y+50)
        
        XCTAssert(handler.touchIndex(location: point) == -1)
    }
    
    func testKeyCount() {
        XCTAssert(handler.getKeyCount() == handler.xCount * handler.yCount)
    }
    
    func testName() {
        XCTAssert(handler.getName(0) == "S")
    }
    
    func testGetPitch() {
        // sa row 0 = 0 offset + 60 pitch + 1
        XCTAssert(handler.getPitch(0) == 61)
    }
    
    func testInBounds() {
        var x = handler.bounds[0]
        var y = handler.yBounds[0]
        
        var point = CGPoint(x: x, y: y)
        
        XCTAssert(handler.inBounds(location: point))
        
        point = CGPoint(x:x, y:y+50)
        
        XCTAssert(!handler.inBounds(location: point))
    }
}
