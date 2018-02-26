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
    
    func generateOAuthJWT() throws -> String {
        let googleOAuthJWT = GoogleOAuthJWT(serviceAccountEmail: serviceAccountEmail)
        return try googleOAuthJWT.generateJWT(using: jwtSigner)
    }
}
