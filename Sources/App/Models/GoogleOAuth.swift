//
//  GoogleOAuth.swift
//  App
//
//  Created by Tyler Milner on 2/25/18.
//

import Foundation
import JWT
import Foundation

struct GoogleOAuth {
    
    // MARK: - Properties
    
    private let googleOAuthURL = "https://www.googleapis.com/oauth2/v4/token"
    private let jwtSigner: Signer
    private let serviceAccountEmail: String
    
    // MARK: - Init
    
    init(jwtSignerName: String, serviceAccountEmail: String, droplet: Droplet) {
        guard let signer = droplet.signers?[jwtSignerName] else {
            fatalError("Unable to locate JWT signer. Make sure your 'Config/jwt.json' file contains a 'signers' object with a '\(jwtSignerName)' key. See Vapor documentation at https://docs.vapor.codes/2.0/jwt/overview/#custom-signers.")
        }
        self.jwtSigner = signer
        
        self.serviceAccountEmail = serviceAccountEmail
    }
    
    // MARK: - Public
    
    func authenticateWithGoogle(using client: ClientFactoryProtocol) throws -> Response {
        let googleOAuthJWT = GoogleOAuthJWT(serviceAccountEmail: serviceAccountEmail)
        
        let oAuthParams = try generateOAuthRequestParams(for: googleOAuthJWT)
        
        return try client.post(googleOAuthURL, query: [:], [.contentType: "application/x-www-form-urlencoded"], oAuthParams, through: [])
    }
    
    // MARK: - Private
    
    private func generateOAuthRequestParams(for jwt: GoogleOAuthJWT) throws -> String {
        let jwtString = try jwt.generateJWT(using: jwtSigner)
        return "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwtString)".urlQueryPercentEncoded
    }
}
