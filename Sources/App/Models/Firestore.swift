//
//  Firestore.swift
//  App
//
//  Created by Tyler Milner on 2/25/18.
//

import Foundation
import HTTP

struct Firestore {
    
    // MARK: - Properties
    
    private let firestoreBaseURL = "https://firestore.googleapis.com/v1beta1"
    private let accessToken: String
    private var authorizationHeader: [HeaderKey: String] {
        return [.authorization: "Bearer \(accessToken)"]
    }
    
    // MARK: - Init
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    // MARK: - Public
    
    func updateDocument(_ document: (FirestoreDocument & JSONRepresentable), using client: ClientFactoryProtocol) throws -> Response {
        let documentURL = generateDocumentURL(for: document)
        let documentJSON = try document.makeJSON()
        
        return try client.patch(documentURL, query: [:], authorizationHeader, documentJSON, through: [])
    }
    
    // MARK: - Private
    
    private func generateDocumentURL(for document: FirestoreDocument) -> String {
        return "\(firestoreBaseURL)/\(document.resourceName)"
    }
}
