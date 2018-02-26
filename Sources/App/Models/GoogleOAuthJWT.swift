//
//  GoogleOAuthJWT.swift
//  App
//
//  Created by Tyler Milner on 2/25/18.
//

import Vapor
import JWT
import Foundation

/// Represents the JWT used to authenticate with Google using their server-to-server OAuth 2.0 process.
struct GoogleOAuthJWT {
    
    // MARK: - Properties
    
    private let serviceAccountEmail: String
    
    // MARK: - Init
    
    init(serviceAccountEmail: String) {
        self.serviceAccountEmail = serviceAccountEmail
    }
    
    // MARK: - Public
    
    func generateJWT(using signer: Signer) throws -> String {
        let headers = try generateHeaders()
        let claims = try generateClaims()
        let jwt = try JWT(headers: headers, payload: claims, signer: signer)
        
        return try jwt.createToken()
    }
    
    // MARK: - Private
    
    private func generateHeaders() throws -> JSON {
        var headersJSON = JSON()
        try headersJSON.set("alg", "RS256")
        try headersJSON.set("typ", "JWT")
        return headersJSON
    }
    
    private func generateClaims() throws -> JSON {
        let issuedTime = Date()
        let timeToLive: TimeInterval = 60 * 30 // 30 minutes (max is 60)
        let expirationTime = issuedTime.addingTimeInterval(timeToLive)
        
        var claimsJSON = JSON()
        try claimsJSON.set("iss", serviceAccountEmail) // the value of "client_email" in the service account private key JSON
        try claimsJSON.set("scope", "https://www.googleapis.com/auth/datastore")
        try claimsJSON.set("aud", "https://www.googleapis.com/oauth2/v4/token")
        try claimsJSON.set("exp", Int(expirationTime.timeIntervalSince1970))
        try claimsJSON.set("iat", Int(issuedTime.timeIntervalSince1970))
        return claimsJSON
    }
}
