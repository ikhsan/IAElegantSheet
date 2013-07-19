//
//  IAAppDelegate.m
//  IAElegantSheet
//
//  Created by Ikhsan Assaat on 6/30/13.
//  Copyright (c) 2013 3kunci. All rights reserved.
//

#import "IAAppDelegate.h"
#import "IAViewController.h"

@implementation IAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    IAViewController *viewController = [[IAViewController alloc] init];
    [self.window setRootViewController:viewController];
    [self.window makeKeyAndVisible];    
        
    return YES;
}
							

@end
