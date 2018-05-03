//
//  PhotoLibraryUtility.m
//  RNShare
//
//  Created by Mudit Jumnani on 03/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNSPhotoLibraryUtility.h"

@implementation RNSPhotoLibraryUtility

+ (void)saveAssetOfType:(PHAssetMediaType)type withURL:(NSURL *)assetURL inCollectionWithName:(NSString *)collectionName withCompletion:(void (^)(PHObjectPlaceholder *assetPlaceholder, NSError *error))completionBlock {
    [self fetchAssetCollectionWithName:collectionName withCompletion:^(PHAssetCollection *assetCollection, NSError *error) {
        if (!assetCollection) {
            completionBlock(nil, error);
        } else {
            [self saveAssetOfType:type withURL:assetURL inAssetCollection:assetCollection withCompletion:completionBlock];
        }
    }];
}

+ (void)saveAssetOfType:(PHAssetMediaType)type withURL:(NSURL *)assetURL inAssetCollection:(PHAssetCollection *)assetCollection withCompletion:(void (^)(PHObjectPlaceholder *assetPlaceholder, NSError *error))completionBlock {
    __block PHObjectPlaceholder *assetPlaceholder;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetRequest;
        PHAssetCollectionChangeRequest *albumChangeRequest;
        if (type == PHAssetMediaTypeVideo) {
            assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:assetURL];
            albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        } else {
            PHFetchResult *photosAsset = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:assetURL];
            albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection assets:photosAsset];
        }
        assetPlaceholder = assetRequest.placeholderForCreatedAsset;
        [albumChangeRequest addAssets:[NSArray arrayWithObject:assetPlaceholder]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            completionBlock(assetPlaceholder, nil);
        } else {
            completionBlock(nil, error);
        }
    }];
}

+ (void)fetchAssetCollectionWithName:(NSString *)collectionName withCompletion:(void (^)(PHAssetCollection *assetCollection, NSError *error))completionBlock {
    __block PHAssetCollection *assetCollection;
    __block PHObjectPlaceholder *assetCollectionPlaceholder;
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", collectionName];
    __block PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    if (collections.count > 0) {
        assetCollection = (PHAssetCollection *)[collections firstObject];
        completionBlock(assetCollection, nil);
    } else {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *createAlbumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:collectionName];
            assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection;
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                collections = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:[NSArray arrayWithObject:assetCollectionPlaceholder.localIdentifier] options:nil];
                assetCollection = [collections firstObject];
                completionBlock(assetCollection, nil);
            } else {
                completionBlock(nil, error);
            }
        }];
    }
}


@end
