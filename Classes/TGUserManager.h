//
//  TGUserManager.h
//  Tapglue iOS SDK
//
//  Created by Martin Stemmle on 09/06/15.
//  Copyright (c) 2015 Tapglue (https://www.tapglue.com/). All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TGBaseManager.h"
#import "Tapglue.h"

/*!
 @abstract The users session token.
 @constant TapglueUserDefaultsKeySessionToken This property stores the session token of the current user.
 */
extern NSString *const TapglueUserDefaultsKeySessionToken;

/*!
 @typedef Determines the connection type.
 @constant TGConnectionTypeFriend Specifies a friend connection.
 @constant TGConnectionTypeFollow Specifies a follow connection.
 @constant TGConnectionTypeFollowers Specifies a follower connection.
 */
typedef NS_ENUM(NSUInteger, TGConnectionType) {
    TGConnectionTypeFriend = 0,
    TGConnectionTypeFollow,
    TGConnectionTypeFollowers
};

/*!
 @abstract The user manager handles all user interactions.
 @discussion This will handle all user interactions in the app.
 */
@interface TGUserManager : TGBaseManager

#pragma mark - User

/*!
 @abstract Create and login the user.
 @discussion This will create and login a user.
 
 @warning If the the user already exists it will just act as a login.
 */
- (void)createAndLoginUser:(TGUser*)user withCompletionBlock:(TGSucessCompletionBlock)completionBlock;

/*!
 @abstract Update a user.
 @discussion This will update a TGUser object.
 
 @param user The TGUser object that you want to update.
 */
- (void)updateUser:(TGUser*)user withCompletionBlock:(TGSucessCompletionBlock)completionBlock;

/*!
 @abstract Delete the currentUser.
 @discussion This will delete the currentUser.
 */
- (void)deleteCurrentUserWithCompletionBlock:(TGSucessCompletionBlock)completionBlock;

/*!
 @abstract Retrieve a user.
 @discussion This will retrieve a user object.
 
 @param userId The id of the user you want to retrieve.
 */
- (void)retrieveUserWithId:(NSString*)userId withCompletionBlock:(TGGetUserCompletionBlock)completionBlock;

/*!
 @abstract Login a user.
 @discussion This will login a user with a username or an email adress.
 
 @param usernameOrEmail The username or email of the user.
 @param usernameOrEmail The password of the user.
 */
- (void)loginWithUsernameOrEmail:(NSString*)usernameOrEmail
                     andPasswort:(NSString*)password
             withCompletionBlock:(TGSucessCompletionBlock)completionBlock;

/*!
 @abstract Retrieve the currentUser.
 @discussion This will retrieve the currentUser.
 */
- (void)retrieveCurrentUserWithCompletionBlock:(TGGetUserCompletionBlock)completionBlock;

/*!
 @abstract Logout the currentUser.
 @discussion This will logout the currentUser.
 */
- (void)logoutWithCompletionBlock:(TGSucessCompletionBlock)completionBlock;

/*!
 @abstract Search users.
 @discussion This will search for users for a given term.
 
 @param searchString Term for which users should be searched.
 */
- (void)searchUsersWithSearchString:(NSString*)searchString andCompletionBlock:(void (^)(NSArray *users, NSError *error))completionBlock;

#pragma mark - Connections

/*!
 @abstract Retrieve the connections of a user.
 @discussion This will retrieve the connections of a certain user.
 
 @param connectionType The connection type that should be retrieved.
 @param user The user to get the connected users of or nil to get current user's connected users.
 */
- (void)retrieveConnectedUsersOfConnectionType:(TGConnectionType)connectionType
                                       forUser:(TGUser*)user
                           withCompletionBlock:(void (^)(NSArray *users, NSError *error))completionBlock;

/*!
 @abstract Create a connection for a user.
 @discussion This will create a certain type of connection for the currentUser.
 
 @param connectionType The connection type that should be created.
 @param toUser The user towards which the connection should be created for.
 */
- (void)createConnectionOfType:(TGConnectionType)connectionType
                        toUser:(TGUser*)toUser
           withCompletionBlock:(TGSucessCompletionBlock)completionBlock;

/*!
 @abstract Delete a connection for a user.
 @discussion This will delete a certain type of connection for the currentUser.
 
 @param connectionType The connection type that should be created.
 @param toUser The user towards which the connection should be deleted for.
 */
- (void)deleteConnectionOfType:(TGConnectionType)connectionType
                        toUser:(TGUser*)toUser
           withCompletionBlock:(TGSucessCompletionBlock)completionBlock;

/*!
 @abstract Create Social Connections for a user.
 @discussion This will create connections for the currentUser from a given social source. That can be facebook or twitter for exmaple.
 
 @param connectionType The connection type that should be created.
 @param socialIdKey The social id of the currentUser.
 @param toSocialUsersIds The social ids of the currentUsers connections from a given source.
 */
- (void)createSocialConnectionsForCurrentUserOnPlatformWithSocialIdKey:(NSString*)socialIdKey
                                                                ofType:(TGConnectionType)connectionType
                                                      toSocialUsersIds:(NSArray*)toSocialUsersIds
                                                   withCompletionBlock:(TGSucessCompletionBlock)completionBlock;

@end