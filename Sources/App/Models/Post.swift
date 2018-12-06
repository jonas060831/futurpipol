import Vapor
import FluentPostgreSQL

final class Post: Codable {
    
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
    var Comment: String?
    
    init(Text: String?, Image: String?, Video: String?, Location: String?, Typeofpost: String, creatorID: User.ID){
        
        self.Text = Text
        self.Image = Image
        self.Video = Video
        self.Location = Location
        self.Typeofpost = Typeofpost
        self.creatorID = creatorID
    }
    
    //create a public version of the user
    final class Public: Codable {
        
        var id: UUID?
        var Name: String
        var Username: String
        var ProfilePictureURL: String
        
        init(Name: String, Username: String, ProfilePictureURL: String){
            self.ProfilePictureURL = ProfilePictureURL
            self.Name = Name
            self.Username = Username
        }
    }
    

}

extension Post: PostgreSQLModel {}

extension Post: Content {}

extension Post: Parameter {}

extension Post {
    var creator: Parent<Post, User> {
        return parent(\.creatorID)
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

