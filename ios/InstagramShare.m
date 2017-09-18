//
//  InstagramShare.m
//  RNShare
//
//  Created by Gaurav Bansal on 8/14/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Social/SLComposeViewController.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "InstagramShare.h"

@interface SLComposeViewController (InstagramAttachment)

- (BOOL)addImageURL:(NSURL *)url;
- (BOOL)addVideoURL:(NSURL *)url;

@end

@implementation SLComposeViewController (InstagramAttachment)

- (BOOL)addImageURL:(NSURL *)url {
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithItem:url typeIdentifier:(NSString *)kUTTypeImage];
    return [self addAttachmentItem:itemProvider];
}

- (BOOL)addVideoURL:(NSURL *)url {
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithItem:url typeIdentifier:(NSString *)kUTTypeMovie];
    return [self addAttachmentItem:itemProvider];
}

- (BOOL)addAttachmentItem:(NSItemProvider *)itemProvider {
    NSExtensionItem *extensionItem = [NSExtensionItem new];
    extensionItem.attachments = [NSArray arrayWithObject:itemProvider];
    if (![self respondsToSelector:@selector(addExtensionItem:)]) {
        return NO;
    }
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    
    return [self performSelector:@selector(addExtensionItem:) withObject:extensionItem];
    
    #pragma clang diagnostic pop
}

@end

@implementation InstagramShare

- (void)shareSingle:(NSDictionary *)options
    failureCallback:(RCTResponseErrorBlock)failureCallback
    successCallback:(RCTResponseSenderBlock)successCallback {
    
    NSString *instagramServiceType = @"com.burbn.instagram.shareextension";
    if([SLComposeViewController isAvailableForServiceType:instagramServiceType]) {
        NSString *mediaType = options[@"type"];
        NSURL *mediaURL = [RCTConvert NSURL:options[@"url"]];
        
        SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:instagramServiceType];
        if ([options objectForKey:@"message"] && [options objectForKey:@"message"] != [NSNull null]) {
            NSString *text = [RCTConvert NSString:options[@"message"]];
            [composeController setInitialText:text];
        }
        
        if ([mediaType isEqualToString:@"image"]) {
            if ([composeController addImageURL:mediaURL]) {
                [self _openComposeViewController:composeController withSuccessCallback:successCallback failureCallback:failureCallback];
            } else {
                if (mediaURL.fileURL || [mediaURL.scheme.lowercaseString isEqualToString:@"data"]) {
                    NSError *error;
                    NSData *data = [NSData dataWithContentsOfURL:mediaURL
                                                         options:(NSDataReadingOptions)0
                                                           error:&error];
                    if (!data) {
                        failureCallback(error);
                        return;
                    }
                    UIImage *image = [UIImage imageWithData: data];
                    [composeController addImage:image];
                    [self _openComposeViewController:composeController withSuccessCallback:successCallback failureCallback:failureCallback];
                } else {
                    __weak typeof(self) weakSelf = self;
                    [self _downloadMediaForMediaUrl:mediaURL withCompletion:^(NSURL *assetURL) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:assetURL]];
                        [composeController addImage:image];
                        [strongSelf _openComposeViewController:composeController withSuccessCallback:successCallback failureCallback:failureCallback];
                    } andFailure:^(NSError *downloadError) {
                        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey:downloadError.localizedFailureReason};
                        NSError *error = [NSError errorWithDomain:@"com.rnshare" code:3 userInfo:userInfo];
                        failureCallback(error);
                    }];
                }
            }
        } else if ([mediaType isEqualToString:@"video"]) {
            if ([composeController addVideoURL:mediaURL]) {
                [self _openComposeViewController:composeController withSuccessCallback:successCallback failureCallback:failureCallback];
            } else {
                NSString *errorMessage = @"Failed to post video";
                NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
                NSError *error = [NSError errorWithDomain:@"com.rnshare" code:3 userInfo:userInfo];
                failureCallback(error);
            }
        } else {
            NSString *errorMessage = @"Unsupported media type";
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
            NSError *error = [NSError errorWithDomain:@"com.rnshare" code:3 userInfo:userInfo];
            failureCallback(error);
        }
        
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
        NSString *errorMessage = @"Unsupported extension for instagram";
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
        NSError *error = [NSError errorWithDomain:@"com.rnshare" code:3 userInfo:userInfo];
        failureCallback(error);
    } else {
        NSString *errorMessage = @"Not installed";
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
        NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];
        
        failureCallback(error);
    }
}

- (void)_openComposeViewController:(SLComposeViewController *)composeController withSuccessCallback:(RCTResponseSenderBlock)successCallback failureCallback:(RCTResponseErrorBlock)failureCallback {
    
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
    [ctrl presentViewController:composeController animated:YES completion:Nil];
}

- (void)openScheme:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *schemeURL = [NSURL URLWithString:scheme];
    
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:schemeURL options:@{} completionHandler:nil];
        RCTLog(@"Open %@: %d", schemeURL);
    }
    
}

- (void)_downloadMediaForMediaUrl:(NSURL *)mediaUrl withCompletion:(void (^)(NSURL *assetURL))completionBlock andFailure:(void (^)(NSError *error))failureBlock {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:mediaUrl]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:15.0];
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error && location) {
            completionBlock(location);
        } else {
            failureBlock(error);
        }
    }];
    [downloadTask resume];
}

@end
