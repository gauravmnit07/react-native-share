//
//  EmailShare.m
//  RNShare
//
//  Created by Diseño Uno BBCL on 23-07-16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "EmailShare.h"


@implementation EmailShare
- (void)shareSingle:(NSDictionary *)options
    failureCallback:(RCTResponseErrorBlock)failureCallback
    successCallback:(RCTResponseSenderBlock)successCallback {

    if ([options objectForKey:@"message"] && [options objectForKey:@"message"] != [NSNull null]) {
        NSString *text = [RCTConvert NSString:options[@"message"]];

        RCTLog(@"Try open view");
        
        NSString *subject = @"";
        NSString *message = @"";
        if ([options objectForKey:@"subject"] && [options objectForKey:@"subject"] != [NSNull null]) {
            subject = [RCTConvert NSString:options[@"subject"]];
        }

        message = [RCTConvert NSString:options[@"message"]];

        if ([options objectForKey:@"url"] && [options objectForKey:@"url"] != [NSNull null]) {
            NSString *url = [RCTConvert NSString:options[@"url"]];
            message = [message stringByAppendingString: [@" " stringByAppendingString: options[@"url"]] ];
        }

        NSString * urlWhats = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@", subject, message ];
        NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
            successCallback(@[]);
        } else {
            // Cannot open email
            RCTLog(@"Cannot open email");
            NSString *errorMessage = @"Cannot open email";
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
            NSError *error = [NSError errorWithDomain:@"com.rnshare" code:2 userInfo:userInfo];
            failureCallback(error);
        }
    }

}

@end
