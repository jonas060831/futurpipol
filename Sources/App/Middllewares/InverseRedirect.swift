import Vapor
import Authentication

/// Basic middleware to redirect authenticated users to /
public struct InverseRedirectMiddleware<A>: Middleware where A: Authenticatable {
    
    /// The path to redirect to
    let path: String
    
    /// Initialise the `InverseRedirectMiddleware`
    ///
    /// - parameter:
    ///    - path: The path to redirect to if the request is authenticated
    public init(path: String) {
        self.path = path
    }
    
    /// See Middleware.respond
    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        if try !request.isAuthenticated(A.self) {
            
            return try next.respond(to: request)
        }
        return Future.map(on: request) {
            request.redirect(to: self.path)
        }
    }
    /// Use this middleware to redirect authenticated users away from login page
    /// protected content to a home page page
    public static func home(path: String = "/") -> InverseRedirectMiddleware {
        return InverseRedirectMiddleware(path: path)
    }
}






