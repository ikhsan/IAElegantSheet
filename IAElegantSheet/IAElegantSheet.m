//
//  IACustomSheet.m
//  Penny
//
//  Created by Ikhsan Assaat on 5/10/13.
//  Copyright (c) 2013 Homegrown Laboratories. All rights reserved.
//

#import "IAElegantSheet.h"

NSString *const ButtonTitleKey = @"ButtonTitle";
NSString *const ButtonBlockKey = @"ButtonBlock";
NSString *const DefaultCancel = @"Cancel";

int const TitleTag = 9999;
CGFloat const TransitionDuration = .2;
CGFloat const Alpha = 0.75;

@interface IAElegantSheet()

@property (strong, nonatomic) NSMutableArray *buttonTitles;
@property (strong, nonatomic) NSMutableDictionary *blocks;
@property (assign, nonatomic) NSInteger destructiveIndex;

@end

@implementation IAElegantSheet

+ (instancetype)elegantSheetWithTitle:(NSString *)title {
	return [[IAElegantSheet alloc] initWithTitle:title];
}

- (id)initWithTitle:(NSString *)title {
	self = [self initWithFrame:CGRectZero];
	if (self) {
		// adding cancel name and block
		_buttonTitles = [NSMutableArray arrayWithObject:DefaultCancel];
		void (^cancel)(void) = ^{};
		_blocks = [NSMutableDictionary dictionaryWithObject:[cancel copy] forKey:DefaultCancel];
		
		// adding title label
		_baseColor = [UIColor blackColor];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.text = [title uppercaseString];
		titleLabel.tag = TitleTag;
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
		titleLabel.shadowColor = [UIColor blackColor];
		titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        titleLabel.font = [UIFont fontWithName:@"RobotoCondensed-Bold" size:titleLabel.font.pointSize];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:titleLabel];
        
        // autolayout code
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel);
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[titleLabel]|" options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLabel(38)]" options:0 metrics:nil views:views];
        [self addConstraints:constraints];
		
        // default destructive index
        _destructiveIndex = -1;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
	}
	
	return self;
}

#pragma mark - Adding buttons and setting cancel button

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block {    
    if (self.destructiveIndex >= 0) {
        NSString *oldTitle = self.buttonTitles[self.destructiveIndex];
        [self.buttonTitles removeObjectAtIndex:self.destructiveIndex];
        [self.blocks removeObjectForKey:oldTitle];
    }
    
    NSInteger index = self.buttonTitles.count-1;
    [self.buttonTitles insertObject:title atIndex:index];
    self.blocks[title] = [block copy];
    self.destructiveIndex = index;
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void(^)())block {
	// get the old ones
	NSString *oldTitle = [self.buttonTitles lastObject];
	NSString *newTitle;
	
	// remove old title, if there's a new one
	if (title && ![title isEqualToString:@""]) {
		newTitle = title;
		[self.buttonTitles removeLastObject];
		[self.buttonTitles addObject:newTitle];
	} else {
		newTitle = oldTitle;
	}
	
	// add a new block
	if (block && ![block isEqual:[NSNull null]]) {
		self.blocks[newTitle] = [block copy];
	} else {
		self.blocks[newTitle] = [self.blocks[oldTitle] copy];
	}
	
	// remove the old block
	[self.blocks removeObjectForKey:oldTitle];		
}

- (void)addButtonsWithTitle:(NSString *)title block:(void(^)())block {
	[self.buttonTitles insertObject:title atIndex:self.buttonTitles.count-1];
	[self.blocks setObject:[block copy] forKey:title];
}

#pragma mark - Preparation before showing view

