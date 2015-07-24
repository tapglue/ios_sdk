//
//  TGUserManager.m
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

#import "TGUserManager.h"
#import "TGApiClient.h"
#import "TGUser.h"
#import "TGModelObject+Private.h"
#import "Tapglue+Private.h"
#import "TGUser+Private.h"
#import "NSError+TGError.h"
#import "TGObjectCache.h"

NSString *const TapglueUserDefaultsKeySessionToken = @"sessionToken";

@implementation TGUserManager

#pragma mark - Current User

- (void)createAndLoginUser:(TGUser*)user withCompletionBlock:(TGSucessCompletionBlock)completionBlock {
    [self.client POST:@"users" withURLParameters:@{@"withLogin" : @"true"} andPayload:user.jsonDictionary andCompletionBlock:^(NSDictionary *jsonResponse, NSError *error) {
        [self handleLoginResponse:jsonResponse
                        withError:error
                      requestUser:user
               andCompletionBlock:completionBlock];
    }];
}

- (void)updateUser:(TGUser*)user withCompletionBlock:(TGSucessCompletionBlock)completionBlock {
    [self.client PUT:@"user" withURLParameters:nil andPayload:user.jsonDictionary andCompletionBlock:^(NSDictionary *jsonResponse, NSError *error) {

        if (jsonResponse && !error) {
            [user loadDataFromDictionary:jsonResponse];
        }

        if (completionBlock) {
            completionBlock(error == nil, error);
        }
    }];
}

- (void)deleteCurrentUserWithCompletionBlock:(TGSucessCompletionBlock)completionBlock {
    [self.client DELETE:@"user" withCompletionBlock:^(BOOL success, NSError *error) {
        [self handleLogoutResponse:success withError:error andCompletionBlock:completionBlock];
    }];
}


- (void)loginWithUsernameOrEmail:(NSString *)usernameOrEmail
                     andPasswort:(NSString *)password
             withCompletionBlock:(TGSucessCompletionBlock)completionBlock {

    NSDictionary *loginData = @{@"username": usernameOrEmail,
                                @"password": [TGUser hashPassword:password]};

    [self.client POST:@"user/login" withURLParameters:@{@"withUserDetails" : @"true"} andPayload:loginData andCompletionBlock:^(NSDictionary *jsonResponse, NSError *error) {
        [self handleLoginResponse:jsonResponse
                        withError:error
                      requestUser:nil
               andCompletionBlock:completionBlock];
    }];
}

- (void)retrieveCurrentUserWithCompletionBlock:(TGGetUserCompletionBlock)completionBlock {
    [self.client GET:@"user" withCompletionBlock:^(NSDictionary *jsonResponse, NSError *error) {
        [self handleSingleUserResponse:jsonResponse withError:error andCompletionBlock:completionBlock];
    }];
}

- (void)logoutWithCompletionBlock:(TGSucessCompletionBlock)completionBlock {
    [self.client DELETE:@"user/logout" withCompletionBlock:^(BOOL success, NSError *error) {
        [self handleLogoutResponse:success withError:error andCompletionBlock:completionBlock];
    }];
}

#pragma mark  - Other users

- (void)retrieveUserWithId:(NSString*)userId withCompletionBlock:(TGGetUserCompletionBlock)completionBlock {
    [self.client GET:[@"users" stringByAppendingPathComponent:userId] withCompletionBlock:^(NSDictionary *jsonResponse, NSError *error) {
        [self handleSingleUserResponse:jsonResponse withError:error andCompletionBlock:completionBlock];
    }];
}

- (void)searchUsersWithSearchString:(NSString*)searchString
                 andCompletionBlock:(void (^)(NSArray *users, NSError *error))completionBlock {
    [self.client GET:@"users/search" withURLParameters:@{@"q" : searchString} andCompletionBlock:^(NSDictionary *jsonResponse, NSError *error) {
        [self handleUserListResponse:jsonResponse withError:error andCompletionBlock:completionBlock];
    }];
}

#pragma mark   Helper - Handlers

- (void)handleLoginResponse:(NSDictionary*)jsonResponse
                  withError:(NSError*)responseError
                requestUser:(TGUser*)requestUser
         andCompletionBlock:(TGSucessCompletionBlock)completionBlock {

    if (!responseError) {
        TGUser *currentUser;
        if (requestUser) {
            [requestUser loadDataFromDictionary:jsonResponse];
            [[TGUser cache] addObject:requestUser];
            currentUser = requestUser;
        }
        else {
            currentUser = [TGUser createOrLoadWithDictionary:jsonResponse];
        }

        NSString *sessionToken = [jsonResponse valueForKey:@"session_token"];
        NSAssert(sessionToken, @"Login should return a session token.");  // ToDo: proper error handling if no session token was returned

        [[Tapglue sharedInstance].userDefaults setObject:sessionToken forKey:TapglueUserDefaultsKeySessionToken];
        self.client.sessionToken = sessionToken;

        [TGUser setCurrentUser:currentUser];


        if (completionBlock) {
            completionBlock(YES, nil);
        }
    }
    else if (completionBlock) {
        completionBlock(NO, responseError);
    }

}

- (void)handleLogoutResponse:(BOOL)success withError:(NSError*)responseError andCompletionBlock:(TGSucessCompletionBlock)completionBlock {
    if (success) {
        [TGUser setCurrentUser:nil];
        NSUserDefaults *tgUserDefaults = [Tapglue sharedInstance].userDefaults;
        [tgUserDefaults removeObjectForKey:TapglueUserDefaultsKeySessionToken];
        [tgUserDefaults synchronize];
    }
    else {
        TGLog(@"Logout failed");
        //TODO: improve error handling: e.g. if the backend returns a 404 also remove current user and tread it as success
    }

    if (completionBlock) {
        completionBlock(success, responseError);
    }
}

