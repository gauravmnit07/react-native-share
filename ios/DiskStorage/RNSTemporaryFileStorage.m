//
//  TemporaryFileStorage.m
//  RNShare
//
//  Created by Mudit Jumnani on 03/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNSTemporaryFileStorage.h"
#import "RNSFileStorageUtils.h"

static NSString *TemporaryDirectoryName = @"RNShareTempDir";

static RNSTemporaryFileStorage *sharedInstance = nil;

@implementation RNSTemporaryFileStorage


+ (RNSTemporaryFileStorage *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[RNSTemporaryFileStorage alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        [[RNSFileStorageUtils sharedInstance] createDirectoryInUserDocumentDirectory:TemporaryDirectoryName];
    }
    return self;
}

- (BOOL)moveFileAtLocation:(NSURL *)location toTemporaryFile:(NSString *)fileName {
    return [[RNSFileStorageUtils sharedInstance] moveFileAtLocation:location toLocationWithFileName:fileName andDirectory:TemporaryDirectoryName];
}

- (BOOL)fileExistsInTemporaryStorage:(NSString *)fileName {
    return [[RNSFileStorageUtils sharedInstance] fileExists:fileName inDirectory:TemporaryDirectoryName];
}

- (NSString *)filePathUrlForFileName:(NSString *)fileName {
    return [[RNSFileStorageUtils sharedInstance] filePathURLForFileName:fileName inDirecrory:TemporaryDirectoryName];
}


@end
