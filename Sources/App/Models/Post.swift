import Vapor
import FluentPostgreSQL

final class Post: Codable {
    
    var id: Int?
    var Text: String?
    var Image: String?
    var Video: String?
    var Location: String?
    var Typeofpost: String
    
    var userID: User.ID
    
    static let createdAtKey: TimestampKey? = \Post.createdAt
    static let updatedAtKey: TimestampKey? = \Post.updatedAt
    
    var createdAt: Date?
    var updatedAt: Date?
    
    var Star: Int?
    var Comment: String?
    
    init(Text: String?, Image: String?, Video: String?, Location: String?, Typeofpost: String, userID: User.ID){
        
        self.Text = Text
        self.Image = Image
        self.Video = Video
        self.Location = Location
        self.Typeofpost = Typeofpost
        self.userID = userID
    }
}

extension Post: PostgreSQLModel {}

extension Post: Content {}

extension Post: Parameter {}

extension Post {
    var user: Parent<Post, User> {
        return parent(\.userID)
    }
}

//Foreign Key Constraints
extension Post: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

