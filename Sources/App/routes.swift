import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
//    // Basic "It works" example
//    router.get { req in
//        return "It works!"
//    }
//
//    // Basic "Hello, world!" example
//    router.get("hello") { req in
//        return "Hello, world!"
//    }
//    router.get("hello","vapor") { req in
//        return "Hello Vapor!"
//    }
//    router.get("hello", String.parameter) { req -> String in
//        //2
//        let name = try req.parameters.next(String.self)
//        // 3
//        return "Hello, \(name)!"
//    }
//    //unchange
//    router.post(InfoData.self, at: "info") { req, data -> String in
//        return "Hello \(data.name)!"
//    }
//    //changed
//    router.post(InfoData.self, at: "info2") { req, data -> InfoResponse in
//        return InfoResponse(request: data)
//    }
    
    router.post("api", "posts") { req -> Future<Post> in
        return try req.content.decode(Post.self).flatMap(to: Post.self) { post in
            return post.save(on: req)
        }
    }

}

struct InfoData: Content {
    let name: String
}

struct InfoResponse: Content {
    let request: InfoData
}
