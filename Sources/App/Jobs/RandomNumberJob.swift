//
//  RandomNumberJob.swift
//  App
//
//  Created by Tyler Milner on 2/25/18.
//

import Foundation
import Dispatch

class RandomNumberJob {
    
    // MARK: - Properties
    
    private static let randomNumberInterval: TimeInterval = 60 // Next update in 60 seconds
    private static let timer = DispatchSource.makeTimerSource()
    
    // MARK: - Public
    
    static func scheduleRandomNumberJob(using droplet: Droplet) {
        timer.setEventHandler {
            publishNewRandomNumber(using: droplet)
        }
        
        // Fire the timer immediately and then every X seconds, +/- 1 second leeway
        timer.schedule(deadline: .now(), repeating: randomNumberInterval, leeway: .seconds(1))
        timer.resume()
    }
    
    @discardableResult
    static func publishNewRandomNumber(using droplet: Droplet) -> Response {
        guard let googleServiceAccountEmail = droplet.config["app", "googleServiceAccountEmail"]?.string else {
            fatalError("Unable to locate Google Service Account email. Make sure it's setup in your 'Config/app.json' configuration file.")
        }
        guard let firebaseProjectId = droplet.config["app", "firebaseProjectId"]?.string else {
            fatalError("Unable to locate Firebase project ID. Make sure it's setup in your 'Config/app.json' configuration file.")
        }
        
        do {
            let googleOAuth = GoogleOAuth(jwtSignerName: "googleOAuth", serviceAccountEmail: googleServiceAccountEmail, droplet: droplet)
            
            let authResponse = try googleOAuth.authenticateWithGoogle(using: droplet.client)
            
            // Google OAuth - Handle the response from Google
            switch authResponse.status {
            case .ok:
                guard let accessToken: String = try authResponse.json?.get("access_token") else { return Response(status: .internalServerError, body: "Google auth response did not include an access token") }
                
                // Generate a new random number and date for the next one to be generated
                let randomNumber = Int(arc4random_uniform(100) + 1) // Generates a random number between [1-100]
                let nextUpdate = Date().addingTimeInterval(randomNumberInterval)
                
                let firestore = Firestore(accessToken: accessToken)
                
                // Firebase - Create a Firestore document object to represent the random number
                let randomNumberDocument = NumberDocument(value: randomNumber,
                                                          nextUpdate: nextUpdate,
                                                          projectId: firebaseProjectId,
                                                          databaseId: "(default)",
                                                          documentPath: "randomNumbers/theRandomNumber")
                
                // Firebase - PATCH onto the resource name to insert or update the document
                let firestoreResponse = try firestore.updateDocument(randomNumberDocument, using: droplet.client)
                
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
