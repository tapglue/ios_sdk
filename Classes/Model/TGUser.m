//
//  TGUser.m
//  Tapglue iOS SDK
//
//  Created by Martin Stemmle on 02/06/15.
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

#import "TGUser.h"
#import "TGModelObject+Private.h"
#import "TGObjectCache.h"
#import "NSDateFormatter+TGISOFormatter.h"
#import "NSString+TGUtilities.h"
#import "NSDictionary+TGUtilities.h"
#import "Tapglue+Private.h"

static NSString *const TGUserCustomIdJsonKey = @"custom_id";
static NSString *const TGUserUsernameJsonKey = @"user_name";
static NSString *const TGUserPasswordJsonKey = @"password";
static NSString *const TGUserFirstNameJsonKey = @"first_name";
static NSString *const TGUserLastNameJsonKey = @"last_name";
static NSString *const TGUserEmailJsonKey = @"email";
static NSString *const TGUserUrlJsonKey = @"url";
static NSString *const TGUserActivatedJsonKey = @"activated";
static NSString *const TGUserLastLoginJsonKey = @"last_login";
static NSString *const TGUserSocialIdsJsonKey = @"social_ids";

@interface TGUser ()
@property (nonatomic, strong) NSMutableDictionary *mutableSocialIds;
@property (nonatomic, readwrite, getter=isActivated) BOOL activated;
@property (nonatomic, strong, readwrite) NSDate *lastLogin;
@end

@implementation TGUser

@synthesize mutableSocialIds = _mutableSocialIds;

#pragma mark - Init & Cache

+ (instancetype)createOrLoadWithDictionary:(NSDictionary*)userData {
    TGObjectCache *cache = [self cache];
    TGUser *user = [cache objectWithObjectId:[userData valueForKey:TGModelObjectIdJsonKey]];
    if (!user) {
        user = [[TGUser alloc] initWithDictionary:userData];
        if (user) { // user will be nil if the userData is invalid
            [cache addObject:user];
        }
    }
    return user;
}

- (instancetype)initWithDictionary:(NSDictionary*)userData {
    if (![self.class isValidUserData:userData]) {
        return nil;
    }
    self = [super initWithDictionary:userData];
    if (self) {
        _lastLogin = [[NSDateFormatter tg_isoDateFormatter] dateFromString:[userData valueForKey:TGUserLastLoginJsonKey]];
    }
    return self;
}

+ (BOOL)isValidUserData:(NSDictionary*)userData {
    BOOL isValid = YES;
    isValid &= [userData tg_hasStringValueForKey:TGModelObjectIdJsonKey];
    isValid &= [userData tg_hasStringValueForKey:TGUserUsernameJsonKey] || [userData tg_hasStringValueForKey:TGUserEmailJsonKey];
    return isValid;
}

#pragma mark - Getter & Setter

#pragma mark User Id

- (NSString*)userId {
    return super.objectId;
}

#pragma mark Password

- (void)setPassword:(NSString *)password {
    _hashedPassword = [self.class hashPassword:password];
}

+ (NSString*)hashPassword:(NSString *)password {
    return [password tg_stringHashedViaPBKDF2];
}

#pragma mark Social Ids

- (NSDictionary*)socialIds {
    return [[NSDictionary alloc] initWithDictionary:self.mutableSocialIds];
}

- (NSString*)socialIdForKey:(NSString*)socialIdKey {
    return [self.mutableSocialIds objectForKey:socialIdKey];
}

- (void)setSocialId:(NSString*)socialId forKey:(NSString*)socialIdKey {
    [self.mutableSocialIds setObject:socialId forKey:socialIdKey];
}

- (NSMutableDictionary*)mutableSocialIds {
    if(!_mutableSocialIds) {
        _mutableSocialIds = [NSMutableDictionary dictionary];
    }
    return _mutableSocialIds;
}

- (void)setMutableSocialIds:(NSMutableDictionary *)mutableSocialIds {
    if ([mutableSocialIds isKindOfClass:[NSDictionary class]]) {
        _mutableSocialIds = mutableSocialIds.mutableCopy;
    } else {
        _mutableSocialIds = mutableSocialIds;
    }
}

#pragma mark - JSON Parser

- (NSDictionary*)jsonDictionary {
    NSMutableDictionary *dictFromMapping = [self dictionaryWithMapping:[self jsonMappingForWriting]];
    if (self.hashedPassword) { [dictFromMapping setObject:self.hashedPassword forKey:TGUserPasswordJsonKey]; }
    return dictFromMapping ;
}

- (NSDictionary*)jsonMapping {
    static NSDictionary *mapping;
    if (!mapping) {
        mapping = [self jsonMappingForReading];
    }
    return mapping;
}

- (NSDictionary*)jsonMappingForWriting {
    // left side: json attribute name , right side: model property name
    return @{
             TGUserCustomIdJsonKey : @"customId",
             TGUserUsernameJsonKey : @"username",
             TGUserFirstNameJsonKey : @"firstName",
             TGUserLastNameJsonKey : @"lastName",
             TGUserEmailJsonKey : @"email",
             TGUserUrlJsonKey : @"url",
             TGUserSocialIdsJsonKey : @"mutableSocialIds",
             TGModelObjectMetadataJsonKey : @"metadata"
             };
}

- (NSDictionary*)jsonMappingForReading {
    NSMutableDictionary *mapping = [self jsonMappingForWriting].mutableCopy;
    [mapping addEntriesFromDictionary:@{
                                        TGUserActivatedJsonKey : @"activated",
                                        TGUserLastLoginJsonKey : @"lastLogin"
                                        }];
    return mapping;
}

#pragma mark - Helper

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %@=%@, %@=%@>",
            NSStringFromClass(self.class),
            TGModelObjectIdJsonKey, self.userId,
            TGUserUsernameJsonKey, self.username];
}

#pragma mark - Current user

- (BOOL)isCurrentUser {
    return self == [TGUser currentUser];
}

static NSString *const TGUserDefaultsCurrentUserKey = @"current_user";
static TGUser *_inMemoryCurrentUser = nil;

+ (TGUser*)currentUser {
    if (!_inMemoryCurrentUser) {
        id userData = [[Tapglue sharedInstance].userDefaults objectForKey:TGUserDefaultsCurrentUserKey];
        if ([userData isKindOfClass:[NSDictionary class]]) {
            _inMemoryCurrentUser = [TGUser createOrLoadWithDictionary:userData];
        }
        else {
            TGLog(@"WARNING: failed to load current user from user defaults");
        }
    }
    return _inMemoryCurrentUser;
}

+ (void)setCurrentUser:(TGUser*)user {
    if (![_inMemoryCurrentUser.userId isEqualToString:user.userId]) {
        [[Tapglue sharedInstance] reset];
    }
    _inMemoryCurrentUser = user;
    NSUserDefaults *userDefaults = [Tapglue sharedInstance].userDefaults;
    if (user) {
        [userDefaults setObject:user.jsonDictionary forKey:TGUserDefaultsCurrentUserKey];
    }
    else {
        [userDefaults removeObjectForKey:TGUserDefaultsCurrentUserKey];
    }
    [userDefaults synchronize]; 
}

@end