import Vapor
import JWT
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        post("nextRandom") { request in
            do {
                // Google OAuth - Create the JWT headers
                var headersJSON = JSON()
                try headersJSON.set("alg", "RS256")
                try headersJSON.set("typ", "JWT")
                debugPrint("Headers: \(headersJSON)")
                
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
                debugPrint("Claims: \(claimsJSON)")
                
                // Google OAuth - Create the JWT signature
                guard let oAuthSigner = self.signers?["googleOAuth"] else { return Response(status: .internalServerError, body: "Unable to locate signer") }
                
                let accessTokenRequestJWT = try JWT(headers: headersJSON, payload: claimsJSON, signer: oAuthSigner)
                let jwtString = try accessTokenRequestJWT.createToken()
                debugPrint("Using JWT: \(jwtString)")
                
                // Google OAuth - Authenticate with Google using the created JWT
                let oAuthParams = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwtString)".urlQueryPercentEncoded
                debugPrint("OAuth Params: \(oAuthParams)")
                
                let authResponse = try self.client.post("https://www.googleapis.com/oauth2/v4/token", query: [:], [.contentType: "application/x-www-form-urlencoded"], oAuthParams, through: [])
                debugPrint("Google auth response: \(authResponse)")
                
                // Google OAuth - Handle the response from Google
                switch authResponse.status {
                case .ok:
                    guard let accessToken: String = try authResponse.json?.get("access_token") else { return Response(status: .internalServerError, body: "Google auth response did not include an access token") }
                    return authResponse
                default:
                    return Response(status: .internalServerError, body: "Unexpected Google auth response: '\(authResponse.status)")
                }
            } catch {
                debugPrint("\(error)")
                return Response(status: .internalServerError, body: "\(error)")
            }
        }
    }
}
