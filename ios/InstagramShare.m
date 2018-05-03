//
//  InstagramShare.m
//  RNShare
//
//  Created by Mudit Jumnani on 03/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "InstagramShare.h"
#import <Social/SLComposeViewController.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RNSPhotoLibraryUtility.h"
#import "RNSTemporaryFileStorage.h"
#import "RNSFileStorageUtils.h"
#import "NSStringRNShareAdditons.h"

#define kMediaAlbumTitle NSLocalizedString(@"Instagram", @"title for new media album")

static NSTimeInterval timeInterval = 10.0;

@implementation InstagramShare

- (void)shareSingle:(NSDictionary *)options successCallback:(void (^)(NSArray *response))successCallback failureCallback:(void (^)(NSError *error))failureCallback {
    if(![self _canOpenInInstagram]) {
        failureCallback([self getErrorWithMessage:@"Instagram app not installed"]);
        return;
    }
    NSString *mediaType = options[@"type"];
    NSString *url = [RCTConvert NSString:options[@"url"]];
    NSURL *mediaURL = [NSURL URLWithString:url];
    NSString *text;
    if ([options objectForKey:@"message"] && [options objectForKey:@"message"] != [NSNull null]) {
        text = [RCTConvert NSString:options[@"message"]];
    }
    
    PHAssetMediaType assetMediaType;
    if ([mediaType isEqualToString:@"image"]) assetMediaType = PHAssetMediaTypeImage;
    else if ([mediaType isEqualToString:@"video"]) assetMediaType = PHAssetMediaTypeVideo;
    else {
        failureCallback([self getErrorWithMessage:@"Unsupported media type"]);
        return;
    }
    if (mediaURL.fileURL || [mediaURL.scheme.lowercaseString isEqualToString:@"data"]) {
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:mediaURL
                                             options:(NSDataReadingOptions)0
                                               error:&error];
        if (!data) {
            failureCallback(error);
            return;
        }
        
        [self shareMediaOnInstagramOfType:assetMediaType withUrl:mediaURL andCaption:text successCallback: successCallback failureCallback: failureCallback andOptions:options];
    } else {
        [self _downloadMediaForMediaUrl:mediaURL withCompletion:^(NSURL *assetURL, NSError *downloadError) {
            if (downloadError != nil) {
                failureCallback(downloadError);
                return;
            }
            [self shareMediaOnInstagramOfType:assetMediaType withUrl:assetURL andCaption:text successCallback: successCallback failureCallback: failureCallback andOptions:options];
        }];
    }
}

- (void)shareMultiple:(NSDictionary *)options successCallback:(void (^)(NSArray *response))successCallback failureCallback:(void (^)(NSError *error))failureCallback {
    if(![self _canOpenInInstagram]) {
        failureCallback([self getErrorWithMessage:@"Instagram app not installed"]);
        return;
    }
    NSString *alertMessage =  [RCTConvert NSString:options[@"alertMessage"]];
    NSArray *mediaUrls = [RCTConvert NSArray:options[@"urls"]];
    if ([mediaUrls count] == 0) {
        failureCallback([self getErrorWithMessage:@"No media urls present"]);
        return;
    }
    
    NSString *text;
    if ([options objectForKey:@"message"] && [options objectForKey:@"message"] != [NSNull null]) {
        text = [RCTConvert NSString:options[@"message"]];
    }
    
    __block NSInteger mediaCount = [mediaUrls count];
    __block NSMutableArray *assetUrls = [NSMutableArray new];
    NSString *url = [RCTConvert NSString:mediaUrls[0]];
    __block NSError *downloadError;
    __block BOOL hasError = false;
    __weak typeof(self) weakSelf = self;
    NSURL *mediaURL  = [NSURL URLWithString:url];
    if (mediaURL.fileURL || [mediaURL.scheme.lowercaseString isEqualToString:@"data"]) {
        for (NSString *mediaUri in mediaUrls) {
            NSURL *assetUrl =  [NSURL URLWithString:mediaUri];
            NSString *albumName = kMediaAlbumTitle;
            if ([options valueForKey:@"albumName"] != nil) {
                albumName = [options valueForKey:@"albumName"];
            }
            [RNSPhotoLibraryUtility saveAssetOfType:PHAssetMediaTypeImage withURL:assetUrl inCollectionWithName:albumName withCompletion:^(PHObjectPlaceholder *assetPlaceholder, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                mediaCount--;
                if (mediaCount == 0) {
                    if (downloadError) {
                        failureCallback(downloadError);
                        return;
                    } else if (hasError) {
                        failureCallback([strongSelf getErrorWithMessage:@"Failed to download asset"]);
                        return;
                    }
                }
                if (!assetPlaceholder || error) {
                    hasError = true;
                    if (error) {
                        downloadError = error;
                    }
                } else {
                    [assetUrls addObject:assetUrl];
                    if (mediaCount == 0 && [assetUrls count] == [mediaUrls count]) {
                        if ([NSThread isMainThread]) {
                            [strongSelf copyCaptionToClipboard:text];
                            [strongSelf showAlertForManualInstagramPublishingWithMessage:alertMessage withSuccessCallback: successCallback andFailureCallback: failureCallback];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [strongSelf copyCaptionToClipboard:text];
                                [strongSelf showAlertForManualInstagramPublishingWithMessage:alertMessage withSuccessCallback: successCallback andFailureCallback: failureCallback];
                            });
                        }
                    }
                }
            }];
        }
    } else {
        [self downloadAssets:mediaUrls successCallback:successCallback failureCallback:failureCallback caption:text withOptions:options andAlertMessage: alertMessage];
    }
}

