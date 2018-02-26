//
//  Number.swift
//  App
//
//  Created by Tyler Milner on 2/25/18.
//

import Foundation

class NumberDocument: FirestoreDocument {
    
    // MARK: - Properties
    
    let value: Int
    let nextUpdate: Date
    
    // MARK: - Init
    
    init(value: Int, nextUpdate: Date, projectId: String, databaseId: String, documentPath: String) {
        self.value = value
        self.nextUpdate = nextUpdate
        super.init(projectId: projectId, databaseId: databaseId, documentPath: documentPath)
    }
}

extension NumberDocument: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var documentJSON = JSON()
        try documentJSON.set("name", "\(resourceName)")
        
        var numberValueJSON = JSON()
        try numberValueJSON.set("integerValue", value)
        
        var nextUpdateValueJSON = JSON()
        try nextUpdateValueJSON.set("timestampValue", nextUpdate)
        
        var numberJSON = JSON()
        try numberJSON.set("number", numberValueJSON)
        try numberJSON.set("nextUpdate", nextUpdateValueJSON)
        
        try documentJSON.set("fields", numberJSON)
        
        return documentJSON
    }
}
