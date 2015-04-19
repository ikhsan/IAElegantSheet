//
//  UIFont+ElegantSheet.m
//  IAElegantSheet
//
//  Created by Ikhsan Assaat on 4/19/15.
//  Copyright (c) 2015 3kunci. All rights reserved.
//

#import "UIFont+ElegantSheet.h"
#import <CoreText/CoreText.h>

@implementation UIFont (ElegantSheet)

+ (UIFont *)elegantFontWithSize:(CGFloat)size {
    static NSString *fontName = @"RobotoCondensed-Regular";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadFont:fontName];
    });
    
    return [UIFont fontWithName:fontName size:size];
}

+ (UIFont *)boldElegantFontWithSize:(CGFloat)size {
    static NSString *fontName = @"RobotoCondensed-Bold";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadFont:fontName];
    });
    
    return [UIFont fontWithName:fontName size:size];
}

+ (void)loadFont:(NSString *)fontName {
    NSURL *url = [[NSBundle mainBundle] URLForResource:fontName withExtension:@"ttf"];
    CFErrorRef error;
    CTFontManagerRegisterFontsForURL((__bridge CFURLRef)url, kCTFontManagerScopeNone, &error);
    error = nil;
}


@end
