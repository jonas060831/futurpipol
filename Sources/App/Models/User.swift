import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
    
    var id: UUID?
    var Name: String
    var Username: String
    
    var ProfilePictureURL: String
    
    static let createdAtKey: TimestampKey? = \User.createdAt
    static let updatedAtKey: TimestampKey? = \User.updatedAt
    var createdAt: Date?
    var updatedAt: Date?
    
    init(Name: String, Username: String, ProfilePictureURL: String) {
        self.Name = Name
        self.Username = Username
        self.ProfilePictureURL = ProfilePictureURL
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
