import Vapor
import Leaf
import Foundation

struct WebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.post(use: createPostHandler)
        router.get("login", use: loginHandler)
        router.get("profile", use: profileHandler)
        router.get("settings", use: settingsHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            
            return Post.query(on: req).sort(\.id, .descending).all().flatMap(to: View.self) { posts in
                let postsData = posts.isEmpty ? nil : posts
                let userData = users.isEmpty ? nil : users
                let context = IndexContext(
                    title: "Home",
                    posts: postsData,
                    users: userData
                )
                return try req.view().render("index", context)
            }
        }
    }
    func createPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(PostData.self).flatMap(to: Response.self) { data in
            let post = Post(Text: data.Text, Image: data.Image, Video: data.Video, Location: data.Location, Typeofpost: data.Typeofpost, creatorID: data.creator)
            return post.save(on: req).map(to: Response.self) { post in

                return req.redirect(to: "/")
            }
        }
    }
    func profileHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            let userData = users.isEmpty ? nil : users
            let context = ProfileContext(
                title: "Profile",
                users: userData
            )
            return try req.view().render("profile", context)
        }
    }
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context = LoginContext(title: "Log In")
        return try req.view().render("login", context)
    }
    func settingsHandler(_ req: Request) throws -> Future<View> {
        let context = settingsContext(title: "Settings")
        return try req.view().render("settings", context)
    }
}

struct IndexContext: Encodable {
    let title: String
    let posts: [Post]?
    let users: [User]?
}
struct ProfileContext: Encodable {
    let title: String
    let users: [User]?
}
struct LoginContext: Encodable {
    let title: String
}
struct settingsContext: Encodable {
    let title: String
}
struct PostData: Content {
    static var defaultMediaType =  MediaType.urlEncodedForm
    let Text: String?
    let Image: String?
    let Video: String?
    let Location: String?
    let Typeofpost: String
    let creator: UUID
}
