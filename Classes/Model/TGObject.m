//
//  TGObject.m
//  Tapglue iOS SDK
//
//  Created by Martin Stemmle on 04/06/15.
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

#import "TGObject+Private.h"
#import "NSDateFormatter+TGISOFormatter.h"
#import "NSDictionary+TGUtilities.h"

NSString *const TGModelObjectIdJsonKey = @"id";

@interface TGObject ()
@property (nonatomic, strong, readwrite) NSString *objectId;
@end

@implementation TGObject


- (instancetype)initWithDictionary:(NSDictionary*)data {
    self = [super init];
    if (self) {
        _objectId = [data tg_stringValueForKey:TGModelObjectIdJsonKey];

        if ([self respondsToSelector:@selector(jsonMapping)]) {
            [self loadDataFromDictionary:data withMapping:[self jsonMapping]];
        }
    }
    return self;
}

- (NSDictionary*)jsonDictionary {
    return [self dictionaryWithMapping:[self jsonMapping]];
}

- (void)loadDataFromDictionary:(NSDictionary *)data {
    NSDictionary *mapping = [self addObjectIdToJsonMapping:[self jsonMapping]];
    [self loadDataFromDictionary:data withMapping:mapping];
}

- (void)loadDataFromDictionary:(NSDictionary*)data withMapping:(NSDictionary*)mapping {
    [mapping enumerateKeysAndObjectsUsingBlock:^(id jsonKey, id objKey, BOOL *stop) {
        id dataValue = [data valueForKey:jsonKey];
        if (dataValue) {
            [self setValue:dataValue forKey:objKey];
        }
    }];
}

- (NSMutableDictionary*)dictionaryWithMapping:(NSDictionary*)mapping {
    mapping = [self addObjectIdToJsonMapping:mapping];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [mapping enumerateKeysAndObjectsUsingBlock:^(id jsonKey, id objKey, BOOL *stop) {
        id objectValue = [self valueForKey:objKey];
        BOOL addValue = objectValue != nil;
        addValue &= ![objectValue isEqual:@{}];
        if (addValue && [objectValue isKindOfClass:[NSNumber class]]) {
            addValue &= ![objectValue isEqual:[NSNumber numberWithFloat:NAN]];
            addValue &= ![objectValue isEqual:[NSNumber numberWithInteger:NAN]];
        }
        if (addValue) {
            [dict setObject:objectValue forKey:jsonKey];
        }
    }];
    return dict;
}

- (NSDictionary*)addObjectIdToJsonMapping:(NSDictionary*)jsonMapping {
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    [mapping setObject:@"objectId" forKey:TGModelObjectIdJsonKey];
    [mapping addEntriesFromDictionary:jsonMapping];
    return mapping;
}

@end
