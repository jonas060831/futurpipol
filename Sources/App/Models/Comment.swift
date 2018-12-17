import Vapor
import FluentPostgreSQL

final class Comment: Codable {

    var id: Int?
    let Text: String?
    var postID: Post.ID
    var creatorInfo: User.Public?
    
    static let createdAtKey: TimestampKey? = \Comment.createdAt
    static let updatedAtKey: TimestampKey? = \Comment.updatedAt

    var createdAt: Date?
    var updatedAt: Date?

    //text creatorInfo postID
    init(Text: String?, postID: Post.ID){
        self.Text = Text
        self.postID = postID
    }
}

extension Comment: PostgreSQLModel {}

extension Comment: Migration {}

extension Comment: Content {}

extension Comment: Parameter {}


//
//import FluentPostgreSQL
//import Vapor
//
//struct Comment: PostgreSQLModel, Migration, Content {
//    var id: Int?
//    let Text: String
//    var postID: Post.ID
//    var creatorInfo: User.Public?
//
//
//
//
//    init(id: Int? = nil, Text: String, postID: Post.ID) {
//        self.id = id
//        self.Text = Text
//        self.postID = postID
//    }
//
//    static func prepare(on conn: PostgreSQLDatabase.Connection) -> Future<Void> {
//        return PostgreSQLDatabase.create(Comment.self, on: conn) { builder in
//            builder.field(for: \.id, isIdentifier: true)
//            builder.field(for: \.Text)
//            builder.field(for: \.postID)
//            builder.reference(from: \.postID, to: \Post.id, onUpdate: .cascade, onDelete: .cascade)
//        }
//    }
//}
