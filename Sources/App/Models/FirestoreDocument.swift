//
//  FirestoreDocument.swift
//  App
//
//  Created by Tyler Milner on 2/25/18.
//

import Foundation

struct FirestoreDocument {
    
    // MARK: - Properties
    
    private let projectId: String
    private let databaseId: String
    private let documentPath: String
    var resourceName: String {
        // The Firestore resource name of the document, for example projects/{projectId}/databases/{databaseId}/documents/{document_path}
        return "projects/\(projectId)/databases/\(databaseId)/documents/\(documentPath)"
    }
    
    // MARK: - Init
    
    init(projectId: String, databaseId: String, documentPath: String) {
        self.projectId = projectId
        self.databaseId = databaseId
        self.documentPath = documentPath
    }
}
