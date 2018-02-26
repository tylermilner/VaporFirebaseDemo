//
//  FirestoreDocument.swift
//  App
//
//  Created by Tyler Milner on 2/25/18.
//

import Foundation

struct FirestoreDocumentConfig {
    let projectId: String
    let databaseId: String
    let documentPath: String
}

protocol FirestoreDocument {
    var documentConfig: FirestoreDocumentConfig { get }
    var resourceName: String { get }
}

extension FirestoreDocument {
    var resourceName: String {
        let projectId = documentConfig.projectId
        let databaseId = documentConfig.databaseId
        let documentPath = documentConfig.documentPath
        
        // The Firestore resource name of the document, for example projects/{projectId}/databases/{databaseId}/documents/{document_path}
        return "projects/\(projectId)/databases/\(databaseId)/documents/\(documentPath)"
    }
}
