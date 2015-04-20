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

@interface IAElegantSheet()

@property (weak, nonatomic) UILabel *titleLabel;
@property (nonatomic, readonly) CGFloat titleHeight;
@property (nonatomic, readonly) CGFloat buttonHeight;
@property (nonatomic, readonly) CGFloat transitionDuration;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (assign, nonatomic, getter=isShowing) BOOL showing;

@end


@interface IAElegantSheetTests : XCTestCase

@end

@implementation IAElegantSheetTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitializers {
    IAElegantSheet *sheet1 = [[IAElegantSheet alloc] initWithTitle:@"title1"];
    XCTAssertNotNil(sheet1, @"Should not be nil");
    XCTAssertEqualObjects(@"TITLE1", sheet1.titleLabel.text, @"Should have correct title");
    
    IAElegantSheet *sheet2 = [IAElegantSheet elegantSheetWithTitle:@"title2"];
    XCTAssertNotNil(sheet2, @"Should not be nil");
    XCTAssertEqualObjects(@"TITLE2", sheet2.titleLabel.text, @"Should have correct title");
}

@end
