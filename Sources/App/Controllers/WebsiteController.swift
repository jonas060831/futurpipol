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
        protectedRoutes.post("createComment", use: createCommentHandler)
        //other user
        protectedRoutes.get(User.parameter, use: otherUserPage)
        
        
        //redirect AUTHENTICATED users to home page when trying to visit login page
        let protectedRoutes2 = authSessionsRoutes.grouped(InverseRedirectMiddleware<User>.home())
        protectedRoutes2.get("login", use: loginHandler)
        protectedRoutes2.post(LoginPostData.self, at: "login", use: loginPostHandler)
        
        //sign up
        router.get("signup", use: signupHandler)
        router.post(SignupPostData.self, at: "signup", use: signupPostHandler)
        
        
        //logout the user
        router.post("logout", use: logoutHandler)
        
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        
        return User.query(on: req).sort(\.Name, .ascending).all().flatMap(to: View.self) { allusers in
            
            return Post.query(on: req).sort(\.id, .descending).all().flatMap(to: View.self) { posts in
                
                return Comment.query(on: req).sort(\.id, .ascending).all().flatMap(to: View.self) { comments in
                    //get the authenticated user
                    let user = try req.requireAuthenticated(User.self)
                    let posts = posts.isEmpty ? nil : posts
                    let showCookieMessage = req.http.cookies["cookies-accepted"] == nil
                    
                    
                    
                    let context = IndexContext(
                        title: "futurpipol",
                        posts: posts,
                        comments: comments,
                        user: user,
                        allusers:  allusers,
                        commentCount: comments.count,
                        showCookieMessage: showCookieMessage
                    )
                    return try req.view().render("index", context)
                }
            }
            
            
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
    
    func createCommentHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(PostCommentData.self).flatMap(to: Response.self) { data in
            
            //get the authenticated user
            let user = try req.requireAuthenticated(User.self)
            
            let comment = Comment(Text: data.Text, postID: data.postID)
            
            //computed authenticated user autofill
            let creatorInfo = User.Public(id: user.id, Name: user.Name, Username: user.Username, ProfilePictureURL: user.ProfilePictureURL!)
            
            comment.creatorInfo = creatorInfo
            
            return comment.save(on: req).map(to: Response.self) { comment in
                
                return req.redirect(to: "/")
            }
        }
    }
    func profileHandler(_ req: Request) throws -> Future<View> {
        
        let userData = try req.requireAuthenticated(User.self)
        
        return Post.query(on: req).sort(\.id, .descending).all().flatMap(to: View.self) { posts in
            
            return Comment.query(on: req).sort(\.id, .ascending).all().flatMap(to: View.self) { comments in
                let context = ProfileContext(
                    title: "Profile",
                    user: userData,
                    posts: posts,
                    comments: comments,
                    commentCount: comments.count
                )
                return try req.view().render("profile", context)
            }
        }
    }
    func settingsHandler(_ req: Request) throws -> Future<View> {
        //get the authenticated user
        let user = try req.requireAuthenticated(User.self)
        let context = settingsContext(
            title: "Settings",
            user: user
        )
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
    func signupHandler(_ req: Request) throws -> Future<View> {
        let context = SignupContext()
        
        return try req.view().render("signup", context)
    }
    
    func otherUserPage(_ req: Request) throws -> Future<View> {
        
        //get the authenticated user
        let user = try req.requireAuthenticated(User.self)
            return try req.parameters.next(User.self).flatMap(to: View.self) { otheruser in
                
              return Post.query(on: req).sort(\.id, .descending).all().flatMap(to: View.self) { posts in
                
                return Comment.query(on: req).sort(\.id, .ascending).all().flatMap(to: View.self) { comments in
                
                    let context = otherUsersPageContext(
                        title: "\(otheruser.Name)",
                        otheruser: otheruser, user : user,
                        posts: posts,
                        comments: comments,
                        commentCount: comments.count
                    )
                 
                    return try req.view().render("other-user", context)
                    
                    }
                }
            }
    }

    
    
    
    //TODO: Sign up post handler
    func signupPostHandler(_ req: Request, signupdata : SignupPostData) throws -> Future<Response> {
        return try req.content.decode(SignupPostData.self).flatMap(to: Response.self) { data in
            
            //get the authenticated user
            //let user = try req.requireAuthenticated(User.self)
            
            //assign a profile picture userimage from db
            let rand = SimpleRandom.random(1...5)
            let gend = data.Gender
            
            let pfURL = "https://s3.us-east-2.amazonaws.com/futurpipol/Uploads/Images/ProfilePicture/Default/\(gend)/avatar\(rand).png"
            
            
            //specify the cost higher number means longer hash & verify time
            let hashedpw = try BCrypt.hash(data.Password, cost: 15)
            
            
            let createuser = User(Name: data.Name, Username: data.Username, Password: hashedpw, Gender: data.Gender, ProfilePictureURL: pfURL)
            
            return createuser.save(on: req).map(to: Response.self) { saveduser in
                try req.authenticateSession(saveduser)
                return req.redirect(to: "/")
            }
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


struct IndexContext: Content {
    let title: String
    let posts: [Post]?
    let comments: [Comment]?
    let user: User
    let allusers : [User]?
    let commentCount: Int?
    let showCookieMessage: Bool
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
    let posts: [Post]
    let comments: [Comment]
    let commentCount: Int?
}

struct settingsContext: Encodable {
    let title: String
    let user: User
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
struct SignupContext: Encodable {
    let title = "Sign Up"
}
struct SignupPostData: Content {
    static var defaultMediaType =  MediaType.urlEncodedForm
    let Name: String
    let Username: String
    let Password: String
    let Gender: String
}

struct otherUsersPageContext : Encodable {
    let title: String
    let otheruser : User
    let user : User
    let posts: [Post]
    let comments: [Comment]
    let commentCount: Int?
}

struct PostCommentData: Content {
    static var defaultMediaType =  MediaType.urlEncodedForm
    let Text: String?
    let postID: Int
}
