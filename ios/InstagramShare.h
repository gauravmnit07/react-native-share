//
//  InstagramShare.h
//  RNShare
//
//  Created by Gaurav Bansal on 8/14/17.
//  Copyright © 2017 Facebook. All rights reserved.
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
// import RCTLog
#if __has_include(<React/RCTUtils.h>)
#import <React/RCTLog.h>
#elif __has_include("RCTLog.h")
#import "RCTLog.h"
#else
#import "React/RCTLog.h"   // Required when used as a Pod in a Swift project
#endif

@interface InstagramShare : NSObject <RCTBridgeModule>
 
- (void)shareSingle:(NSDictionary *)options successCallback:(RCTResponseSenderBlock)successCallback failureCallback:(RCTResponseErrorBlock)failureCallback;

- (void)shareMultiple:(NSDictionary *)options successCallback:(RCTResponseSenderBlock)successCallback failureCallback:(RCTResponseErrorBlock)failureCallback;

@end
