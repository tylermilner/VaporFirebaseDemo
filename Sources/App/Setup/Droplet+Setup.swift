@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        
        // Kick off the random number generation
        RandomNumberJob.scheduleRandomNumberJob(using: self)
    }
}
