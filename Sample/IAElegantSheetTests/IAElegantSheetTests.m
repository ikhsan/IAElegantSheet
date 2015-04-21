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

@interface IAElegantSheet (Private)

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) IAElegantButton *destructiveButton;
@property (nonatomic, readonly) IAElegantButton *cancelButton;
@property (nonatomic, assign) CGFloat transitionDuration;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (assign, nonatomic, getter=isShowing) BOOL showing;

- (void)showInView:(UIView *)view completion:(void (^)())completion;
- (void)dismissWithCompletion:(void (^)())completion;

@end

@interface IAElegantSheetTests : XCTestCase {
    UIView *view;
    IAElegantSheet *sheet;
}

@end

@implementation IAElegantSheetTests

- (void)setUp {
    [super setUp];

    sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
    sheet.transitionDuration = 0.0f;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 768)];
}

- (void)tearDown {
    view = nil;
    sheet = nil;

    [super tearDown];
}

- (void)testSheetInitializersReturnsValidSheet {
    XCTAssertNotNil(sheet, @"Should not be nil");
    XCTAssertEqualObjects(@"TITLE", sheet.titleLabel.text, @"Should have correct title");
    
    IAElegantSheet *sheet2 = [IAElegantSheet elegantSheetWithTitle:@"title2"];
    XCTAssertNotNil(sheet2, @"Should not be nil");
    XCTAssertEqualObjects(@"TITLE2", sheet2.titleLabel.text, @"Should have correct title");
}

- (void)testSheetShouldHaveCancelButtonByDefault {
    XCTAssertEqual(1, sheet.buttons.count, @"Should have one button, cancel");

    IAElegantButton *button = sheet.buttons.firstObject;
    XCTAssertEqualObjects(@"Cancel", button.buttonTitle);
}

- (void)testSheetShouldHaveCorrectSetterForCancelButton {
    XCTestExpectation *tapExpectation = [self expectationWithDescription:@"cancel tap"];
    __block BOOL isCancelled = NO;

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

- (void)testSheetSettingDestructiveButtonTwiceShouldNotMakeDuplicates {
    XCTestExpectation *tapExpectation = [self expectationWithDescription:@"destructive tap"];
    __block BOOL isDestructed = NO;

    [sheet setDestructiveButtonWithTitle:@"Blow some rockets" block:nil];
    XCTAssertEqualObjects(@"Blow some rockets", sheet.destructiveButton.buttonTitle, @"Should changed text for the destructive button");

    [sheet setDestructiveButtonWithTitle:@"Blast some laser" block:^{
        isDestructed = YES;
        [tapExpectation fulfill];
    }];

    sheet.destructiveButton.buttonAction();
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(2, sheet.buttons.count, @"Should have only cancel and destructive button");
    XCTAssertEqualObjects(@"Blast some laser", sheet.destructiveButton.buttonTitle, @"Should changed text for the destructive button");
    XCTAssertTrue(isDestructed, @"Destructive block should be called");
}

- (void)testSheetShouldAddButtonsCorrectly {
    [sheet addButtonsWithTitle:@"a" block:nil];
    [sheet addButtonsWithTitle:@"b" block:nil];
    [sheet addButtonsWithTitle:@"c" block:nil];

    XCTAssertEqual(4, sheet.buttons.count, @"Sheet should have correct total of buttons");
}

- (void)testSheetShouldHaveCorrectButtonsOrder {
    [sheet setCancelButtonWithTitle:@"d" block:nil];
    [sheet setDestructiveButtonWithTitle:@"c" block:nil];
    [sheet addButtonsWithTitle:@"a" block:nil];
    [sheet addButtonsWithTitle:@"b" block:nil];

    IAElegantButton *a = sheet.buttons[0];
    IAElegantButton *b = sheet.buttons[1];
    IAElegantButton *c = sheet.buttons[2];
    IAElegantButton *d = sheet.buttons[3];

    XCTAssertEqualObjects(@"a", a.buttonTitle, @"Normal buttons' order should not be changed");
    XCTAssertEqualObjects(@"b", b.buttonTitle, @"Normal buttons' order should not be changed");
    XCTAssertEqualObjects(@"c", c.buttonTitle, @"Destructive button should be before cancel button");
    XCTAssertEqualObjects(@"d", d.buttonTitle, @"Cacnel button should be the last button");

}

- (void)testSheetShowInsideViewShouldAppearInsideView {
    [sheet showInView:view];
    XCTAssertTrue([view.subviews containsObject:sheet], @"View should have sheet as a subview");
}

- (void)testSheetShowInsideViewTwiceShouldNotAddMoreButtons {
    [sheet addButtonsWithTitle:@"a" block:nil];
    [sheet showInView:view];
    [sheet showInView:view];

    NSArray *buttons = [sheet.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *subview, NSDictionary *bindings) {
        return [subview isKindOfClass:IAElegantButton.class];
    }]];
    XCTAssertEqual(2, buttons.count, @"Should still have only two buttons");
}

- (void)testSheetShowInsideViewShouldChangeItsStatus {
    XCTestExpectation *shownExpectation = [self expectationWithDescription:@"show animation is finished"];
    __block BOOL isAnimationFinished = NO;

    [sheet showInView:view completion:^{
        isAnimationFinished = YES;
        [shownExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(sheet.isShowing, @"Sheet should be shown");
}

- (void)testSheetDismissShouldRemoveView {
    XCTestExpectation *dismissedExpectation = [self expectationWithDescription:@"dismiss animation is finished"];
    __block BOOL isAnimationFinished = NO;

    [sheet showInView:view completion:^{
        [sheet dismissWithCompletion:^{
            isAnimationFinished = YES;
            [dismissedExpectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertFalse([view.subviews containsObject:sheet], @"View should have sheet as a subview");
    XCTAssertFalse(sheet.showing, @"Sheet should be hidden");
}

@end
