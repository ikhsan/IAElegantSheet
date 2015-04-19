//
//  IAElegantButton.m
//  IAElegantSheet
//
//  Created by Ikhsan Assaat on 4/19/15.
//  Copyright (c) 2015 3kunci. All rights reserved.
//

#import "IAElegantButton.h"
#import "UIFont+ElegantSheet.h"

static CGFloat const kAlpha = 0.75;

@interface IAElegantButton ()

@property (assign, nonatomic) IAElegantButtonType elegantButtonType;

@end

@implementation IAElegantButton

+ (instancetype)buttonWithTitle:(NSString *)title type:(IAElegantButtonType)type baseColor:(UIColor *)baseColor block:(void (^)(void))block {
    IAElegantButton *button = [super buttonWithType:UIButtonTypeCustom];
    button.buttonTitle = title ?: @"";
    button.elegantButtonType = type;
    button.buttonAction = [block copy];
    
    UIColor *buttonColor = (type != IAElegantButtonTypeDestructive)? baseColor : [UIColor redColor];
    button.backgroundColor = [buttonColor colorWithAlphaComponent:kAlpha];
    button.titleLabel.font = [UIFont elegantFontWithSize:16.0];
    button.titleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.adjustsImageWhenHighlighted = YES;
   
    
    [button addTarget:button action:@selector(callBlocks) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:button action:@selector(buttonHighlight) forControlEvents:UIControlEventTouchDown];
    [button addTarget:button action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpOutside];
    
    return button;
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    _buttonTitle = buttonTitle;
    
    [self setTitle:[buttonTitle uppercaseString] forState:UIControlStateNormal];
}

- (void)setButtonAction:(void (^)(void))buttonAction {
    _buttonAction = [buttonAction copy];
}

#pragma mark - Button helpers

- (void)callBlocks {
    [self buttonNormal];
    if (self.buttonAction) self.buttonAction();
}

- (void)buttonHighlight {
    [self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:kAlpha+0.05]];
}

- (void)buttonNormal {
    [self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:kAlpha]];
}

@end
