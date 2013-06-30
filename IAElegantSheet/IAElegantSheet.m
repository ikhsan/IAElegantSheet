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
		[self addSubview:titleLabel];		
	}
	
	return self;
}

#pragma mark - Adding buttons and setting cancel button

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block {
    
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
	[[self viewWithTag:TitleTag] setFrame:f];
	CGFloat cursor = f.size.height;
	
	UILabel *titleLabel = (UILabel *)[self viewWithTag:TitleTag];
	titleLabel.backgroundColor = self.baseColor;
	
	UIFont *buttonFont = [UIFont fontWithName:@"RobotoCondensed-Regular" size:14.0];
	for (NSString *buttonTitle in self.buttonTitles) {
		f.origin.y = cursor;
		f.size.height = 32.0;
		UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
		NSInteger index = [self.buttonTitles indexOfObjectIdenticalTo:buttonTitle];
		optionButton.tag = index;
		optionButton.frame = f;
		optionButton.backgroundColor = [self.baseColor colorWithAlphaComponent:Alpha];
		optionButton.titleLabel.font = buttonFont;
		optionButton.titleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
		optionButton.adjustsImageWhenHighlighted = YES;
        
        optionButton.titleLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:titleLabel.font.pointSize];
		[optionButton setTitle:[buttonTitle uppercaseString] forState:UIControlStateNormal];
		
		[optionButton addTarget:self action:@selector(callBlocks:) forControlEvents:UIControlEventTouchUpInside];
		[optionButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
		[optionButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
		
		[self addSubview:optionButton];
		cursor += f.size.height;
		
		if (index != ([self.buttonTitles count] - 1)) {
			CGRect f = CGRectMake(CGRectGetMinX(frame) + 4.0, cursor - 1.0, CGRectGetMaxX(frame) - 8.0, .5);
			UIView *line = [[UIView alloc] initWithFrame:f];
			[line setBackgroundColor:[UIColor colorWithWhite:.9 alpha:0.5]];
			[self addSubview:line];
		}
	}
	
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
	[button setBackgroundColor:[self.baseColor colorWithAlphaComponent:Alpha+0.05]];
}

- (void)buttonNormal:(UIButton *)button {
	// normalize color
	[button setBackgroundColor:[self.baseColor colorWithAlphaComponent:Alpha]];
}

#pragma mark - Showing and dismissing methods

- (void)showInView:(UIView *)view {
	[self prepare:view.frame];
	
	// place to the bottom
	CGRect f = self.frame;
	f.origin.y = view.frame.size.height;
	self.frame = f;
	[view addSubview:self];
	
	// slide from bottom
	f.origin.y = view.frame.size.height - self.frame.size.height;
	[UIView animateWithDuration:TransitionDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.frame = f;
	} completion:nil];
}

- (void)dismiss {
	if (!self.superview) return;
	
	CGRect f = self.frame;
	f.origin.y += f.size.height;
	
	[UIView animateWithDuration:TransitionDuration animations:^{
		self.frame = f;
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
	}];
}

@end
