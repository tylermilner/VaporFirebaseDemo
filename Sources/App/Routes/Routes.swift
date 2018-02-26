import Vapor
import JWT
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        post("nextRandom") { request in
            do {
                let googleOAuth = GoogleOAuth(jwtSignerName: "googleOAuth", serviceAccountEmail: "firebase-adminsdk-notoj@vaporfirebasedemo.iam.gserviceaccount.com", droplet: self)
                
                let authResponse = try googleOAuth.authenticateWithGoogle(using: self.client)
                
                // Google OAuth - Handle the response from Google
                switch authResponse.status {
                case .ok:
                    guard let accessToken: String = try authResponse.json?.get("access_token") else { return Response(status: .internalServerError, body: "Google auth response did not include an access token") }
                    
                    // Generate a new random number
                    let randomNumber = arc4random_uniform(100) + 1 // Generates a random number between [1-100]
                    
                    // Firebase - Build the Cloud Firestore resource name
                    let firestoreDocument = FirestoreDocument(projectId: "vaporfirebasedemo",
                                                              databaseId: "(default)",
                                                              documentPath: "randomNumbers/theRandomNumber")
                    
                    // Firebase - Create a Firestore document object to represent the random number
                    var documentJSON = JSON()
                    try documentJSON.set("name", "\(firestoreDocument.resourceName)")
                    
                    var numberValueJSON = JSON()
                    try numberValueJSON.set("integerValue", randomNumber)
                    
                    var numberJSON = JSON()
                    try numberJSON.set("number", numberValueJSON)
                    
                    try documentJSON.set("fields", numberJSON)
                    
                    let firestoreBaseURL = "https://firestore.googleapis.com/v1beta1"
                    let firestoreDocumentURL = "\(firestoreBaseURL)/\(firestoreDocument.resourceName)"
                    
                    // Firebase - PATCH onto the resource name to insert or update the document
                    let firestoreResponse = try self.client.patch(firestoreDocumentURL, query: [:], [.authorization: "Bearer \(accessToken)"], documentJSON, through: [])
                    
                    switch firestoreResponse.status {
                    case .ok:
                        return firestoreResponse
                    default:
                        return Response(status: .internalServerError, body: "Error saving document to Firestore: \(firestoreResponse)")
                    }
                default:
                    return Response(status: .internalServerError, body: "Unexpected Google auth response: '\(authResponse)")
                }
            } catch {
                debugPrint("\(error)")
                return Response(status: .internalServerError, body: "\(error)")
            }
        }
    }
}
