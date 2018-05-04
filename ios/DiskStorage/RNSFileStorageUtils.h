//
//  FileStorageUtils.h
//  RNShare
//
//  Created by Mudit Jumnani on 03/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNSFileStorageUtils : NSObject

+ (RNSFileStorageUtils *)sharedInstance;;


- (BOOL)createDirectoryInUserDocumentDirectory:(NSString *)directoryName;

- (BOOL)moveFileAtLocation:(NSURL *)location toLocationWithFileName:(NSString *)fileName;
- (BOOL)moveFileAtLocation:(NSURL *)location toLocationWithFileName:(NSString *)fileName andDirectory:(NSString *)directoryName;//create file with data in subdirectory of user domain document directory

- (BOOL)fileExists:(NSString *)fileName inDirectory:(NSString *)directory;;

- (NSString *)filePathURLForFileName:(NSString *)fileName inDirecrory:(NSString *)directoryName;

@end
