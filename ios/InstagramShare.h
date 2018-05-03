//
//  InstagramShare.h
//  RNShare
//
//  Created by Mudit Jumnani on 03/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
// import RCTConvert
#if __has_include(<React/RCTConvert.h>)
#import <React/RCTConvert.h>
#elif __has_include("RCTConvert.h")
#import "RCTConvert.h"
#else
#import "React/RCTConvert.h"   // Required when used as a Pod in a Swift project
#endif
// import RCTBridge
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
#import "RCTBridge.h"
#else
#import "React/RCTBridge.h"   // Required when used as a Pod in a Swift project
#endif

@interface InstagramShare : NSObject

- (void)shareSingle:(NSDictionary *)options successCallback:(void (^)(NSArray *response))successCallback failureCallback:(void (^)(NSError *error))failureCallback;

- (void)shareMultiple:(NSDictionary *)options successCallback:(void (^)(NSArray *response))successCallback failureCallback:(void (^)(NSError *error))failureCallback;

@end
