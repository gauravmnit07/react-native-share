//
//  NSStringAdditons.m
//  RNShare
//
//  Created by Mudit Jumnani on 03/05/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "NSStringRNShareAdditons.h"

@implementation NSString(RNShareAdditions)

- (BOOL)isEmpty {
    NSString *text = [self copy];
    if (!text || [text length] == 0 || [@"" isEqualToString:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
        return YES;
    }
    return NO;
}

@end
