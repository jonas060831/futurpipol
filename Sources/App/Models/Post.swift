import Vapor
import FluentPostgreSQL

final class Post: Codable {
    
    var id: Int?
    var Text: String?
    var Image: String?
    var Video: String?
    var Location: String?
    var Typeofpost: String
    
    
    var Star: Int?
    var Comment: String?
    
    
    //Timestampable
//    var createdAtKey: Date?
//    var updatedAtKey: Date?
    
    
    init(Text: String?, Image: String?, Video: String?, Location: String?, Typeofpost: String){
        
        self.Text = Text
        self.Image = Image
        self.Video = Video
        self.Location = Location
        self.Typeofpost = Typeofpost

    }
}

extension Post: PostgreSQLModel {}

extension Post: Migration {}

extension Post: Content {}

