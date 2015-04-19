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

static NSString *const kButtonTitleKey = @"ButtonTitle";
static NSString *const kButtonBlockKey = @"ButtonBlock";
static NSString *const kDefaultCancel = @"Cancel";

static const CGFloat kTransitionDuration = 0.2f;

@interface IAElegantSheet()

@property (weak, nonatomic) UILabel *titleLabel;

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
        // initialize
		_baseColor = [UIColor blackColor];
        _buttons = [NSMutableArray array];
		
        // adding title label
        UILabel *titleLabel = [self generateTitleLabelForTitle:title];
		[self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel);
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[titleLabel]|" options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel(38)]" options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        [self insertButtonWithTitle:title type:IAElegantButtonTypeCancel block:nil];
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

#pragma mark - Adding buttons and setting cancel button

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block {
    IAElegantButton *destructiveButton = [self destructiveButton];
    if (!destructiveButton) {
        [self insertButtonWithTitle:title type:IAElegantButtonTypeDestructive block:block];
        return;
    }
    
    if (title && ![title isEqualToString:@""]) {
        destructiveButton.buttonTitle = title;
    }
    
    if (block) {
        destructiveButton.buttonAction = block;
    }
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void(^)())block {
    IAElegantButton *cancelButton = [self cancelButton];
    
    if (title && ![title isEqualToString:@""]) {
        cancelButton.buttonTitle = title;
    }
    
    if (block) {
        cancelButton.buttonAction = block;
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

- (void)insertButtonWithTitle:(NSString *)title type:(IAElegantButtonType)type block:(void(^)())block {
    IAElegantButton *button = [IAElegantButton buttonWithTitle:title type:type baseColor:self.baseColor action:nil];
    [self.buttons addObject:button];
    [self reorderButtons:self.buttons];
}

- (void)reorderButtons:(NSMutableArray *)buttons {
}

#pragma mark - Preparation before showing view

- (void)prepare:(CGRect)frame {
    CGFloat labelHeight = 32.0;
    
    [self.buttons enumerateObjectsUsingBlock:^(IAElegantButton *button, NSUInteger idx, BOOL *stop) {
        if ([self.subviews containsObject:button]) {
            return;
        }
        
        [self addSubview:button];
    
        NSDictionary *views = NSDictionaryOfVariableBindings(button);
        NSDictionary *metrics = @{ @"height": @(labelHeight), @"cursor" : @(idx * labelHeight) };
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[button]|" options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-cursor-[button(height)]" options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
    }];
    
    self.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(frame), (self.buttons.count * labelHeight + CGRectGetHeight(self.titleLabel.frame)));
}

#pragma mark - Showing and dismissing methods

- (void)showInView:(UIView *)view {
    if (self.isShowing) return;
    
	[self prepare:view.frame];
	[view addSubview:self];
    
    // adding autolayout code
    UIView *elegantSheet = self;
    NSDictionary *metrics = @{ @"height": @(CGRectGetHeight(self.frame)) };
    NSDictionary *views = NSDictionaryOfVariableBindings(elegantSheet);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[elegantSheet(height)]|" options:0 metrics:metrics views:views];
    [view addConstraints:verticalConstraints];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[elegantSheet]|" options:0 metrics:nil views:views];
    [view addConstraints:horizontalConstraints];
    
	// slide from bottom
    self.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    [UIView animateWithDuration:kTransitionDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        self.showing = YES;
    }];
}

- (void)dismiss {
	if (!self.superview) return;
	
    __block CGRect f = self.frame;
	[UIView animateWithDuration:kTransitionDuration animations:^{
        f.origin.y += f.size.height;
        self.frame = f;
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
        self.showing = NO;
	}];
}

@end
