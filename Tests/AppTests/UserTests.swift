@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
    
    
    
    let usersName = "Alice"
    let usersUsername = "alicea"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        let user = try User.create(
            name: usersName,
            username: usersUsername,
            on: conn)
        _ = try User.create(on: conn)
        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User].self)
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].Name, usersName)
        XCTAssertEqual(users[0].Username, usersUsername)
        XCTAssertEqual(users[0].id, user.id)
    }
    
    func testUserCanBeSavedWithAPI() throws {
        // 1
        let user = User(Name: usersName, Username: usersUsername)
        // 2
        let receivedUser = try app.getResponse(
            to: usersURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: user,
            decodeTo: User.self)
        // 3
        XCTAssertEqual(receivedUser.Name, usersName)
        XCTAssertEqual(receivedUser.Username, usersUsername)
        XCTAssertNotNil(receivedUser.id)
        // 4
        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User].self)
        // 5
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].Name, usersName)
        XCTAssertEqual(users[0].Username, usersUsername)
        XCTAssertEqual(users[0].id, receivedUser.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        // 1
        let user = try User.create(
            name: usersName,
            username: usersUsername,
            on: conn)
        // 2
        let receivedUser = try app.getResponse(
            to: "\(usersURI)\(user.id!)",
            decodeTo: User.self)
        // 3
        XCTAssertEqual(receivedUser.Name, usersName)
        XCTAssertEqual(receivedUser.Username, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
    }
    func testGettingAUsersPostsFromTheAPI() throws {
        // 1
        let user = try User.create(on: conn)
        // 2
        let Typeofpost = "Public"
        let Text = "Hello World!"
        // 3
        let post1 = try Post.create(
            Typeofpost: Typeofpost,
            Text: Text,
            user: user,
            on: conn)
        _ = try Post.create(
            Typeofpost: "Public",
            Text: "Hello World!",
            user: user,
            on: conn)
        // 4
        let posts = try app.getResponse(
            to: "\(usersURI)\(user.id!)/posts",
            decodeTo: [Post].self)
        // 5
        XCTAssertEqual(posts.count, 2)
        XCTAssertEqual(posts[0].id, post1.id)
        XCTAssertEqual(posts[0].Typeofpost, Typeofpost)
        XCTAssertEqual(posts[0].Text, Text)
    }
    
    static let allTests = [
        ("testUsersCanBeRetrievedFromAPI",
         testUsersCanBeRetrievedFromAPI),
        ("testUserCanBeSavedWithAPI", testUserCanBeSavedWithAPI),
        ("testGettingASingleUserFromTheAPI",
         testGettingASingleUserFromTheAPI)
    ]
}
