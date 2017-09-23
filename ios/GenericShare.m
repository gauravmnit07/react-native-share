//
//  GenericShare.m
//  RNShare
//
//  Created by Diseño Uno BBCL on 23-07-16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "GenericShare.h"

@implementation GenericShare
- (void)shareSingle:(NSDictionary *)options
    failureCallback:(RCTResponseErrorBlock)failureCallback
    successCallback:(RCTResponseSenderBlock)successCallback
    serviceType:(NSString*)serviceType {

    RCTLog(@"Try open view");
    if([SLComposeViewController isAvailableForServiceType:serviceType]) {

        SLComposeViewController *composeController = [SLComposeViewController  composeViewControllerForServiceType:serviceType];

        NSURL *URL = [RCTConvert NSURL:options[@"url"]];
        if (URL) {
            if (URL.fileURL || [URL.scheme.lowercaseString isEqualToString:@"data"]) {
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:URL
                                                     options:(NSDataReadingOptions)0
                                                       error:&error];
                if (!data) {
                    failureCallback(error);
                    return;
                }
                UIImage *image = [UIImage imageWithData: data];
                [composeController addImage:image];

            } else {
                [composeController addURL:URL];
            }
        }

        if ([options objectForKey:@"message"] && [options objectForKey:@"message"] != [NSNull null]) {
            NSString *text = [RCTConvert NSString:options[@"message"]];
            [composeController setInitialText:text];
        }
        composeController.completionHandler = ^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
                successCallback(@[@"success"]);
            } else {
                NSString *errorMessage = @"Cancelled";
                NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
                NSError *error = [NSError errorWithDomain:@"com.rnshare" code:2 userInfo:userInfo];
                failureCallback(error);
            }
        };
        UIViewController *ctrl = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        while (ctrl.presentedViewController) {
            ctrl = ctrl.presentedViewController;
        }
        [ctrl presentViewController:composeController animated:YES completion:Nil];
      } else {
        NSString *errorMessage = @"Not installed";
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
        NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];

        RCTLog(errorMessage);
        failureCallback(error);

        NSString *escapedString = [options[@"message"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

        if ([options[@"social"] isEqualToString:@"twitter"]) {
          NSString *URL = [NSString stringWithFormat:@"https://twitter.com/intent/tweet?message=%@&url=%@", escapedString, options[@"url"]];
          [self openScheme:URL];
        }

        if ([options[@"social"] isEqualToString:@"facebook"]) {
          NSString *URL = [NSString stringWithFormat:@"https://www.facebook.com/sharer/sharer.php?u=%@", options[@"url"]];
          [self openScheme:URL];
        }

      }
  }
  - (void)openScheme:(NSString *)scheme {
      UIApplication *application = [UIApplication sharedApplication];
      NSURL *schemeURL = [NSURL URLWithString:scheme];

      if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
          [application openURL:schemeURL options:@{} completionHandler:nil];
          RCTLog(@"Open %@: %d", schemeURL);
      }

  }

  @end