- (void)prepare:(CGRect)frame {
	CGRect f = CGRectMake(0.0, 0.0, frame.size.width, 38.0);
	UILabel *titleLabel = (UILabel *)[self viewWithTag:TitleTag];
    titleLabel.frame = f;
	titleLabel.backgroundColor = self.baseColor;
    
	__block CGFloat cursor = f.size.height;
    UIFont *buttonFont = [UIFont fontWithName:@"RobotoCondensed-Regular" size:14.0];
    [self.buttonTitles enumerateObjectsUsingBlock:^(NSString *buttonTitle, NSUInteger index, BOOL *stop) {
        CGFloat labelHeight = 32.0;
        
		UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
		optionButton.tag = index;
        optionButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIColor *buttonColor = (self.destructiveIndex != index)? self.baseColor : [UIColor redColor];
		optionButton.backgroundColor = [buttonColor colorWithAlphaComponent:Alpha];
		optionButton.titleLabel.font = buttonFont;
		optionButton.titleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
		optionButton.adjustsImageWhenHighlighted = YES;
        
		[optionButton setTitle:[buttonTitle uppercaseString] forState:UIControlStateNormal];
		
		[optionButton addTarget:self action:@selector(callBlocks:) forControlEvents:UIControlEventTouchUpInside];
		[optionButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
		[optionButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
		
		[self addSubview:optionButton];
        
        // autolayout code
        NSDictionary *views = NSDictionaryOfVariableBindings(optionButton);
        NSDictionary *metrics = @{ @"height": @(labelHeight), @"cursor" : @(cursor) };
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[optionButton]|" options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-cursor-[optionButton(height)]" options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
        
		cursor += labelHeight;
		
		if (index != ([self.buttonTitles count] - 1)) {
			UIView *line = [[UIView alloc] init];
            line.translatesAutoresizingMaskIntoConstraints = NO;
			[line setBackgroundColor:[UIColor colorWithWhite:.9 alpha:0.5]];
			[self addSubview:line];
            
            NSDictionary *views = NSDictionaryOfVariableBindings(line);
            NSDictionary *metrics = @{ @"padding": @4, @"topMargin" : @(cursor-1), @"thickness" : @0.5 };
            NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[line]-padding-|" options:0 metrics:metrics views:views];
            [self addConstraints:constraints];
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[line(thickness)]" options:0 metrics:metrics views:views];
            [self addConstraints:constraints];
		}
    }];
	
	self.frame = CGRectMake(0.0, 0.0, frame.size.width, cursor);
}

- (void)callBlocks:(UIButton *)button {
	[self buttonNormal:button];
	
	// get the block from the dictionary
	NSInteger tag = button.tag;
	NSString *blockKey = self.buttonTitles[tag];
	void (^block)() = self.blocks[blockKey];
	
	// dismiss and then fire the block
	block();
	[self dismiss];
}

- (void)buttonHighlight:(UIButton *)button {	
	// darken color
	[button setBackgroundColor:[button.backgroundColor colorWithAlphaComponent:Alpha+0.05]];
}

- (void)buttonNormal:(UIButton *)button {
	// normalize color
	[button setBackgroundColor:[button.backgroundColor colorWithAlphaComponent:Alpha]];
}

#pragma mark - Showing and dismissing methods

- (void)showInView:(UIView *)view {
	[self prepare:view.frame];
	
	// place to the bottom
	[view addSubview:self];
    
    // adding autolayout code
    UIView *elegantSheet = self;
    NSDictionary *metrics = @{ @"height": @(self.frame.size.height), @"minusHeight" : @(-self.frame.size.height) };
    NSDictionary *views = NSDictionaryOfVariableBindings(elegantSheet);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[elegantSheet(height)]|" options:0 metrics:metrics views:views];
    [view addConstraints:verticalConstraints];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[elegantSheet]|" options:0 metrics:nil views:views];
    [view addConstraints:horizontalConstraints];
    
	// slide from bottom
    self.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    [UIView animateWithDuration:TransitionDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:NULL];
}

- (void)dismiss {
	if (!self.superview) return;
	
    __block CGRect f = self.frame;
	[UIView animateWithDuration:TransitionDuration animations:^{
        f.origin.y += f.size.height;
        self.frame = f;
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
	}];
}

@end
