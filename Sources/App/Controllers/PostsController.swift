import Vapor
import Fluent

struct PostsController: RouteCollection {
    func boot(router: Router) throws {
        
        let postsRoutes = router.grouped("api", "posts")
        postsRoutes.post(use: createHandler)
        postsRoutes.get(use: getAllHandler)
    }
    
    
    func createHandler(_ req: Request) throws -> Future<Post> {
        return try req.content.decode(Post.self).flatMap(to: Post.self) { post in
            return post.save(on: req)
        }
    }
    func getAllHandler(_ req: Request) -> Future<[Post]> {
        return Post.query(on: req).all()
    }
}


