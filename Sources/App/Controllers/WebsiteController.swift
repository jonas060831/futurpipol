import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("login", use: loginHandler)
        router.get("user", use: userHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Post.query(on: req).all().flatMap(to: View.self) { posts in
            let postsData = posts.isEmpty ? nil : posts
            let context = IndexContext(
                title: "Home",
                posts: postsData
            )
            return try req.view().render("index", context)
        }
    }
    
    func userHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { user in
            let userData = user.isEmpty ? nil : user
            let context = UserContext(
                title: "User",
                user: userData
            )
            return try req.view().render("user", context)
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context = LoginContext(title: "Log In")
        return try req.view().render("login", context)
    }
}

struct IndexContext: Encodable {
    let title: String
    let posts: [Post]?
}

struct LoginContext: Encodable {
    let title: String
}
struct UserContext: Encodable {
    let title: String
    let user: [User]?
}
