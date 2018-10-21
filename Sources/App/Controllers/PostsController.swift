import Vapor
import Fluent


//create a post
//get all post
//get a specfic post
//delete a post
//search a post
//get parent

struct PostsController: RouteCollection {
    func boot(router: Router) throws {
        
        let postsRoutes = router.grouped("api", "posts")
        //postsRoutes.post(use: createHandler) //1
        postsRoutes.post(Post.self, use: createHandler)
        postsRoutes.get(use: getAllHandler) //2
        postsRoutes.get(Post.parameter, use: getHandler) //3
        postsRoutes.delete(Post.parameter, use: deleteHandler) //4
        postsRoutes.get("search", use: searchHandler) //5
        postsRoutes.get(Post.parameter, "user", use: getUserHandler) //6
    }
    
    //1
//   func createHandler(_ req: Request) throws -> Future<Post> {
//        return try req.content.decode(Post.self).flatMap(to: Post.self) { post in
//            return post.save(on: req)
//        }
//   }
    //As mentioned in Chapter 2, “Hello Vapor!”, Vapor provides helper functions for PUT, POST and PATCH routes for decoding incoming data. This helps remove a layer of nesting. To use this helper function, open AcronymsController.swift and replace createHandler(_:) with the following:
    func createHandler(_ req: Request, post: Post) throws -> Future<Post> {
        
            return post.save(on: req)
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
    //6
    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Post.self).flatMap(to: User.self) { post in
            post.user.get(on: req)
        }
    }
}


