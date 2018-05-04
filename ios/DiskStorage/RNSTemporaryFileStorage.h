//
//  TemporaryFileStorage.h
//  RNShare
//
//  Created by Mudit Jumnani on 03/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNSTemporaryFileStorage : NSObject

+ (RNSTemporaryFileStorage *)sharedInstance;

- (BOOL)moveFileAtLocation:(NSURL *)location toTemporaryFile:(NSString *)fileName;

- (BOOL)fileExistsInTemporaryStorage:(NSString *)fileName;

- (NSString *)filePathUrlForFileName:(NSString *)fileName;

@end
