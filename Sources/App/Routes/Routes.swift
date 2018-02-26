import Vapor
import JWT
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        post("nextRandom") { request in
            return RandomNumberJob.publishNewRandomNumber(using: self)
        }
    }
}
