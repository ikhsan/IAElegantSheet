//
//  IAElegantButton.m
//  IAElegantSheet
//
//  Created by Ikhsan Assaat on 4/19/15.
//  Copyright (c) 2015 3kunci. All rights reserved.
//

#import "IAElegantButton.h"
#import "UIFont+ElegantSheet.h"

static CGFloat const kAlphaHighlight = 0.75;

@interface IAElegantButton ()

@property (assign, nonatomic) IAElegantButtonType elegantButtonType;
@property (weak, nonatomic) UIView *lineView;
@property (nonatomic, readonly) CGFloat alphaHighlight;

@end

@implementation IAElegantButton

+ (instancetype)buttonWithTitle:(NSString *)title type:(IAElegantButtonType)type baseColor:(UIColor *)baseColor block:(void (^)(void))block {
    IAElegantButton *button = [super buttonWithType:UIButtonTypeCustom];
    button.buttonTitle = title ?: @"";
    button.elegantButtonType = type;
    button.buttonAction = [block copy];
    
    baseColor = baseColor ?: [UIColor blackColor];
    UIColor *buttonColor = (type != IAElegantButtonTypeDestructive)? baseColor : [UIColor redColor];
    button.backgroundColor = [buttonColor colorWithAlphaComponent:button.alphaHighlight];
    button.titleLabel.font = [UIFont elegantFontWithSize:16.0];
    button.titleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.adjustsImageWhenHighlighted = YES;
    
    [button addTarget:button action:@selector(callBlocks) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:button action:@selector(buttonHighlight) forControlEvents:UIControlEventTouchDown];
    [button addTarget:button action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpOutside];
    
    if (type != IAElegantButtonTypeCancel)
        [button addBottomBorder];
    
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

- (void)addBottomBorder {
    UIView *line = [[UIView alloc] init];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    [line setBackgroundColor:[UIColor colorWithWhite:.9 alpha:0.5]];
    [self addSubview:line];
    self.lineView = line;

    NSDictionary *views = NSDictionaryOfVariableBindings(line);
    NSDictionary *metrics = @{ @"padding": @4, @"bottomMargin" : @0.5, @"thickness" : @0.5 };
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[line]-padding-|" options:0 metrics:metrics views:views];
    [self addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[line(thickness)]-bottomMargin-|" options:0 metrics:metrics views:views];
    [self addConstraints:constraints];
}

- (CGFloat)alphaHighlight {
    return kAlphaHighlight;
}

- (void)callBlocks {
    [self buttonNormal];
    if (self.buttonAction) self.buttonAction();
}

- (void)buttonHighlight {
    [self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:self.alphaHighlight+0.05]];
}

- (void)buttonNormal {
    [self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:self.alphaHighlight]];
}

@end
