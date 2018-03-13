import Vapor

extension Droplet {
    func setupRoutes() throws {
        
        post("nextRandom") { request in
            do {
                // ...
                
                return Response(status: .methodNotAllowed)
            } catch {
                debugPrint("\(error)")
                return Response(status: .internalServerError, body: "\(error)")
            }
        }
    }
}