- (void)downloadAssets:(NSArray *)mediaUrls successCallback:(void (^)(NSArray *response))successCallback failureCallback:(void (^)(NSError *error))failureCallback caption:(NSString *)caption withOptions:(NSDictionary *)options andAlertMessage:(NSString *)alertMessage {
    __weak typeof(self) weakSelf = self;
    __block NSInteger mediaCount = [mediaUrls count];
    __block NSMutableArray *assetUrls = [NSMutableArray new];
    void (^CompletionBlock)() = ^(NSURL *assetURL, NSError *downloadError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (downloadError != nil) {
                failureCallback(downloadError);
                return;
            }
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSString *albumName = kMediaAlbumTitle;
            if ([options valueForKey:@"albumName"] != nil) {
                albumName = [options valueForKey:@"albumName"];
            }
            [RNSPhotoLibraryUtility saveAssetOfType:PHAssetMediaTypeImage withURL:assetURL inCollectionWithName:albumName withCompletion:^(PHObjectPlaceholder *assetPlaceholder, NSError *error) {
                mediaCount--;
                if (!assetPlaceholder || error) {
                    if (error) {
                        failureCallback(error);
                        return;
                    } else {
                        failureCallback([self getErrorWithMessage:@"Failed to download asset"]);
                        return;
                    }
                } else {
                    [assetUrls addObject:assetURL];
                    if (mediaCount == 0 && [assetUrls count] == [mediaUrls count]) {
                        if ([NSThread isMainThread]) {
                            [strongSelf copyCaptionToClipboard:caption];
                            [strongSelf showAlertForManualInstagramPublishingWithMessage:alertMessage withSuccessCallback: successCallback andFailureCallback: failureCallback];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [strongSelf copyCaptionToClipboard:caption];
                                [strongSelf showAlertForManualInstagramPublishingWithMessage:alertMessage withSuccessCallback: successCallback andFailureCallback: failureCallback];
                            });
                        }
                    }
                }
            }];
        });
    };
    for(NSString *mediaUrl in mediaUrls) {
        [self _downloadMediaForMediaUrl:[NSURL URLWithString:mediaUrl] withCompletion:CompletionBlock];
    }
}

