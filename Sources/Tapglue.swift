//
//  File.swift
//  Tapglue
//
//  Created by John Nilsen on 7/12/16.
//  Copyright © 2016 Tapglue. All rights reserved.
//

import Foundation
import RxSwift

public class Tapglue {
    let disposeBag = DisposeBag()
    let rxTapglue: RxTapglue
    
    var currentUser: User? {
        get {
            return rxTapglue.currentUser
        }
    }
    
    public init(configuration: Configuration) {
        rxTapglue = RxTapglue(configuration: configuration)
    }
    
    public func loginUser(username: String, password: String, completionHandler: (user: User?, error: ErrorType?) -> ()) {
        rxTapglue.loginUser(username, password: password).unwrap(completionHandler)
    }

    public func createUser(user: User, completionHandler: (user: User?, error: ErrorType?) -> ()) {
        rxTapglue.createUser(user).unwrap(completionHandler)
    }

    public func updateCurrentUser(user: User, completionHandler: (user: User?, error: ErrorType?) -> ()) {
        rxTapglue.updateCurrentUser(user).unwrap(completionHandler)
    }

    public func refreshCurrentUser(completionHandler: (user: User?, error: ErrorType?) -> ()) {
        rxTapglue.refreshCurrentUser().unwrap(completionHandler)
    }

    public func logout(completionHandler: (success:Bool, error:ErrorType?) -> ()) {
        rxTapglue.logout().unwrap(completionHandler)
    }

    public func deleteCurrentUser(completionHandler: (success:Bool, error:ErrorType?) -> ()) {
        rxTapglue.deleteCurrentUser().unwrap(completionHandler)
    }

    public func retrieveUser(id: String, completionHandler: (user:User?, error: ErrorType?) -> ()) {
        rxTapglue.retrieveUser(id).unwrap(completionHandler)
    }

    public func createConnection(connection: Connection, 
            completionHandler: (connection: Connection?, error: ErrorType?) -> ()) {
        rxTapglue.createConnection(connection).unwrap(completionHandler)
    }

    public func deleteConnection(toUserId userId: String, type: 
            ConnectionType, completionHandler: (success: Bool, error: ErrorType?) -> ()) {
        rxTapglue.deleteConnection(toUserId: userId, type: type).unwrap(completionHandler)
    }

    public func retrieveFollowers(completionHandler: (users: [User]?, error: ErrorType?) -> ()) {
        rxTapglue.retrieveFollowers().unwrap(completionHandler)
    }

    public func retrieveFollowings(completionHandler: (users: [User]?, error: ErrorType?) -> ()) {
        rxTapglue.retrieveFollowings().unwrap(completionHandler)
    }

    public func retrieveFollowersForUserId(id: String, 
            completionHandler: (users: [User]?, error:ErrorType?) -> ()) {
        rxTapglue.retrieveFollowersForUserId(id).unwrap(completionHandler)
    }

    public func retrieveFollowingsForUserId(id: String, 
            completionHandler: (users: [User]?, error: ErrorType?) -> ()) {
        rxTapglue.retrieveFollowingsForUserId(id).unwrap(completionHandler)
    }

    public func createPost(post: Post, completionHandler: (post: Post?, error: ErrorType?) -> ()) {
        rxTapglue.createPost(post).unwrap(completionHandler)
    }

    public func retrievePost(id: String, completionHandler: (post: Post?, error: ErrorType?) -> ()) {
        rxTapglue.retrievePost(id).unwrap(completionHandler)
    }

    public func updatePost(post: Post, completionHandler: (post: Post?, error: ErrorType?) -> ()) {
        rxTapglue.updatePost(post).unwrap(completionHandler)
    }

    public func deletePost(id: String, completionHandler: (success: Bool, error: ErrorType?) -> ()) {
        rxTapglue.deletePost(id).unwrap(completionHandler)
    }
    public func createComment(comment: Comment, completionHandler: (comment: Comment?, error: ErrorType?) -> ()) {
        rxTapglue.createComment(comment).unwrap(completionHandler)
    }
    
    // TODO: Comments List
    public func retrieveComments(postId: String, completionHandler: (comments: [Comment]?, error: ErrorType?) -> ()) {
        rxTapglue.retrieveComments(postId).unwrap(completionHandler)
    }
    
    public func updateComment(comment: Comment, completionHandler: (comment: Comment?, error: ErrorType?) -> ()) {
        rxTapglue.updateComment(comment).unwrap(completionHandler)
    }
    
    public func deleteComment(comment: Comment, completionHandler: (success: Bool, error: ErrorType?) -> ()) {
        rxTapglue.deleteComment(comment).unwrap(completionHandler)
    }
}