import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
    
    var id: UUID?
    var Name: String
    var Username: String
    
    init(Name: String, Username: String) {
        self.Name = Name
        self.Username = Username
    }
}


extension User: PostgreSQLUUIDModel {}

extension User: Content {}

extension User: Migration {}

extension User: Parameter {}

extension User {
    var posts: Children<User, Post> {
        return children(\.userID)
    }
}
