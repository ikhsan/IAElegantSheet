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

@property (weak, nonatomic) UILabel *titleLabel;
@property (nonatomic, readonly) CGFloat titleHeight;
@property (nonatomic, readonly) CGFloat buttonHeight;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (assign, nonatomic, getter=isShowing) BOOL showing;

@property (nonatomic, readonly) IAElegantButton *destructiveButton;
@property (nonatomic, readonly) IAElegantButton *cancelButton;

- (void)showInView:(UIView *)view completion:(void (^)())completion;
- (void)dismissWithCompletion:(void (^)())completion;

@end

@interface IAElegantSheet (Duration)
@property (nonatomic, readonly) CGFloat transitionDuration;
@end

@implementation IAElegantSheet (Duration)
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

- (void)testSheetSettingDestructiveButtonTwiceShouldNotMakeDuplicates {
    XCTestExpectation *tapExpectation = [self expectationWithDescription:@"destructive tap"];
    __block BOOL isDestructed = NO;

    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
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
    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
    [sheet addButtonsWithTitle:@"a" block:nil];
    [sheet addButtonsWithTitle:@"b" block:nil];
    [sheet addButtonsWithTitle:@"c" block:nil];

    XCTAssertEqual(4, sheet.buttons.count, @"Sheet should have correct total of buttons");
}

- (void)testSheetShouldHaveCorrectButtonsOrder {
    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
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
    XCTestExpectation *shownExpectation = [self expectationWithDescription:@"show animation is finished"];
    __block BOOL isAnimationFinished = NO;

    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
    [sheet showInView:self.view completion:^{
        isAnimationFinished = YES;
        [shownExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue([self.view.subviews containsObject:sheet], @"View should have sheet as a subview");
    XCTAssertTrue(sheet.isShowing, @"Sheet should be shown");
}

- (void)testSheetDismissShouldRemoveView {
    XCTestExpectation *dismissedExpectation = [self expectationWithDescription:@"dismiss animation is finished"];
    __block BOOL isAnimationFinished = NO;

    IAElegantSheet *sheet = [[IAElegantSheet alloc] initWithTitle:@"title"];
    [sheet showInView:self.view completion:^{
        [sheet dismissWithCompletion:^{
            isAnimationFinished = YES;
            [dismissedExpectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertFalse([self.view.subviews containsObject:sheet], @"View should have sheet as a subview");
    XCTAssertFalse(sheet.showing, @"Sheet should be hidden");
}

@end
