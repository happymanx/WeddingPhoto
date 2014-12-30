//
//  HTCommonMethod.m
//  WeddingPhoto
//
//  Created by Jason on 2014/10/16.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTCommonMethod.h"

@implementation HTCommonMethod

NSString * HTLocalizedString(NSString * translation_key, NSString *nothing) {
    NSString * s = NSLocalizedString(translation_key, nil);
    if (!([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"] || [[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"zh-Hant"] || [[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"zh-Hans"])) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        NSBundle * languageBundle = [NSBundle bundleWithPath:path];
        s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    }

    return s;
}

@end
