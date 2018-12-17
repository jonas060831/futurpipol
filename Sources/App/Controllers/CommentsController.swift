import Vapor
import Fluent
import Authentication

struct CommentsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let commentsRoutes = router.grouped("api"  , "comments")
        commentsRoutes.get(use: getAllHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        
        let tokenAuthGroup = commentsRoutes.grouped(tokenAuthMiddleware,guardAuthMiddleware)
        tokenAuthGroup.post(use: createHandler)
        
    }
    
    func createHandler(_ req: Request) throws -> Future<Comment> {
        
        return try req.content.decode(CommentCreateData.self).flatMap(to: Comment.self) { commentCreateData in
            
            //get the authenticated user
            let user = try req.requireAuthenticated(User.self)
            
            let comment =  Comment(Text: commentCreateData.Text!, postID: commentCreateData.postID)
            
            //computed authenticated user autofill
            let CI = User.Public(id: user.id, Name: user.Name, Username: user.Username, ProfilePictureURL: user.ProfilePictureURL!)
    
            comment.creatorInfo = CI
            
            return comment.save(on: req)
        }
    }
    func getAllHandler(_ req: Request) -> Future<[Comment]> {
        
        return Comment.query(on: req).all()
    }
}

struct CommentCreateData: Content {
    let Text: String?
    let postID: Post.ID
}
