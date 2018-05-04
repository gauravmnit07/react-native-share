//
//  PhotoLibraryUtility.h
//  RNShare
//
//  Created by Mudit Jumnani on 03/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface RNSPhotoLibraryUtility : NSObject

+ (void)saveAssetOfType:(PHAssetMediaType)type withURL:(NSURL *)assetURL inCollectionWithName:(NSString *)collectionName withCompletion:(void (^)(PHObjectPlaceholder *assetPlaceholder, NSError *error))completionBlock;

+ (void)saveAssetOfType:(PHAssetMediaType)type withURL:(NSURL *)assetURL inAssetCollection:(PHAssetCollection *)assetCollection withCompletion:(void (^)(PHObjectPlaceholder *assetPlaceholder, NSError *error))completionBlock;

@end
