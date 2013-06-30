//
//  IACustomSheet.h
//  Penny
//
//  Created by Ikhsan Assaat on 5/10/13.
//  Copyright (c) 2013 Homegrown Laboratories. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAElegantSheet : UIView

@property (strong, nonatomic) UIColor *baseColor;

+ (instancetype)elegantSheetWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title;

- (void)addButtonsWithTitle:(NSString *)title block:(void(^)())block;
- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)setCancelButtonWithTitle:(NSString *)title block:(void(^)())block;

- (void)showInView:(UIView *)view;

@end
