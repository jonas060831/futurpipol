import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let usersController = UsersController()
    try router.register(collection: usersController)
 
    let postsController = PostsController()
    try router.register(collection: postsController)
    
    let commentsController = CommentsController()
    try router.register(collection: commentsController)
    
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
}
