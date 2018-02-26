import Vapor
import JWT
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        post("nextRandom") { request in
            do {
                // Setup - Make sure a Signer exists so that we can use it to generate the Google OAuth JWT
                let signerName = "googleOAuth"
                guard let oAuthSigner = self.signers?[signerName] else { return Response(status: .internalServerError, body: "Unable to locate JWT signer. Make sure your 'Config/jwt.json' file contains a 'signers' object with a '\(signerName)' key. See Vapor documentation at https://docs.vapor.codes/2.0/jwt/overview/#custom-signers.") }
                
                // Google OAuth - Create the JWT from the service account email and signer
                let googleOAuthJWT = GoogleOAuthJWT(serviceAccountEmail: "firebase-adminsdk-notoj@vaporfirebasedemo.iam.gserviceaccount.com")
                let jwtString = try googleOAuthJWT.generateJWT(for: oAuthSigner, in: self)
                
                // Google OAuth - Authenticate with Google using the created JWT
                let oAuthParams = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwtString)".urlQueryPercentEncoded
                debugPrint("OAuth Params: \(oAuthParams)")
                
                let authResponse = try self.client.post("https://www.googleapis.com/oauth2/v4/token", query: [:], [.contentType: "application/x-www-form-urlencoded"], oAuthParams, through: [])
                debugPrint("Google auth response: \(authResponse)")
                
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
