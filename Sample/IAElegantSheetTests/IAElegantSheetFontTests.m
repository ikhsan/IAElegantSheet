//
//  IAElegantSheetFontTests.m
//  IAElegantSheet
//
//  Created by Ikhsan Assaat on 4/19/15.
//  Copyright (c) 2015 3kunci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "UIFont+ElegantSheet.h"

@interface IAElegantSheetFontTests : XCTestCase

@end

@implementation IAElegantSheetFontTests

- (void)testElegantFont {
    UIFont *elegantFont = [UIFont elegantFontWithSize:10];
    XCTAssertEqual(elegantFont.pointSize, 10, @"Should have the correct font size");
    XCTAssertEqualObjects(elegantFont.fontName, @"RobotoCondensed-Regular", @"Should have the correct font name");
}

- (void)testBoldElegantFont {
    UIFont *elegantFont = [UIFont boldElegantFontWithSize:12];
    XCTAssertEqual(elegantFont.pointSize, 12, @"Should have the correct font size");
    XCTAssertEqualObjects(elegantFont.fontName, @"RobotoCondensed-Bold", @"Should have the correct font name");
}

@end
