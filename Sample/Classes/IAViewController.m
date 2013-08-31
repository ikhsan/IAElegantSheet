//
//  IAViewController.m
//  IAElegantSheet
//
//  Created by Ikhsan Assaat on 6/30/13.
//  Copyright (c) 2013 3kunci. All rights reserved.
//

#import "IAViewController.h"
#import "IAElegantSheet.h"

@interface IAViewController ()

@end

@implementation IAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self addButton];
    [self.view setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1.0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Show Elegance" forState:UIControlStateNormal];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    if ([button respondsToSelector:@selector(setTranslatesAutoresizingMaskIntoConstraints:)])
        button.translatesAutoresizingMaskIntoConstraints = NO;
    else
    {
        button.frame = CGRectMake(0,0,200,44);
        button.center = self.view.center;
    }
    [button addTarget:self action:@selector(showElegantSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // autolayout code
    if ([self.view respondsToSelector:@selector(addConstraint:)])
    {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:button.superview attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
        [self.view addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:button.superview attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f];
        [self.view addConstraint:constraint];
    }
}

- (void)showElegantSheet:(UIButton *)button {
    NSDictionary *dict = @{
        @"Elegant to code" : @"Using blocks handler",
        @"Elegant to see" : @"Using custom views",
        @"Custom font by default" : @"Using Roboto for default font",
    };
        
    IAElegantSheet *elegantSheet = [IAElegantSheet elegantSheetWithTitle:@"Elegant Sheet"];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *title, NSString *message, BOOL *stop) {
        [elegantSheet addButtonsWithTitle:title block:^{ [self alert:message]; }];
    }];
    
    [elegantSheet setDestructiveButtonWithTitle:@"Danger Button" block:^{
        [self alert:@"Do something dangerous"];
    }];
    
    [elegantSheet setCancelButtonWithTitle:@"Thanks!" block:^{
        NSLog(@"\nCreated by Ikhsan Assaat for 'Back On The Map'. \n#backonthemap #objectivechackathon \nhttps://objectivechackathon.appspot.com/‎");
    }];
    
    [elegantSheet showInView:self.view];
}

- (void)alert:(NSString *)alertMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Elegant Sheet" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
