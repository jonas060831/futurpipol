import Vapor
import FluentPostgreSQL

final class Post: Decodable {
    
    var id: Int?
    var Text: String?
    var Image: String?
    var Video: String?
    var Location: String?
    var Typeofpost: String
    var creatorInfo: User.Public?
    var creatorID: User.ID
    
    static let createdAtKey: TimestampKey? = \Post.createdAt
    static let updatedAtKey: TimestampKey? = \Post.updatedAt
    
    var createdAt: Date?
    var updatedAt: Date?
    
    var Star: Int?
    
    init(Text: String?, Image: String?, Video: String?, Location: String?, Typeofpost: String, creatorID: User.ID){
        
        self.Text = Text
        self.Image = Image
        self.Video = Video
        self.Location = Location
        self.Typeofpost = Typeofpost
        self.creatorID = creatorID
    }
}

extension Post: PostgreSQLModel {}

extension Post: Content {}

extension Post: Parameter {}


//parent to child rel
extension Post {
    var creator: Parent<Post, User> {
        return parent(\.creatorID)
    }
}

//parent to child rel
extension Post {
    var comments: Children<Post, Comment> {
        return children(\.postID)
    }
}

//Foreign Key Constraints
extension Post: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.creatorID, to: \User.id)
        }
    }
}
