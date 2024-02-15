//
//  RagaLogic.swift
//  TestApp
//
//  Created by Aiden Walker on 2/14/23.
//


import Foundation

// verifies that swaras fit into a raga type
class RagaRules {
    var name : String

    init(name: String) {
        self.name = name
    }

    // test swara input
    func testInput(inputs: Array<Int>) -> Bool {
        var output: Bool

        switch (self.name.lowercased()) {
            case "melakartha" :
                output = testMelakartha(inputs: inputs)
            case "shadava" :
                output = testShadava(inputs: inputs)
            case "audava" :
                output = testAudava(inputs: inputs)
            default :
                output = testDefault(inputs: inputs)
        }

        return output
    }
    
    // test swara input
    func testAll(inputs: Array<Int>) -> String? {
        if testMelakartha(inputs: inputs) {
            return "Melakartha"
        }
        else if testShadava(inputs: inputs) {
            return "Shadava"
        }
        else if testAudava(inputs: inputs) {
            return "Audava"
        }
        else if testDefault(inputs: inputs) {
            return "Janya"
        }
        
        return nil
    }
    
    // test default raga
    // 3 swaras, at needs at least m or p
    func testDefault(inputs: Array<Int>) -> Bool {
        let m = inputs[3]
        let p = inputs[4]
        
        if m == 0 && p == 0 {
            return false
        }
        
        var count = 0
        
        // checks that has m or p
        if inputs[3] == 0 && inputs[4] == 0 {
            return false
        }
        
        // goes through, gets swara count
        for i in 1...(inputs.count - 1) {
            if inputs[i] != 0 {
                count += 1
            }
        }
        
        return count >= 3
    }
    
    // test raga is audava
    func testAudava(inputs: Array<Int>) -> Bool {
        var count = 0
        
        // goes through, gets swara count
        for i in 0...(inputs.count - 1) {
            if inputs[i] == 0 {
                count += 1
            }
        }
        
        if count != 2 {
            return false
        }
        
        return checkAscending(inputs: inputs)
    }
    
    // test if raga is shadava
    func testShadava(inputs: Array<Int>) -> Bool {
        var count = 0
        
        // goes through, gets swara count
        for i in 0...(inputs.count - 1) {
            if inputs[i] == 0 {
                count += 1
            }
        }
        
        if count != 1 {
            return false
        }
        
        return checkAscending(inputs: inputs)
    }
    
    // check entries are ascending
    func checkAscending(inputs: [Int]) -> Bool {
        let r = inputs[1]
        let g = inputs[2]
        let m = inputs[3]
        let p = inputs[4]
        let d = inputs[5]
        let n = inputs[6]
        
        // checks that has m or p
        if m == 0 && p == 0 {
            return false
        }
        
        if r != 0 && g != 0 && !self.CheckEntries(swara1: r, swara2: g) {
            return false
        }
        if d == 0 || n == 0 {
            return true
        }
        
        return self.CheckEntries(swara1: d, swara2: n)
    }
    
    // test melakartha raga
    func testMelakartha(inputs: Array<Int>) -> Bool {
        for input in inputs {
            if input == 0 {
                return false
            }
        }
        
        // get each swara
        let r = inputs[1]
        let g = inputs[2]
        let d = inputs[5]
        let n = inputs[6]
        
        if !self.CheckEntries(swara1: r, swara2: g) {
            return false
        }
        
        return self.CheckEntries(swara1: d, swara2: n)
    }
    
    // check if entries work for melakartha
    func CheckEntries(swara1: Int, swara2: Int) -> Bool {
        if swara1 == 1 {
            return true
        }
        else if swara1 == 2 {
            return swara2 >= swara1
        }
        
        return swara1 == swara2
    }
}
