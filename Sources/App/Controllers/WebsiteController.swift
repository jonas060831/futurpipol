import Vapor
import Leaf
import Foundation
import Authentication

struct WebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        

        let authSessionsRoutes = router.grouped(User.authSessionsMiddleware())
        
        
        //redirect UNAUTHENTICATED users to login page
        let protectedRoutes = authSessionsRoutes.grouped(RedirectMiddleware<User>.login())
        protectedRoutes.get(use: indexHandler)
        protectedRoutes.post(use: createPostHandler)
        protectedRoutes.get("profile", use: profileHandler)
        protectedRoutes.get("settings", use: settingsHandler)
        
        //redirect AUTHENTICATED users to home page when trying to visit login page
        let protectedRoutes2 = authSessionsRoutes.grouped(InverseRedirectMiddleware<User>.home())
        protectedRoutes2.get("login", use: loginHandler)
        protectedRoutes2.post(LoginPostData.self, at: "login", use: loginPostHandler)
        
        //logout the user
        router.post("logout", use: logoutHandler)
        
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        print(SimpleRandom.random(1...5))
            
            return Post.query(on: req).sort(\.id, .descending).all().flatMap(to: View.self) { posts in
                
                //get the authenticated user
                let user = try req.requireAuthenticated(User.self)
                let postsData = posts.isEmpty ? nil : posts
                let userData =  user
                let context = IndexContext(
                    title: "futurpipol",
                    posts: postsData,
                    user: userData
                )
                return try req.view().render("index", context)
            }
    }
    func createPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(PostData.self).flatMap(to: Response.self) { data in
            
            //get the authenticated user
            let user = try req.requireAuthenticated(User.self)
            
            let post = Post(Text: data.Text, Image: data.Image, Video: data.Video, Location: data.Location, Typeofpost: data.Typeofpost, creatorID: try user.requireID())
            
            //computed authenticated user autofill
            let creatorInfo = User.Public(id: user.id, Name: user.Name, Username: user.Username, ProfilePictureURL: user.ProfilePictureURL!)
            
            post.creatorInfo = creatorInfo
            
            return post.save(on: req).map(to: Response.self) { post in

                return req.redirect(to: "/")
            }
        }
    }
    func profileHandler(_ req: Request) throws -> Future<View> {
        
            let userData = try req.requireAuthenticated(User.self)
            let context = ProfileContext(
                title: "Profile",
                user: userData
            )
            return try req.view().render("profile", context)
        
    }
    func settingsHandler(_ req: Request) throws -> Future<View> {
        let context = settingsContext(title: "Settings")
        return try req.view().render("settings", context)
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context : LoginContext
        
        if req.query[Bool.self, at: "Error"] != nil {
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        return try req.view().render("login", context)
    }
    func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
        
        return User.authenticate(username: userData.Username, password: userData.Password, using: BCryptDigest(), on: req).map(to: Response.self) { user in
            
            guard let user = user else {
                //must match with at: in loginHandler
                return req.redirect(to: "/login?Error")
            }
            try req.authenticateSession(user)
            return req.redirect(to: "/")
        }
    }
    func logoutHandler(_ req: Request) throws -> Response {
        
        //destroy the session
        try req.unauthenticateSession(User.self)
        try req.releaseCachedConnections()
        try req.destroySession()
        return req.redirect(to: "/login")
    }
}

struct IndexContext: Encodable {
    let title: String
    let posts: [Post]?
    let user: User
}
struct PostData: Content {
    static var defaultMediaType =  MediaType.urlEncodedForm
    let Text: String?
    let Image: String?
    let Video: String?
    let Location: String?
    let Typeofpost: String
    let creatorID: UUID
}

struct ProfileContext: Encodable {
    let title: String
    let user: User
}

struct settingsContext: Encodable {
    let title: String
}


struct LoginContext: Encodable {
    let title = "Log In"
    let loginError: Bool
    
    init(loginError: Bool = false){
        self.loginError = loginError
    }
}
struct LoginPostData: Content {
    static var defaultMediaType =  MediaType.urlEncodedForm
    let Username: String
    let Password: String
}
