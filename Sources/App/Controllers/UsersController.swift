import Vapor
import Fluent

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api","users")
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
        usersRoute.get("search", use: searchHandler)
        usersRoute.get(User.parameter, "posts", use: getPostsHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User> {
        return user.save(on: req)
    }
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    func searchHandler(_ req: Request) throws -> Future<[User]> {
        
        guard let searchTerm = req.query[String.self, at: "Name"] else {
            throw Abort(.badRequest)
        }
        return  User.query(on: req).filter(\.Name == searchTerm).all()
    }
    func getPostsHandler(_ req: Request) throws -> Future<[Post]> {
        
        return try req.parameters.next(User.self).flatMap(to: [Post].self) { user in
            try user.posts.query(on: req).all()
        }
    }
}