- (void)shareMediaOnInstagramOfType:(PHAssetMediaType)type withUrl:(NSURL *)mediaUrl andCaption:(NSString *)caption successCallback:(void (^)(NSArray *response))successCallback failureCallback:(void (^)(NSError *error))failureCallback andOptions:(NSDictionary *)options {
    __weak typeof(self) weakSelf = self;
    NSString *albumName = kMediaAlbumTitle;
    if ([options valueForKey:@"albumName"] != nil) {
        albumName = [options valueForKey:@"albumName"];
    }
    [RNSPhotoLibraryUtility saveAssetOfType:type withURL:mediaUrl inCollectionWithName:albumName withCompletion:^(PHObjectPlaceholder *assetPlaceholder, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!assetPlaceholder || error) {
            if (error) {
                failureCallback(error);
                return;
            }  else {
                failureCallback([strongSelf getErrorWithMessage:@"Failed to download asset"]);
                return;
            }
        }
        NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@", assetPlaceholder.localIdentifier]];
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
            [self copyCaptionToClipboard:caption];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:instagramURL options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:instagramURL];
            }
            successCallback(@[@{@"success": @"true"}]);
        } else {
            failureCallback([strongSelf getErrorWithMessage:@"Instagram app not installed"]);
        }
    }];
};

#pragma mark -

- (BOOL)_canOpenInInstagram {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        return NO;
    }
    return YES;
}

- (void)copyCaptionToClipboard:(NSString *)caption {
    NSString *text = caption ?: @"";
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setValue:text forPasteboardType:@"public.utf8-plain-text"];
}

#pragma mark -

- (void)_downloadMediaForMediaUrl:(NSURL *)mediaUrl withCompletion:(void (^)(NSURL *assetURL, NSError * error))completionBlock {
    NSString *fileName = [[NSUUID UUID] UUIDString];
    NSString *pathExtension = [[mediaUrl pathExtension] lowercaseString];
    fileName = [fileName stringByAppendingPathExtension:pathExtension];
    if ([[RNSTemporaryFileStorage sharedInstance] fileExistsInTemporaryStorage:fileName]) {
        NSURL *assetURL = [NSURL fileURLWithPath:[[RNSTemporaryFileStorage sharedInstance] filePathUrlForFileName:fileName]];
        completionBlock(assetURL, nil);
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:mediaUrl
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:timeInterval];
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error && location) {
            BOOL didSave = [[RNSTemporaryFileStorage sharedInstance] moveFileAtLocation:location toTemporaryFile:fileName];
            if (didSave) {
                NSURL *assetURL = [NSURL fileURLWithPath:[[RNSTemporaryFileStorage sharedInstance] filePathUrlForFileName:fileName]];
                completionBlock(assetURL, nil);
            } else {
                completionBlock(nil, [strongSelf getErrorWithMessage:@"Failed to download asset"]);
            }
        } else {
            completionBlock(nil, error);
        }
    }];
    [downloadTask resume];
}

#pragma mark -

- (void)showAlertForManualInstagramPublishingWithMessage:(NSString *)alertMessage withSuccessCallback:(void (^)(NSArray *response))successCallback  andFailureCallback:(RCTResponseErrorBlock)failureCallback {
    UIViewController *presenter = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (presenter.presentedViewController) {
        presenter = presenter.presentedViewController;
    }
    if (!presenter) {
        failureCallback([self getErrorWithMessage:@"Unable to find presenter"]);
        return;
    }
    
    NSString *message = alertMessage ? alertMessage : [self carouselPublishingAlertString];
    NSString *title = NSLocalizedString(@"Publish Instructions", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *postButtonTitle = NSLocalizedString(@"Publish", nil);
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:postButtonTitle style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self openInstagramAppForManualPublishing];
                                                              successCallback(@[@{@"success": @"true"}]);
                                                          }];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    
    
    [presenter presentViewController:alert animated:YES completion: nil];
}

#pragma mark -

- (void)openInstagramAppForManualPublishing {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:instagramURL options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:instagramURL];
        }
    }
}

#pragma mark -

- (NSString *)carouselPublishingAlertString {
    NSString *step1 = NSLocalizedString(@"Step 1: Tap on add button.", nil);
    NSString *step2 = NSLocalizedString(@"Step 2: Tap on Multiple icon on Instagram.", nil);
    NSString *step3 = NSLocalizedString(@"Step 3: Select media from your camera roll.", nil);
    NSString *step4 = NSLocalizedString(@"Step 4: Double tap caption field and paste caption.", nil);
    return [NSString stringWithFormat:@"\r%@\r\r%@\r\r%@\r\r%@\r", step1, step2, step3, step4];
}

#pragma mark -
- (NSError *)getErrorWithMessage:(NSString *)errorMessage {
    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
    return [NSError errorWithDomain:@"com.share" code:3 userInfo:userInfo];
}

@end
