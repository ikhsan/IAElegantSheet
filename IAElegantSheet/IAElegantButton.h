//
//  IAElegantButton.h
//  IAElegantSheet
//
//  Created by Ikhsan Assaat on 4/19/15.
//  Copyright (c) 2015 3kunci. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, IAElegantButtonType) {
    IAElegantButtonTypeDefault,
    IAElegantButtonTypeDestructive,
    IAElegantButtonTypeCancel,
};

@interface IAElegantButton : UIButton

@property (strong, nonatomic) NSString *buttonTitle;
@property (strong, nonatomic) void (^buttonAction)(void);
@property (nonatomic, readonly) IAElegantButtonType elegantButtonType;

+ (instancetype)buttonWithTitle:(NSString *)title type:(IAElegantButtonType)type baseColor:(UIColor *)baseColor action:(void (^)(void))action;

@end
