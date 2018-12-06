import Vapor
import Fluent
import Authentication

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
        
        
        //protecting the iOS App
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = postsRoutes.grouped(tokenAuthMiddleware)
        tokenAuthGroup.post(use: createHandler)
        tokenAuthGroup.delete(use: deleteHandler)
        tokenAuthGroup.put(use: updateHandler)
    }
    
    //1
//   func createHandler(_ req: Request) throws -> Future<Post> {
//        return try req.content.decode(Post.self).flatMap(to: Post.self) { post in
//            return post.save(on: req)
//        }
//   }
    func createHandler(_ req: Request) throws -> Future<Post> {
        
        return try req.content.decode(PostCreateData.self).flatMap(to: Post.self) { postCreateData in
            
            //get the authenticated user
            let user = try req.requireAuthenticated(User.self)
            
            let post = try Post(Text: postCreateData.Text, Image: postCreateData.Image, Video: postCreateData.Video, Location: postCreateData.Location, Typeofpost: postCreateData.Typeofpost, creatorID: user.requireID() )
            
            //values needed to be unwrapped
            let creatorInfo = User.Public(Name: (user.Name ) , Username: (user.Username ) , ProfilePictureURL: (user.ProfilePictureURL!))
            post.creatorInfo = creatorInfo
            return post.save(on: req)
        }
    }
    
    //2
    func getAllHandler(_ req: Request) -> Future<[Post]> {
        
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
            post.Typeofpost = postcreateData.Typeofpost
            post.creatorID = try req.requireAuthenticated(User.self).requireID()
            return post.save(on: req)
        }
    }
    //6
    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Post.self).flatMap(to: User.self) { post in
            post.creator.get(on: req)
        }
    }
}
struct PostContent: Encodable {

    let posts: [Post]?

    let users: [User.Public]?
}

struct PostCreateData: Content {
   // Text: String?, Image: String?, Video: String?, Location: String?, Typeofpost: String, creatorID: User.ID
    let Text: String?
    let Image: String?
    let Video: String?
    let Location: String?
    let Typeofpost: String
}
