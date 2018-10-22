import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(use: indexHandler)
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
}

struct IndexContext: Encodable {
    let title: String
    let posts: [Post]?
}
