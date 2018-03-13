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
                
                // Google OAuth - Authenticate with Google using the created JWT
                let oAuthParams = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwtString)".urlQueryPercentEncoded
                
                let authResponse = try self.client.post("https://www.googleapis.com/oauth2/v4/token", query: [:], [.contentType: "application/x-www-form-urlencoded"], oAuthParams, through: [])
                
                // Google OAuth - Handle the response from Google
                switch authResponse.status {
                case .ok:
                    guard let accessToken: String = try authResponse.json?.get("access_token") else { return Response(status: .internalServerError, body: "Google auth response did not include an access token") }
                    
                    // Generate a new random number
                    let randomNumber = arc4random_uniform(100) + 1 // Generates a random number between [1-100]
                    
                    // Firebase - Build the Cloud Firestore resource name
                    let projectId = "vaporfirebasedemo"
                    let databaseId = "(default)"
                    let documentPath = "randomNumbers/theRandomNumber"
                    let resourceName = "projects/\(projectId)/databases/\(databaseId)/documents/\(documentPath)"
                    
                    // Firebase - Create a Firestore document object to represent the random number
                    var documentJSON = JSON()
                    try documentJSON.set("name", "\(resourceName)") // The Firestore resource name of the document, for example projects/{projectId}/databases/{databaseId}/documents/{document_path}
                    
                    var numberValueJSON = JSON()
                    try numberValueJSON.set("integerValue", randomNumber)
                    
                    var numberJSON = JSON()
                    try numberJSON.set("number", numberValueJSON)
                    
                    try documentJSON.set("fields", numberJSON)
                    
                    let firestoreBaseURL = "https://firestore.googleapis.com/v1beta1"
                    let firestoreDocumentURL = "\(firestoreBaseURL)/\(resourceName)"
                    
                    // Firebase - PATCH onto the resource name to insert or update the document
                    let firestoreResponse = try self.client.patch(firestoreDocumentURL, query: [:], [.authorization: "Bearer \(accessToken)"], documentJSON, through: [])
                    
                    switch firestoreResponse.status {
                    case .ok:
                        return firestoreResponse
                    default:
                        return Response(status: .internalServerError, body: "Error saving document to Firestore: \(firestoreResponse)")
                    }
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
