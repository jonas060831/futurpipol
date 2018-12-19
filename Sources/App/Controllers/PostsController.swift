import Vapor
import Fluent
import Authentication
import FluentPostgreSQL

//create a post
//get all post
//get a specfic post
//delete a post
//search a post
//get parent

struct PostsController: RouteCollection {
    func boot(router: Router) throws {
        
        let postsRoutes = router.grouped("api"  , "posts")
        //postsRoutes.post(use: createHandler) //1
        //postsRoutes.post(Post.self, use: createHandler)
        postsRoutes.get(use: getAllHandler) //2
        postsRoutes.get(Post.parameter, use: getHandler) //3
        //postsRoutes.delete(Post.parameter, use: deleteHandler) //4
        //postsRoutes.put(Post.parameter, use: updateHandler)//5
        postsRoutes.get("search", use: searchHandler) //6
        postsRoutes.get(Post.parameter, "user", use: getUserHandler) //7
        postsRoutes.get(Post.parameter, "comments", use: getCommentsHandler)
        postsRoutes.get("combine", use: getAllPostandCommentsHandler)
        
        //basic authentication
        //let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        //let guardAuthMiddleware = User.guardAuthMiddleware()
        //let protected = postsRoutes.grouped(basicAuthMiddleware, guardAuthMiddleware)
        
        //using token on every http req
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        
        let tokenAuthGroup = postsRoutes.grouped(tokenAuthMiddleware,guardAuthMiddleware)
        tokenAuthGroup.post(use: createHandler)
        tokenAuthGroup.delete(Post.parameter, use: deleteHandler)
        tokenAuthGroup.put(Post.parameter ,use: updateHandler)
    }

    func createHandler(_ req: Request) throws -> Future<Post> {
        
        return try req.content.decode(PostCreateData.self).flatMap(to: Post.self) { postCreateData in
            
            //get the authenticated user
            let user = try req.requireAuthenticated(User.self)
            
            let post = try Post(Text: postCreateData.Text, Image: postCreateData.Image, Video: postCreateData.Video, Location: postCreateData.Location, Typeofpost: postCreateData.Typeofpost, creatorID: user.requireID())

           //computed authenticated user
            let creatorInfo = User.Public(id: user.id, Name: user.Name, Username: user.Username, ProfilePictureURL: user.ProfilePictureURL!)
            post.creatorInfo = creatorInfo
            return post.save(on: req)
        }
    }
    //2
    func getAllHandler(_ req: Request) -> Future<[Post]>  {
        
        return Post.query(on: req).all()
    }
    
    //3
    func getHandler(_ req: Request) throws -> Future<Post> {
        
        return try req.parameters.next(Post.self)
    }
    
    //4
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Post.self).flatMap(to: HTTPStatus.self) { post in
            post.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    //5
    func searchHandler(_ req: Request) throws -> Future<[Post]> {
        
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return  Post.query(on: req).filter(\.Text == searchTerm).all()
    }
    func updateHandler(_ req: Request) throws -> Future<Post>{
        return try flatMap(to: Post.self, req.parameters.next(Post.self), req.content.decode(PostCreateData.self)) { post, postcreateData in
            
            //updating the text and the type of post
            post.Text = postcreateData.Text
            post.Image = postcreateData.Image
            post.Video = postcreateData.Video
            
            //can never update what type of post they sent opt 1 is to delete the post
            //post.Typeofpost = postcreateData.Typeofpost
            
            //get the authenticated user
            let user = try req.requireAuthenticated(User.self)
            
            post.creatorID = try user.requireID()
            
            return post.save(on: req)
        }
    }
    
    //6
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Post.self).flatMap(to: User.Public.self) { post in
            post.creator.get(on: req).convertToPublic()
        }
    }
    //7 parent to child query
    func getCommentsHandler(_ req: Request) throws -> Future<[Comment]> {
        return try req.parameters.next(Post.self).flatMap(to: [Comment].self) { post in
            try post.comments.query(on: req).all()
        }
    }
    //8 combine post and comments query
    func getAllPostandCommentsHandler(_ req: Request) -> Future<[PostWithComments]>  {
        return Post.query(on: req).all().flatMap { fetchChildren(of: $0, via: \Comment.postID, on: req) { post, comments in
            
            PostWithComments(id: post.id, Post: post, Comments: comments)
            }
        }
        
    }
}


struct PostWithComments: Content {
    let id: Int?
    let Post: Post
    let Comments: [Comment]
}

struct PostCreateData: Content {
    let Text: String?
    let Image: String?
    let Video: String?
    let Location: String?
    let Typeofpost: String
}
