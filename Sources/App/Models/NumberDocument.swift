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
    
    // MARK: - Init
    
    init(value: Int, projectId: String, databaseId: String, documentPath: String) {
        self.value = value
        super.init(projectId: projectId, databaseId: databaseId, documentPath: documentPath)
    }
}

extension NumberDocument: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var documentJSON = JSON()
        try documentJSON.set("name", "\(resourceName)")
        
        var numberValueJSON = JSON()
        try numberValueJSON.set("integerValue", value)
        
        var numberJSON = JSON()
        try numberJSON.set("number", numberValueJSON)
        
        try documentJSON.set("fields", numberJSON)
        
        return documentJSON
    }
}
