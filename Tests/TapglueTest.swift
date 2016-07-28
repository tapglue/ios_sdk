//
//  TapglueTest.swift
//  Tapglue
//
//  Created by John Nilsen on 7/12/16.
//  Copyright © 2016 Tapglue. All rights reserved.
//

import XCTest
import Nimble
import Mockingjay
@testable import Tapglue

class TapglueTest: XCTestCase {

    let userId = "testUserId"
    var tapglue: Tapglue!
    let network = TestNetwork()

    override func setUp() {
        super.setUp()
        stub(http(.POST, uri: "/0.4/analytics"), builder: http(204))
        
        tapglue = Tapglue(configuration: Configuration())
        tapglue.rxTapglue.network = network
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testLogin() {
        var callbackUser = User()
        tapglue.loginUser("user1", password: "1234") { user, error in
            callbackUser = user!
        }
        
        expect(callbackUser.id).toEventually(equal(userId))
    }

    func testCreateUser() {
        var callbackUser = User()
        tapglue.createUser(User()) { user, error in
            callbackUser = user!
        }
        expect(callbackUser.id).toEventually(equal(userId))
    }

    func testUpdateCurrentUser() {
        var callbackUser = User()
        tapglue.updateCurrentUser(User()) { user, error in
            callbackUser = user!
        }
        expect(callbackUser.id).toEventually(equal(userId))
    }

    func testRefreshCurrentUser() {
        var callbackUser = User()
        tapglue.refreshCurrentUser() { user, error in
            callbackUser = user!
        }
        expect(callbackUser.id).toEventually(equal(userId))
    }

    func testLogout() {
        var wasLoggedOut = false
        tapglue.logout() { success, error in 
            wasLoggedOut = success
        }
        expect(wasLoggedOut).toEventually(beTrue())
    }

    func testDeleteUser() {
        var wasDeleted = false
        tapglue.deleteCurrentUser() { success, error in
            wasDeleted = true
        }
        expect(wasDeleted).toEventually(beTrue())
    }

    func testRetrieveUser() {
        var callbackUser = User()
        tapglue.retrieveUser("id") { user, error in
            callbackUser = user!
        }
        expect(callbackUser.id).toEventually(equal(userId))
    }

    func testCreateConnection() {
        var callbackConnection: Connection?
        let connection = Connection(toUserId: "userId", type: .Follow, state: .Confirmed)
        tapglue.createConnection(connection) { connection, error in
            callbackConnection = connection
        }
        expect(callbackConnection).toEventuallyNot(beNil())
    }

    func testDeleteConnection() {
        var wasDeleted = false
        tapglue.deleteConnection(toUserId: "userId", type: .Follow) { success, error in
            wasDeleted = true
        }
        expect(wasDeleted).toEventually(beTrue())
    }

    func testRetrieveFollowers() {
        var callbackUsers = [User]()
        tapglue.retrieveFollowers() { users, error in
            callbackUsers = users!
        }
        expect(callbackUsers).toEventually(contain(network.testUser))
    }

    func testRetrieveFollowings() {
        var callbackUsers =  [User]()
        tapglue.retrieveFollowings() { users, error in
            callbackUsers = users!
        }
        expect(callbackUsers).toEventually(contain(network.testUser))
    }

    func testRetrieveFollowersForUserId() {
        var callbackUsers = [User]()
        tapglue.retrieveFollowersForUserId("userId") { users, error in
            callbackUsers = users!
        }
        expect(callbackUsers).toEventually(contain(network.testUser))
    }

    func testRetrieveFollowingsForUserId() {
        var callbackUsers = [User]()
        tapglue.retrieveFollowingsForUserId("userId") { users, error in
            callbackUsers = users!
        }
        expect(callbackUsers).toEventually(contain(network.testUser))
    }

    func testCreatePost() {
        var callbackPost: Post?
        let post = Post(visibility: .Private, attachments: [Attachment]())
        tapglue.createPost(post) { post, error in
            callbackPost = post
        }
        expect(callbackPost).toEventuallyNot(beNil())
    }

    func testRetrievePost() {
        var callbackPost: Post?
        tapglue.retrievePost("postId") { post, error in
            callbackPost = post
        }
        expect(callbackPost).toEventuallyNot(beNil())
    }

    func testUpdatePost() {
        var callbackPost: Post?
        let post = Post(visibility: .Public, attachments: [Attachment]())
        tapglue.updatePost(post) { post, error in
            callbackPost = post
        }
        expect(callbackPost).toEventuallyNot(beNil())
    }

    func testDeletePost() {
        var wasDeleted = false
        tapglue.deletePost("postId") { success, error in
            wasDeleted = success
        }
        expect(wasDeleted).toEventually(beTrue())
    }
}
