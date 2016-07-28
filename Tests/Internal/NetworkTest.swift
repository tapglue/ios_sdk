//
//  NetworkTest.swift
//  Tapglue
//
//  Created by John Nilsen on 7/6/16.
//  Copyright © 2016 Tapglue. All rights reserved.
//

import XCTest
import Mockingjay
import Nimble
@testable import Tapglue

class NetworkTest: XCTestCase {

    let postId = "postIdString"
    let commentId = "commentIdString"
    let userId = "someId213"
    var sampleUser: [String: AnyObject]!
    var samplePost: [String:AnyObject]!
    var sampleComment: [String:AnyObject]!
    var sampleUserFeed = [String: AnyObject]()
    var sampleCommentFeed = [String: AnyObject]()
    var sampleConnection: [String:AnyObject]!
    var network: Network!

    var analyticsSent = false
    
    override func setUp() {
        super.setUp()
        stub(http(.POST, uri: "/0.4/analytics"), builder: analyticsBuilder)
        Network.analyticsSent = false

        network = Network()
        sampleUser = ["user_name":"user1","id_string": userId,"password":"1234", "session_token":"someToken"]
        sampleUserFeed["users"] = [sampleUser]
        samplePost = ["visibility": 20, "attachments": [], "id": "postIdString"]
        sampleComment = ["contents":["en":"content"], postId:"postIdString"]
        sampleConnection = ["user_to_id_string": userId, "type":"follow", "state":"confirmed"]
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func analyticsBuilder(request: NSURLRequest) -> Response {
        analyticsSent = true
        let response = NSHTTPURLResponse(URL: request.URL!, statusCode: 200, HTTPVersion: nil, headerFields: nil)!
        return .Success(response, nil)
    }

    func testAnalyticsSentOnInstantiation() {
        expect(self.analyticsSent).toEventually(beTrue())
    }
    
    func testLogin() {
        stub(http(.POST, uri: "/0.4/users/login"), builder: json(sampleUser))
        
        var networkUser = User()
        _ = network.loginUser("user2", password: "1234").subscribeNext { user in
            networkUser = user
        }
        
        expect(networkUser.username).toEventually(equal("user1"))
    }
    
    func testLoginSetsSessionTokenToRouter() {
        stub(http(.POST, uri: "/0.4/users/login"), builder: json(sampleUser))
        
        _ = network.loginUser("user2", password: "1234").subscribe()
        
        expect(Router.sessionToken).toEventually(equal("someToken"))
    }
    
    func testRefreshCurrentUser() {
        stub(http(.GET, uri: "/0.4/me"), builder: json(sampleUser))
        
        var networkUser = User()
        _ = network.refreshCurrentUser().subscribeNext({ user in
            networkUser = user
        })
        
        expect(networkUser.username).toEventually(equal("user1"))
    }

    func testRetrieveFollowersReturnsEmptyArrayWhenNone() {
        sampleUserFeed["users"] = [User]()
        stub(http(.GET, uri: "/0.4/me/followers"), builder: json(sampleUserFeed))
        var followers: [User]?
        _ = network.retrieveFollowers().subscribeNext { users in
            followers = users
        }

        expect(followers).toNotEventually(beNil())
    }

    func testCreateUser() {
        stub(http(.POST, uri: "/0.4/users"), builder: json(sampleUser))
        let userToBeCreated = User()
        userToBeCreated.username = "someUsername"
        userToBeCreated.password = "1234"

        var createdUser = User()
        _ = network.createUser(userToBeCreated).subscribeNext { user in
            createdUser = user
        }
        expect(createdUser.username).toEventually(equal("user1"))
    }

    func testUpdateCurrentUser() {
        stub(http(.PUT, uri:"/0.4/me"), builder: json(sampleUser))
        var updatedUser = User();
        _ = network.updateCurrentUser(updatedUser).subscribeNext { user in
            updatedUser = user
        }
        expect(updatedUser.username).toEventually(equal("user1"))
    }

    func testLogout() {
        stub(http(.DELETE, uri:"/0.4/me/logout"), builder: http(204))
        var wasLoggedout = false
        _ = network.logout().subscribeCompleted { _ in
            wasLoggedout = true
        }
        expect(wasLoggedout).toEventually(beTruthy())
    }

    func testDeleteCurrentUser() {
        stub(http(.DELETE, uri:"/0.4/me"), builder: http(204))
        var wasDeleted = false
        _ = network.deleteCurrentUser().subscribeCompleted { _ in
            wasDeleted = true
        }
        expect(wasDeleted).toEventually(beTruthy())
    }

    func testRetrieveUser() {
        stub(http(.GET, uri:"/0.4/users/1234"), builder: json(sampleUser))
        var networkUser = User()
        _ = network.retrieveUser("1234").subscribeNext { user in
            networkUser = user
        }
        expect(networkUser.username).toEventually(equal("user1"))
    }

    func testCreateConnection() {
        stub(http(.PUT, uri: "/0.4/me/connections"), builder: json(sampleConnection))
        var networkConnection: Connection?
        let connection = Connection(toUserId: "2123", type: .Follow, state: .Confirmed)
        _ = network.createConnection(connection).subscribeNext { connection in
            networkConnection = connection
        }
        expect(networkConnection?.userToId).toEventually(equal(userId))
        expect(networkConnection?.type).toEventually(equal(ConnectionType.Follow))
    }

    func testDeleteConnection() {
        stub(http(.DELETE, uri: "/0.4/me/connections/follow/"+userId), builder: http(204))
        var wasDeleted = false
        _ = network.deleteConnection(toUserId: userId, type: .Follow).subscribeCompleted {
            wasDeleted = true
        }
        expect(wasDeleted).toEventually(beTrue())
    }
    
    func testRetrieveFollowers() {
        stub(http(.GET, uri: "/0.4/me/followers"), builder: json(sampleUserFeed))
        var followers = [User]()
        _ = network.retrieveFollowers().subscribeNext { users in
            followers = users
        }
        expect(followers.count).toEventually(equal(1))
        expect(followers.first?.username).toEventually(equal("user1"))
    }

    func testRetrieveFollowings() {
        stub(http(.GET, uri: "/0.4/me/follows"), builder: json(sampleUserFeed))
        var followings = [User]()
        _ = network.retrieveFollowings().subscribeNext {users in
            followings = users
        }
        expect(followings.count).toEventually(equal(1))
        expect(followings.first?.username).toEventually(equal("user1"))
    }

    func testRetrieveFollowersForUserId() {
        stub(http(.GET, uri: "/0.4/users/" + userId + "/followers"), builder: json(sampleUserFeed))
        var followers = [User]()
        _ = network.retrieveFollowersForUserId(userId).subscribeNext { users in
            followers = users
        }
        expect(followers.count).toEventually(equal(1))
        expect(followers.first?.id).toEventually(equal(userId))
    }

    func testRetrieveFollowingsForUserId() {
        stub(http(.GET, uri: "/0.4/users/" + userId + "/follows"),
                    builder: json(sampleUserFeed))
        var followings = [User]()
        _ = network.retrieveFollowingsForUserId(userId).subscribeNext { users in
            followings = users
        }
        expect(followings.count).toEventually(equal(1))
        expect(followings.first?.id).toEventually(equal(userId))
    }

    func testCreatePost() {
        stub(http(.POST, uri: "/0.4/posts"), builder: json(samplePost))
        var networkPost: Post?
        let post = Post(visibility: .Public, attachments: [])
        _ = network.createPost(post).subscribeNext { post in
            networkPost = post
        }
        expect(networkPost?.id).toEventually(equal(postId))
    }

    func testRetrievePost() {
        stub(http(.GET, uri: "/0.4/posts/" + postId), builder: json(samplePost))
        var networkPost: Post?
        _ = network.retrievePost(postId).subscribeNext { post in
            networkPost = post
        }
        expect(networkPost?.id).toEventually(equal(postId))
    }

    func testUpdatePost() {
        stub(http(.PUT, uri: "/0.4/posts/" + postId), builder: json(samplePost))
        var networkPost: Post?
        let post = Post(visibility: .Private, attachments: [])
        post.id = postId
        _ = network.updatePost(post).subscribeNext {post in
            networkPost = post
        }
        expect(networkPost?.id).toEventually(equal(postId))
    }

    func testDeletePost() {
        stub(http(.DELETE, uri: "/0.4/posts/" + postId), builder: http(204))
        var wasDeleted = false
        _ = network.deletePost(postId).subscribeCompleted {
            wasDeleted = true
        }
        expect(wasDeleted).toEventually(beTrue())
    }
    
    func testCreateComment() {
        stub(http(.POST, uri: "/0.4/posts/" + postId + "/comments"), builder: json(sampleComment))
        var networkComment: Comment?
        let comment = Comment(contents: ["en":"content"], postId: postId)
        _ = network.createComment(comment).subscribeNext { comment in
            networkComment = comment
        }
        expect(networkComment?.id).toEventually(equal(commentId))
    }
    
    func testRetrieveComments() {
        stub(http(.GET, uri: "/0.4/posts/" + postId + "/comments"),                    builder: json(sampleCommentFeed))
        var postComments = [Comment]()
        _ = network.retrieveComments(postId).subscribeNext { comments in
            postComments = comments
        }
        expect(postComments.count).toEventually(equal(1))
        expect(postComments.first?.id).toEventually(equal(commentId))
    }
    
    func testUpdateComment() {
        stub(http(.PUT, uri: "/0.4/posts/" + postId + "/comments"), builder: json(sampleComment))
        var networkComment: Comment?
        let comment = Comment(contents: ["en":"content"], postId: postId)
        comment.id = commentId
        _ = network.updateComment(comment).subscribeNext {comment in
            networkComment = comment
        }
        expect(networkComment?.id).toEventually(equal(commentId))
    }
    
    func testDeleteComment() {
        stub(http(.DELETE, uri: "/0.4/posts/" + postId + "/comments" + commentId), builder: http(204))
        let comment = Comment(contents: ["en":"content"], postId: postId)
        var wasDeleted = false
        _ = network.deleteComment(comment).subscribeCompleted {
            wasDeleted = true
        }
        expect(wasDeleted).toEventually(beTrue())
    }
}
