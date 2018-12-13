import Vapor
import Fluent
import Foundation
import Authentication

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api","users")
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.Public.parameter, use: getHandler)
        usersRoute.delete(User.parameter, use: deleteHandler)
        usersRoute.get("search", use: searchHandler)
        usersRoute.get(User.parameter, "posts", use: getPostsHandler)
        
        //basic auth
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
        
        //bearer auto
        //let tokenAuthMiddleware = User.tokenAuthMiddleware()
        //let guardAuthMiddleware = User.guardAuthMiddleware()
        //let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware,guardAuthMiddleware)

    }

    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        
        //TODO:
        //USER can create an account by default there will be a profile picture provided that can be change later On
        //MUST PROVIDE NAME, PASSWORD AND EMAIL
        //then other info can be provided later on
        
        

        return try req.content.decode(User.self).flatMap(to: User.Public.self) { user in
            
            //assign a profile picture userimage from db
            //let rand = SimpleRandom.random(1...5)
            let pfURL = "https://s3.us-east-2.amazonaws.com/futurpipol/Uploads/Images/ProfilePicture/Default/\(user.Gender)/avatar\(SimpleRandom.random(1...5)).png"
            
            user.ProfilePictureURL = pfURL
            
            //specify the cost higher number means longer hash & verify time
            let hashedpw = try BCrypt.hash(user.Password, cost: 15)
            user.Password = hashedpw
            
            return user.save(on: req).convertToPublic()
        }
    }
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        
        return try req.parameters.next(User.self).convertToPublic()
    }
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.parameters.next(User.self).flatMap(to: HTTPStatus.self) { user in
            user.delete(on: req).transform(to: HTTPStatus.noContent)
        }
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
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }

}
//User.Public
extension User.Public: Parameter {}

