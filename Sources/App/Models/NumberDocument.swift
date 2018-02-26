//
//  Number.swift
//  App
//
//  Created by Tyler Milner on 2/25/18.
//

import Foundation

struct NumberDocument: FirestoreDocument {
    
    // MARK: - Properties
    
    let value: Int
    var documentConfig: FirestoreDocumentConfig
    
    // MARK: - Init
    
    init(value: Int, documentConfig: FirestoreDocumentConfig) {
        self.value = value
        self.documentConfig = documentConfig
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
