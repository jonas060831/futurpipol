import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    
    var id: UUID?
    var Name: String
    var Username: String
    var Password: String
    var Gender: String
    var ProfilePictureURL: String?
    
    
    var Posts: Post?
    
    static let createdAtKey: TimestampKey? = \User.createdAt
    static let updatedAtKey: TimestampKey? = \User.updatedAt
    var createdAt: Date?
    var updatedAt: Date?
    
    
    init(Name: String, Username: String, Password: String, Gender: String,ProfilePictureURL: String) {
        self.Name = Name
        self.Username = Username
        self.Password = Password
        self.Gender = Gender
        self.ProfilePictureURL = ProfilePictureURL
    }
    
    //create a public version of the user
    final class Public: Codable {
        
        var id: UUID?
        var Name: String
        var Username: String
        var ProfilePictureURL: String
        
        init(id: UUID?, Name: String, Username: String, ProfilePictureURL: String){
            self.id = id
            self.Name = Name
            self.Username = Username
            self.ProfilePictureURL = ProfilePictureURL
        }
    }
}


extension User: PostgreSQLUUIDModel {}

extension User: Content {}

//Unique username
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection){ builder in
            try addProperties(to: builder)
            builder.unique(on: \.Username)
        }
    }
}

extension User: Parameter {}

//Public User
extension User.Public: PostgreSQLUUIDModel {
    static let entity = User.entity
}
extension User.Public: Content {}

//retrieving post from the user parent to child rel
extension User {
    var posts: Children<User, Post> {
        return children(\.creatorID)
    }
}

//Basic Authentication
extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.Username
    static let passwordKey: PasswordKey = \User.Password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, Name: Name, Username: Username, ProfilePictureURL: ProfilePictureURL!)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}
