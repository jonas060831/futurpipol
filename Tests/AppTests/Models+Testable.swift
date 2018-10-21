@testable import App
import FluentPostgreSQL
extension User {
    static func create(
        name: String = "Luke",
        username: String = "lukes",
        on connection: PostgreSQLConnection
        ) throws -> User {
        let user = User(Name: name, Username: username)
        return try user.save(on: connection).wait()
    }

}
extension Post {
    static func create(
        Typeofpost: String = "Public",
        Text: String = "Hello World!",
        user: User? = nil,
        on connection: PostgreSQLConnection ) throws -> Post {
        var postsUser = user
        
        if postsUser == nil {
            postsUser = try User.create(on: connection)
        }
        let post = Post(
            Text: Text,
            Image: "",
            Video: "",
            Location: "",
            Typeofpost: "Public",
            userID: postsUser!.id!
        )
        return try post.save(on: connection).wait()
    }
}

