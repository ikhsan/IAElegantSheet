//
//  IAElegantButtonTests.m
//  IAElegantSheet
//
//  Created by Ikhsan Assaat on 4/19/15.
//  Copyright (c) 2015 3kunci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "IAElegantButton.h"

@interface IAElegantButton ()

@property (assign, nonatomic) IAElegantButtonType elegantButtonType;
@property (weak, nonatomic) UIView *lineView;
@property (nonatomic, readonly) CGFloat alphaHighlight;

@end

@interface IAElegantButtonTests : XCTestCase

@end

@implementation IAElegantButtonTests

- (void)testButtonCreation {
    IAElegantButton *button = [IAElegantButton buttonWithTitle:@"title" type:IAElegantButtonTypeDefault baseColor:[UIColor blackColor] block:nil];
    
    XCTAssertNotNil(button, @"Should not be nil");
    XCTAssertEqualObjects(@"title", button.buttonTitle);
    XCTAssertEqualObjects(@"TITLE", [button titleForState:UIControlStateNormal]);
    XCTAssertEqual(IAElegantButtonTypeDefault, button.elegantButtonType);
}

- (void)testButtonCreationWithNilString {
    IAElegantButton *button = [IAElegantButton buttonWithTitle:nil type:IAElegantButtonTypeDefault baseColor:[UIColor blackColor] block:nil];
    
    XCTAssertNotNil(button, @"Should not be nil");
    XCTAssertEqualObjects(@"", button.buttonTitle);
    XCTAssertEqualObjects(@"", [button titleForState:UIControlStateNormal]);
    XCTAssertEqual(IAElegantButtonTypeDefault, button.elegantButtonType);
}

- (void)testButtonCreationWithNilColor {
    IAElegantButton *button = [IAElegantButton buttonWithTitle:nil type:0 baseColor:nil block:nil];
    UIColor *defaultColor = [[UIColor blackColor] colorWithAlphaComponent:button.alphaHighlight];
    
    XCTAssertEqualObjects(defaultColor, button.backgroundColor, @"Button's background default color should be black");
}

- (void)testDestructiveButtonColor {
    IAElegantButton *button = [IAElegantButton buttonWithTitle:nil type:IAElegantButtonTypeDestructive baseColor:nil block:nil];
    UIColor *defaultColor = [[UIColor redColor] colorWithAlphaComponent:button.alphaHighlight];
    
    XCTAssertEqualObjects(defaultColor, button.backgroundColor, @"Destructive button's background default color should be red");
}

- (void)testButtonShouldHaveLine {
    IAElegantButton *button = [IAElegantButton buttonWithTitle:@"title" type:IAElegantButtonTypeDefault baseColor:[UIColor blackColor] block:nil];
    
    XCTAssertNotNil(button.lineView, @"Button should have line");
    XCTAssertTrue([button.subviews containsObject:button.lineView], @"Button should have line as a subview");
}

- (void)testCancelButtonShouldNotHaveLine {
    IAElegantButton *button = [IAElegantButton buttonWithTitle:@"title" type:IAElegantButtonTypeCancel baseColor:[UIColor blackColor] block:nil];
    
    XCTAssertNil(button.lineView, @"Button should have line");
}

- (void)testButtonTouchHighlight {
    IAElegantButton *button = [IAElegantButton buttonWithTitle:@"title" type:IAElegantButtonTypeDefault baseColor:[UIColor blackColor] block:nil];
    
    CGFloat previousAlpha;
    [button.backgroundColor getWhite:nil alpha:&previousAlpha];
    
    [button sendActionsForControlEvents:UIControlEventTouchDown];
    
    CGFloat currentAlpha;
    [button.backgroundColor getWhite:nil alpha:&currentAlpha];
    
    XCTAssertGreaterThan(currentAlpha, previousAlpha, @"Button's background color should be slightly bright");
}

- (void)testButtonTouch {
    XCTestExpectation *tapExpectation = [self expectationWithDescription:@"button tap"];
    __block BOOL isBlockCalled = NO;

    IAElegantButton *button = [IAElegantButton buttonWithTitle:@"title" type:IAElegantButtonTypeDefault baseColor:[UIColor blackColor] block:^{
        isBlockCalled = YES;
        [tapExpectation fulfill];
    }];
    
    UIColor *backgroundColor = button.backgroundColor;
    [button sendActionsForControlEvents:UIControlEventTouchDown];
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    XCTAssertEqualObjects(backgroundColor, button.backgroundColor, @"Button's color should be back to normal");
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssert(isBlockCalled, @"Button's block should be called");
}

@end
