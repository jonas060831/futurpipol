import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
 
    let postsController = PostsController()
    try router.register(collection: postsController)
    
    let usersController = UsersController()
    try router.register(collection: usersController)
}
