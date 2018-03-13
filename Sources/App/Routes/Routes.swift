import Vapor
import Foundation
import JWT

extension Droplet {
    func setupRoutes() throws {
        
        post("nextRandom") { request in
            do {
                // Google OAuth - Create the JWT headers
                var headersJSON = JSON()
                try headersJSON.set("alg", "RS256")
                try headersJSON.set("typ", "JWT")
                
                // Google OAuth - Create the JWT claims
                let issuedTime = Date()
                let timeToLive: TimeInterval = 60 * 30 // 30 minutes, max is 60
                let expirationTime = issuedTime.addingTimeInterval(timeToLive)
                
                var claimsJSON = JSON()
                try claimsJSON.set("iss", "firebase-adminsdk-notoj@vaporfirebasedemo.iam.gserviceaccount.com") // the value of "client_email" in the service account JSON
                try claimsJSON.set("scope", "https://www.googleapis.com/auth/datastore")
                try claimsJSON.set("aud", "https://www.googleapis.com/oauth2/v4/token")
                try claimsJSON.set("exp", Int(expirationTime.timeIntervalSince1970))
                try claimsJSON.set("iat", Int(issuedTime.timeIntervalSince1970))
                
                // Google OAuth - Create the JWT signature
                guard let oAuthSigner = self.signers?["googleOAuth"] else { return Response(status: .internalServerError, body: "Unable to locate signer") }
                
                let accessTokenRequestJWT = try JWT(headers: headersJSON, payload: claimsJSON, signer: oAuthSigner)
                let jwtString = try accessTokenRequestJWT.createToken() // the final encoded JWT
                
                // ...
                
                return Response(status: .methodNotAllowed)
            } catch {
                debugPrint("\(error)")
                return Response(status: .internalServerError, body: "\(error)")
            }
        }
    }
}
