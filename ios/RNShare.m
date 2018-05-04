#import "RNShare.h"
// import RCTConvert
#if __has_include(<React/RCTConvert.h>)
#import <React/RCTConvert.h>
#elif __has_include("RCTConvert.h")
#import "RCTConvert.h"
#else
#import "React/RCTConvert.h"   // Required when used as a Pod in a Swift project
#endif
// import RCTLog
#if __has_include(<React/RCTLog.h>)
#import <React/RCTLog.h>
#elif __has_include("RCTLog.h")
#import "RCTLog.h"
#else
#import "React/RCTLog.h"   // Required when used as a Pod in a Swift project
#endif
// import RCTUtils
#if __has_include(<React/RCTUtils.h>)
#import <React/RCTUtils.h>
#elif __has_include("RCTUtils.h")
#import "RCTUtils.h"
#else
#import "React/RCTUtils.h"   // Required when used as a Pod in a Swift project
#endif
// import RCTBridge
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
#import "RCTBridge.h"
#else
#import "React/RCTBridge.h"   // Required when used as a Pod in a Swift project
#endif
// import RCTBridge
#if __has_include(<React/RCTUIManager.h>)
#import <React/RCTUIManager.h>
#elif __has_include("RCTUIManager.h")
#import "RCTUIManager.h"
#else
#import "React/RCTUIManager.h"   // Required when used as a Pod in a Swift project
#endif
#import "GenericShare.h"
#import "WhatsAppShare.h"
#import "GooglePlusShare.h"
#import "EmailShare.h"
#import "InstagramShare.h"

@interface RNShare()

@property (nonatomic, strong) InstagramShare *instagramShare;

@end

@implementation RNShare
  
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(shareSingle:(NSDictionary *)options
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback)
{
    
    NSString *social = [RCTConvert NSString:options[@"social"]];
    if (social) {
        RCTLog(@"Channel: %@", social);
        if([social isEqualToString:@"facebook"]) {
            RCTLog(@"TRY OPEN FACEBOOK");
            GenericShare *shareCtl = [[GenericShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback serviceType: SLServiceTypeFacebook];
        } else if([social isEqualToString:@"twitter"]) {
            RCTLog(@"TRY OPEN Twitter");
            GenericShare *shareCtl = [[GenericShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback serviceType: SLServiceTypeTwitter];
        } else if([social isEqualToString:@"googleplus"]) {
            RCTLog(@"TRY OPEN google plus");
            GooglePlusShare *shareCtl = [[GooglePlusShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        } else if([social isEqualToString:@"whatsapp"]) {
            RCTLog(@"TRY OPEN whatsapp");
            WhatsAppShare *shareCtl = [[WhatsAppShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        } else if([social isEqualToString:@"email"]) {
            RCTLog(@"TRY OPEN email");
            EmailShare *shareCtl = [[EmailShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        } else if ([social isEqualToString:@"instagram"]) {
            _instagramShare = [[InstagramShare alloc] init];
            [_instagramShare shareSingle:options successCallback: ^(NSArray *response) {
                successCallback(response);
                _instagramShare = nil;
            }  failureCallback: ^(NSError *error) {
                failureCallback(error);
                _instagramShare = nil;
            }];
        }
    } else {
        RCTLogError(@"key 'social' missing in options");
        return;
    }
}

RCT_EXPORT_METHOD(shareMultiple:(NSDictionary *)options
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failureCallback:(RCTResponseErrorBlock)failureCallback) {
    NSString *social = [RCTConvert NSString:options[@"social"]];
    if (social) {
        if([social isEqualToString:@"instagram"]) {
            _instagramShare = [[InstagramShare alloc] init];
            [_instagramShare shareMultiple:options successCallback: ^(NSArray *response) {
                successCallback(response);
                _instagramShare = nil;
            } failureCallback: ^(NSError *error) {
                failureCallback(error);
                _instagramShare = nil;
            }];
        }
    } else {
        RCTLogError(@"No exists social key");
        return;
    }
}

@end
