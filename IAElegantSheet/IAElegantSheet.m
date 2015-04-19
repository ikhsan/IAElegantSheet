//
//  IACustomSheet.m
//  Penny
//
//  Created by Ikhsan Assaat on 5/10/13.
//  Copyright (c) 2013 Homegrown Laboratories. All rights reserved.
//

#import "IAElegantSheet.h"
#import "UIFont+ElegantSheet.h"
#import "IAElegantButton.h"

static NSString *const kDefaultCancel = @"Cancel";
static const CGFloat kTransitionDuration = 0.2f;

@interface IAElegantSheet()

@property (weak, nonatomic) UILabel *titleLabel;
@property (nonatomic, readonly) CGFloat titleHeight;
@property (nonatomic, readonly) CGFloat buttonHeight;
@property (nonatomic, readonly) CGFloat transitionDuration;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (assign, nonatomic, getter=isShowing) BOOL showing;

@end

@implementation IAElegantSheet

+ (instancetype)elegantSheetWithTitle:(NSString *)title {
    return [[IAElegantSheet alloc] initWithTitle:title];
}

- (id)initWithTitle:(NSString *)title {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _baseColor = [UIColor blackColor];
        _buttons = [NSMutableArray array];
        
        // adding title label
        UILabel *titleLabel = [self generateTitleLabelForTitle:title];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel);
        NSDictionary *metrics = @{ @"height" : @(self.titleHeight) };
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[titleLabel]|" options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel(height)]" options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
        
        [self insertButtonWithTitle:kDefaultCancel type:IAElegantButtonTypeCancel block:nil];
    }
    
    return self;
}

- (UILabel *)generateTitleLabelForTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = [title uppercaseString];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    titleLabel.font = [UIFont boldElegantFontWithSize:titleLabel.font.pointSize];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.backgroundColor = _baseColor;
    return titleLabel;
}

- (CGFloat)titleHeight {
    return 40.0f;
}

- (CGFloat)buttonHeight {
    return 34.0f;
}

- (CGFloat)transitionDuration {
    return kTransitionDuration;
}

#pragma mark - Adding buttons and setting cancel button

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block {
    IAElegantButton *destructiveButton = [self destructiveButton];
    void (^blockWithDismiss)() = [self setBlockWithDismissal:block];
    
    if (!destructiveButton) {
        [self insertButtonWithTitle:title type:IAElegantButtonTypeDestructive block:blockWithDismiss];
        return;
    }
    
    if (title && ![title isEqualToString:@""]) {
        destructiveButton.buttonTitle = title;
    }
    
    if (block) {
        destructiveButton.buttonAction = blockWithDismiss;
    }
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void(^)())block {
    IAElegantButton *cancelButton = [self cancelButton];
    void (^blockWithDismiss)() = [self setBlockWithDismissal:block];
    
    if (title && ![title isEqualToString:@""]) {
        cancelButton.buttonTitle = title;
    }
    
    if (block) {
        cancelButton.buttonAction = blockWithDismiss;
    }
}

- (void)addButtonsWithTitle:(NSString *)title block:(void(^)())block {
    [self insertButtonWithTitle:title type:IAElegantButtonTypeDefault block:block];
}

#pragma mark - Helper methods

- (IAElegantButton *)buttonsForType:(IAElegantButtonType)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"elegantButtonType == %@", @(type)];
    NSArray *filteredButtons = [self.buttons filteredArrayUsingPredicate:predicate];
    return [filteredButtons firstObject];
}

- (IAElegantButton *)destructiveButton {
    return [self buttonsForType:IAElegantButtonTypeDestructive];
}

- (IAElegantButton *)cancelButton {
    return [self buttonsForType:IAElegantButtonTypeCancel];
}

- (void (^)())setBlockWithDismissal:(void (^)())block {
    __weak typeof(self) welf = self;
    return ^{
        if (block) block();
        [welf dismiss];
    };
}

- (void)insertButtonWithTitle:(NSString *)title type:(IAElegantButtonType)type block:(void(^)())block {
    void (^blockWithDismiss)() = [self setBlockWithDismissal:block];
    [self.buttons addObject:[IAElegantButton buttonWithTitle:title type:type baseColor:self.baseColor block:blockWithDismiss]];
    [self reorderButtons:self.buttons];
}

- (void)reorderButtons:(NSMutableArray *)buttons {
    IAElegantButton *destructiveButton = [self destructiveButton];
    if (destructiveButton) {
        [buttons removeObjectIdenticalTo:destructiveButton];
        [buttons addObject:destructiveButton];
    }
    
    IAElegantButton *cancelButton = [self cancelButton];
    if (cancelButton) {
        [buttons removeObjectIdenticalTo:cancelButton];
        [buttons addObject:cancelButton];
    }
}

#pragma mark - Preparation before showing view

- (void)prepare:(CGRect)frame {
    self.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(frame), (self.buttons.count * self.buttonHeight + self.titleHeight));
    
    [self.buttons enumerateObjectsUsingBlock:^(IAElegantButton *button, NSUInteger idx, BOOL *stop) {
        if ([self.subviews containsObject:button]) {
            return;
        }
        
        [self addSubview:button];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(button);
        NSDictionary *metrics = @{ @"height": @(self.buttonHeight), @"cursor" : @(idx * self.buttonHeight + self.titleHeight) };        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[button]|" options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-cursor-[button(height)]" options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
    }];
}

#pragma mark - Showing and dismissing methods

- (void)showInView:(UIView *)view {
    if (self.isShowing) return;
    
    [self prepare:view.frame];
    [view addSubview:self];
    
    // adding autolayout code
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *metrics = @{ @"height": @(CGRectGetHeight(self.frame)) };
    NSDictionary *views = @{ @"elegantSheet" : self };
    
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[elegantSheet(height)]|" options:0 metrics:metrics views:views];
    [view addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[elegantSheet]|" options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    // slide from bottom
    self.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.bounds));
    [UIView animateWithDuration:self.transitionDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        self.showing = YES;
    }];
}

- (void)dismiss {
    if (!self.superview) return;
    
    __block CGRect f = self.frame;
    [UIView animateWithDuration:self.transitionDuration animations:^{
        f.origin.y += f.size.height;
        self.frame = f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.showing = NO;
    }];
}

@end