- (void)handleSingleUserResponse:(NSDictionary*)jsonResponse withError:(NSError*)responseError andCompletionBlock:(TGGetUserCompletionBlock)completionBlock {
    if (jsonResponse && !responseError) {
        TGUser *currentUser = [[TGUser alloc] initWithDictionary:jsonResponse];
        if (completionBlock) {
            completionBlock(currentUser, nil);
        }
    }
    else if (completionBlock) {
        completionBlock(nil, responseError);
    }
}

- (void)handleUserListResponse:(NSDictionary*)jsonResponse withError:(NSError*)responseError andCompletionBlock:(void (^)(NSArray *users, NSError *error))completionBlock {
    if (completionBlock) {
        if (!responseError) {
            NSArray *users = [TGUser createAndCacheObjectsFromDictionaries:[jsonResponse objectForKey:@"users"]];
            completionBlock(users, nil);
        } else {
            completionBlock(nil, responseError);
        }
    }
}

#pragma mark - Connections

- (void)retrieveConnectedUsersOfConnectionType:(TGConnectionType)connectionType
                                       forUser:(TGUser*)user
                           withCompletionBlock:(void (^)(NSArray *users, NSError *error))completionBlock {

    NSString *apiEndpoint = user ? [@"users" stringByAppendingPathComponent:user.userId] : @"user";

    switch (connectionType) {
        case TGConnectionTypeFriend:
            apiEndpoint = [apiEndpoint stringByAppendingPathComponent:@"friends"];
            break;
        case TGConnectionTypeFollow:
            apiEndpoint = [apiEndpoint stringByAppendingPathComponent:@"follows"];
            break;
        case TGConnectionTypeFollowers:
            apiEndpoint = [apiEndpoint stringByAppendingPathComponent:@"followers"];
            break;
        default:
            break;
    }

    [self.client GET:apiEndpoint withCompletionBlock:^(NSDictionary *jsonResponse, NSError *error) {
        [self handleUserListResponse:jsonResponse withError:error andCompletionBlock:completionBlock];
    }];

}

- (void)createSocialConnectionsForCurrentUserOnPlatformWithSocialIdKey:(NSString*)socialIdKey
                                                                ofType:(TGConnectionType)connectionType
                                                      toSocialUsersIds:(NSArray*)toSocialUsersIds
                                                   withCompletionBlock:(TGSucessCompletionBlock)completionBlock {

    NSString *ownSocialId = [[TGUser currentUser] socialIdForKey:socialIdKey];
    if (!ownSocialId) {
        if (completionBlock) {
            completionBlock(NO, [NSError tg_errorWithCode:kTGErrorNoSocialIdForPlattform userInfo:nil]);
        }
        return;
    }

    NSMutableArray *toSocialUsersIdsAsStrings = [NSMutableArray arrayWithCapacity:toSocialUsersIds.count];
    [toSocialUsersIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [toSocialUsersIdsAsStrings addObject:obj];
        }
        else {
            [toSocialUsersIdsAsStrings addObject:[obj description]];
        }
    }];

    NSDictionary *connectionsData = @{
                                      @"platform" : socialIdKey,
                                      @"type" : [self stringFromConnectionType:connectionType],
                                      @"platform_user_id" : ownSocialId,
                                      @"connection_ids" : toSocialUsersIdsAsStrings
                                      };

    [self.client POST:@"user/connections/social" withURLParameters:nil andPayload:connectionsData andCompletionBlock:^(NSDictionary *jsonResponse, NSError *error) {
        if (completionBlock) {
            if (jsonResponse && !error) {
                completionBlock(YES, nil);
            }
            else {
                completionBlock(NO, error);
            }
        }
    }];
}

- (void)createConnectionOfType:(TGConnectionType)connectionType
                        toUser:(TGUser*)toUser
           withCompletionBlock:(TGSucessCompletionBlock)completionBlock {

    if (!toUser.userId) {
        if (completionBlock) {
            NSDictionary *errorInfo = @{NSLocalizedDescriptionKey : @"The give toUser was either `nil` or has no userId." };
            completionBlock(NO, [NSError tg_errorWithCode:kTGErrorInconsistentData userInfo:errorInfo]);
        }
        return;
    }

    NSDictionary *connectionData = @{
                                     @"user_to_id" : [[[NSNumberFormatter alloc] init] numberFromString:toUser.userId] ?: @(0),
                                     @"type" : [self stringFromConnectionType:connectionType]
                                     };

    [self.client POST:@"user/connections" withURLParameters:nil andPayload:connectionData andCompletionBlock:^(NSDictionary *jsonResponse, NSError *error) {
        if (completionBlock) {
            if (jsonResponse && !error) {
                completionBlock(YES, nil);
            }
            else {
                completionBlock(NO, error);
            }
        }
    }];
}

- (void)deleteConnectionOfType:(TGConnectionType)connectionType
                        toUser:(TGUser*)toUser
           withCompletionBlock:(TGSucessCompletionBlock)completionBlock {
    [self.client DELETE:[@"user/connections" stringByAppendingPathComponent:toUser.userId]
      withURLParameters:@{ @"type" : [self stringFromConnectionType:connectionType] }
     andCompletionBlock:completionBlock];
}

- (NSString*)stringFromConnectionType:(TGConnectionType)connectionType {
    return connectionType == TGConnectionTypeFriend ? @"friend" : @"follow";
}

@end
