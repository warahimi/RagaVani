//
//  RagaDatabase.swift
//  Raga_App
//
//  Created by Aiden Walker on 2/16/23.
//

import Foundation



// stores all ragas
class RagaDatabase : ObservableObject {
    @Published var categories: Dictionary<String,[Raga]> = Dictionary()
    var dbVersion : String = UIData.initalizeData("", "DB Version") as! String
    
    // sets up local database
    func setUpDB(fetchedRagas:[Raga]?) {
        var ragas = [Raga]()
        
        // path of ragas file
        let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ragas")
        
        // checks if didnt grab data
        if fetchedRagas == nil {
            // tries to get data in ragas file
            if FileManager.default.fileExists(atPath: dataPath.path) {
                // Attempt to decode received data as an array of Raga
                ragas = try! JSONDecoder().decode([Raga].self, from: Data(contentsOf: dataPath))
            }
            setUp(ragas: ragas)
            return
        }
    
        // save data to ragas file
        let data = try? JSONEncoder().encode(fetchedRagas!)
        do {
            try data?.write(to: dataPath)
        }
        catch {
            
        }
        
        // update ragas, setup
        UIData.updateData(fetchedRagas!, key: "ragas")
        setUp(ragas: fetchedRagas!)
    }
    
    // no connection to internet, get basic ragas
    func addMore() -> [Raga]{
        // adds melakartha
        let r1 = Raga(id: "local1", userId: "Local Ragas",inputs: [1, 1, 1, 1, 1, 1, 1], samvadi: "Pa", vadi: "Sa", name: "Kanakangi", description: "", category: "Melakartha",is_public: false)
        let r2 = Raga(id: "local2", userId: "Local Ragas",inputs: [1, 1, 1, 1, 1, 1, 2], samvadi: "Pa", vadi: "Sa", name: "Rathnangi", description: "", category: "Melakartha",is_public: false)
        let r3 = Raga(id: "local3", userId: "Local Ragas",inputs: [1, 1, 1, 1, 1, 1, 3], samvadi: "Pa", vadi: "Sa", name: "Ganamurthi", description: "", category: "Melakartha",is_public: false)
        let r4 = Raga(id: "local4", userId: "Local Ragas",inputs: [1, 1, 1, 1, 1, 2, 2], samvadi: "Pa", vadi: "Sa", name: "Vanaspathi", description: "", category: "Melakartha",is_public: false)
        let r5 = Raga(id: "local5", userId: "Local Ragas",inputs: [1, 1, 1, 1, 1, 2, 3], samvadi: "Pa", vadi: "Sa", name: "Manavathi", description: "", category: "Melakartha",is_public: false)
        let r6 = Raga(id: "local6", userId: "Local Ragas",inputs: [1, 1, 1, 1, 1, 3, 3], samvadi: "Pa", vadi: "Sa", name: "Thanarupi", description: "", category: "Melakartha",is_public: false)
        
        categories["Melakartha"] = []
        categories["Shadava"] = []
        categories["Audava"] = []
        let ragas = [r1,r2,r3,r4,r5,r6]
        
        return ragas
    }
    
    // get all ragas
    func getAllRagas() -> [Raga] {
        var ragas = [Raga]()
        
        // go through all categories
        for curRagas in categories.values {
            ragas.append(contentsOf: curRagas)
        }
        
        return ragas
    }
    
    // set up ragas
    func setUp(ragas:[Raga]) {
        // add each raga
        for raga in ragas {
            addRaga(raga: raga)
        }
    }
    
    // get all categories
    func getCategories() -> [String] {
        return Array(categories.keys);
    }
    
    // checks if contains given category
    func containsCategory(category: String) -> Bool {
        return categories.keys.contains(category)
    }
    
    // add a raga
    func addRaga(raga:Raga) {
        // create cateogory if needed
        if categories[raga.category] == nil {
            categories[raga.category] = []
        }
        
        // get val
        var arr = categories[raga.category]!
        
        // check if contains name
        for values in categories.values {
            for value in values {
                if value.name == raga.name {
                    return
                }
            }
        }
        
        // add raga
        arr.append(raga)
        categories[raga.category] = arr
    }
    
    // searches raga and gets list of matches
    func searchRaga(name:String) -> Array<String> {
        // no name to search
        if name == "" {
            return []
        }
        
        let search = name.lowercased()
        var output:Array<String> = []
        
        for cat in categories.keys {
            // goes through each raga
            if cat.lowercased().starts(with: search) {
                output.append(cat)
            }
            for raga in categories[cat]! {
                if raga.name.lowercased().starts(with: search) {
                    output.append(raga.name)
                }
            }
            
        }
        
        return output
    }
    
    // find category from given input
    func findCategory(inputs: Array<Int>) -> String {
        // check if matches any raga
        if let raga = findRaga(inputs: inputs) {
            return raga.category
        }
        
        // check if raga fits in category
        for cat in categories.keys {
            let rules = RagaRules(name: cat)
            if let val = rules.testAll(inputs: inputs) {
                return val
            }
        }
        
        return "None"
    }
    
    // find name from given input
    func findName(inputs: Array<Int>) -> String {
        // search with swaras
        if let raga = findRaga(inputs: inputs) {
            return raga.name
        }
        
        return "Custom"
    }
    
    // search for a certain raga based on swara values
    func findRaga(inputs: [Int]) -> Raga? {
        for cat in categories.keys {
            // goes through each raga
            for raga in categories[cat]! {
                var same = true
                
                // checks if each swara value is the same
                for i in 1..<inputs.count {
                    if inputs[i] != raga.inputs[i] {
                        same = false
                    }
                }
                
                if same {
                    return raga
                }
            }
        }
        
        return nil
    }
}
