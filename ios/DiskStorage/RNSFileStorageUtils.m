//
//  FileStorageUtils.m
//  RNShare
//
//  Created by Mudit Jumnani on 03/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNSFileStorageUtils.h"
#import "NSStringRNShareAdditons.h"

static NSString *documentsDirectory;

static inline NSString *DocumentDirectoryPath() {
    if (!documentsDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
    }
    return documentsDirectory;
}

static inline NSFileManager *FileManager() {
    return [NSFileManager defaultManager];
}

static RNSFileStorageUtils *sharedInstance = nil;

@implementation RNSFileStorageUtils

+ (RNSFileStorageUtils *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[RNSFileStorageUtils alloc] init];
    }
    return sharedInstance;
}

- (BOOL)createDirectoryInUserDocumentDirectory:(NSString *)directoryName {
    if ([directoryName isEmpty]) {
        return NO;
    }
    NSString *directoryPath = [self directoryPathForDirectory:directoryName];
    if (![self directoryExistsAtPath:directoryPath]) {
        NSError *error = nil;
        BOOL hasCreated = [FileManager() createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!hasCreated) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)moveFileAtLocation:(NSURL *)location toLocationWithFileName:(NSString *)fileName {
    return [self moveFileAtLocation:location toLocationWithFileName:fileName andDirectory:nil];
}

- (BOOL)moveFileAtLocation:(NSURL *)location toLocationWithFileName:(NSString *)fileName andDirectory:(NSString *)directoryName {
    if (location && fileName && ![fileName isEmpty]) {
        NSString *directoryPath = [self directoryPathForDirectory:directoryName];
        if ([directoryPath isEmpty]) {
            directoryPath = DocumentDirectoryPath();
        } else if (![self directoryExistsAtPath:directoryPath]) {
            return NO;
        }
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        NSError *error;
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        BOOL hasFileSaved = [FileManager() moveItemAtURL:location toURL:fileURL error:&error];
        if (!hasFileSaved) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)fileExists:(NSString *)fileName inDirectory:(NSString *)directory {
    NSString *directoryPath = [self directoryPathForDirectory:directory];
    if ([directoryPath isEmpty] || [fileName isEmpty] || ![self directoryExistsAtPath:directoryPath]) {
        return NO;
    }
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    if ([FileManager() fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}

- (NSString *)filePathURLForFileName:(NSString *)fileName inDirecrory:(NSString *)directoryName {
    if (![fileName isEmpty]) {
        NSString *directoryPath = [self directoryPathForDirectory:directoryName];
        if ([directoryPath isEmpty]) {
            directoryPath = DocumentDirectoryPath();
        } else if (![self directoryExistsAtPath:directoryPath]) {
            return nil;
        }
        return [directoryPath stringByAppendingPathComponent:fileName];
    }
    return nil;
}

#pragma mark -

- (NSString *)directoryPathForDirectory:(NSString *)directoryName {
    if ([directoryName isEmpty]) {
        return nil;
    }
    return [DocumentDirectoryPath() stringByAppendingPathComponent:directoryName];
}

- (BOOL)directoryExistsAtPath:(NSString *)directoryPath {
    BOOL isDirectory = NO;
    return [FileManager() fileExistsAtPath:directoryPath isDirectory:&isDirectory] && isDirectory;
}


@end
