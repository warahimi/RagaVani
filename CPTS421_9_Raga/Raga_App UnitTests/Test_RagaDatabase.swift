//
//  Test_RagaDatabase.swift
//  Raga_App UnitTests
//
//  Created by Aiden Walker on 10/10/23.
//

import XCTest

final class Test_RagaDatabase: XCTestCase {
    var db = RagaDatabase()
    
    override func setUp() async throws {
        db.categories = Dictionary()
    }
    
    func testAdd() {
        
        // adds melakartha
        var found = db.categories["Melakartha"] != nil
        XCTAssert(!found)
        
        let r1 = Raga2(inputs: [1, 1, 1, 1, 1, 1, 1], samvadi: "", vadi: "", name: "test", description: "", category: "Melakartha")
        
        db.addRaga(raga: r1)
        
        found = db.categories["Melakartha"]!.contains { n in
            n.name == "test"
        }
        XCTAssert(found)
        
        let r2 = Raga2(inputs: [1, 1, 1, 1, 1, 1, 1], samvadi: "", vadi: "", name: "test2", description: "", category: "Other")
        db.addRaga(raga: r2)
        found = db.categories["Other"]!.contains { n in
            n.name == "test2"
        }
        XCTAssert(found)
        
        found = db.categories["Other"]!.contains { n in
            n.name == "test"
        }
        XCTAssert(!found)
        
        found = db.categories["Melakartha"]!.contains { n in
            n.name == "test2"
        }
        XCTAssert(!found)
    }
    
    func testAddMultiple() {
        let r1 = Raga2(inputs: [1, 1, 1, 1, 1, 1, 1], samvadi: "", vadi: "", name: "test", description: "", category: "test")
        
        let r2 = Raga2(inputs: [1, 1, 1, 1, 1, 1, 2], samvadi: "", vadi: "", name: "test2", description: "", category: "test")
        let r3 = Raga2(inputs: [1, 1, 1, 1, 1, 1, 1], samvadi: "", vadi: "", name: "test", description: "", category: "test")
        db.addRagas(ragas: [r1, r2, r3])
        XCTAssert(db.categories["test"]!.count == 2)
    }
    
    func testSearch() {
        // adds melakartha
        XCTAssert(db.searchRaga(name: "test").isEmpty)
        let r1 = Raga2(inputs: [1, 1, 1, 1, 1, 1, 1], samvadi: "", vadi: "", name: "test", description: "", category: "Melakartha")
        db.addRaga(raga: r1)
        var found = db.searchRaga(name: "test")
        XCTAssert(found[0] == "test")
    }
}
