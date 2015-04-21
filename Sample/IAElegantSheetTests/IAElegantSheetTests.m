//
//  IAElegantSheetTests.m
//  IAElegantSheetTests
//
//  Created by Ikhsan Assaat on 4/19/15.
//  Copyright (c) 2015 3kunci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "IAElegantSheet.h"
#import "IAElegantButton.h"

@interface IAElegantSheet (Test)

@property (weak, nonatomic) UILabel *titleLabel;
@property (nonatomic, readonly) CGFloat titleHeight;
@property (nonatomic, readonly) CGFloat buttonHeight;
@property (nonatomic, readonly) CGFloat transitionDuration;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (assign, nonatomic, getter=isShowing) BOOL showing;

@property (nonatomic, readonly) IAElegantButton *destructiveButton;
@property (nonatomic, readonly) IAElegantButton *cancelButton;

@end

@implementation IAElegantSheet (Test)

@dynamic titleLabel, titleHeight, buttonHeight, buttons, transitionDuration, showing, destructiveButton, cancelButton;

- (CGFloat)transitionDuration { return 0.1f; }

@end


@interface IAElegantSheetTests : XCTestCase

@property (nonatomic, strong) UIView *view;

@end

@implementation IAElegantSheetTests

- (void)setUp {
    [super setUp];

    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 768)];
}

- (void)tearDown {
    self.view = nil;

    [super tearDown];
}

- (void)testSheetInitializersReturnsValidSheet {
    IAElegantSheet *sheet1 = [[IAElegantSheet alloc] initWithTitle:@"title1"];
    XCTAssertNotNil(sheet1, @"Should not be nil");
    XCTAssertEqualObjects(@"TITLE1", sheet1.titleLabel.text, @"Should have correct title");
    
    IAElegantSheet *sheet2 = [IAElegantSheet elegantSheetWithTitle:@"title2"];
    XCTAssertNotNil(sheet2, @"Should not be nil");
    XCTAssertEqualObjects(@"TITLE2", sheet2.titleLabel.text, @"Should have correct title");
}

- (void)testSheetShouldHaveCancelButtonByDefault {
    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];

    XCTAssertEqual(1, sheet.buttons.count, @"Should have one button, cancel");

    IAElegantButton *button = sheet.buttons.firstObject;
    XCTAssertEqualObjects(@"Cancel", button.buttonTitle);
}

- (void)testSheetShouldHaveCorrectSetterForCancelButton {
    XCTestExpectation *tapExpectation = [self expectationWithDescription:@"cancel tap"];
    __block BOOL isCancelled = NO;

    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
    [sheet setCancelButtonWithTitle:@"Abort" block:^{
        isCancelled = YES;
        [tapExpectation fulfill];
    }];

    IAElegantButton *button = sheet.cancelButton;
    XCTAssertEqualObjects(@"Abort", button.buttonTitle, @"Should changed text for the cancel button");

    button.buttonAction();
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(isCancelled, @"Cancel inside block should be called");
}

- (void)testSheetShouldHaveCorrectSetterForDestructiveButton {
    XCTestExpectation *tapExpectation = [self expectationWithDescription:@"destructive tap"];
    __block BOOL isDestructed = NO;

    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
    [sheet setDestructiveButtonWithTitle:@"Blow some rockets" block:^{
        isDestructed = YES;
        [tapExpectation fulfill];
    }];

    IAElegantButton *button = sheet.destructiveButton;
    XCTAssertEqualObjects(@"Blow some rockets", button.buttonTitle, @"Should changed text for the destructive button");

    button.buttonAction();
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(isDestructed, @"Destructive block should be called");
}

- (void)testSheetShouldAddButtonsCorrectly {
    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
    [sheet addButtonsWithTitle:@"a" block:nil];
    [sheet addButtonsWithTitle:@"b" block:nil];
    [sheet addButtonsWithTitle:@"c" block:nil];

    XCTAssertEqual(4, sheet.buttons.count, @"Sheet should have correct total of buttons");
}

- (void)testSheetShouldHaveCorrectButtonsOrder {}

- (void)testSheetShowInsideViewShouldAppearInsideView {
    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
    [sheet showInView:self.view];

    // test in the next run loop
    dispatch_after((uint64_t)0.0, dispatch_get_main_queue(), ^{
        XCTAssertTrue([self.view.subviews containsObject:sheet], @"View should have sheet as a subview");
        XCTAssertTrue(sheet.isShowing, @"Sheet should be shown");
    });
}

- (void)testSheetDismissShouldRemoveView {
    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
    [sheet showInView:self.view];
    [sheet dismiss];

    // test in the next run loop
    dispatch_after((uint64_t)0.0, dispatch_get_main_queue(), ^{
        XCTAssertFalse([self.view.subviews containsObject:sheet], @"View should have sheet as a subview");
        XCTAssertFalse(sheet.isShowing, @"Sheet should be hidden");
    });
}

- (void)testSheetShouldTapAnyButtonShouldDismissIt {}

@end
