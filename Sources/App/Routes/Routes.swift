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
                    
                    // Firebase - Create a Firestore document object to represent the random number
                    let documentConfig = FirestoreDocumentConfig(projectId: "vaporfirebasedemo",
                                                                 databaseId: "(default)",
                                                                 documentPath: "randomNumbers/theRandomNumber")
                    let randomNumberDocument = NumberDocument(value: Int(randomNumber), documentConfig: documentConfig)
                    let documentJSON = try randomNumberDocument.makeJSON()
                    
                    // Firebase - PATCH onto the resource name to insert or update the document
                    let firestoreBaseURL = "https://firestore.googleapis.com/v1beta1"
                    let firestoreDocumentURL = "\(firestoreBaseURL)/\(randomNumberDocument.resourceName)"
                    
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
