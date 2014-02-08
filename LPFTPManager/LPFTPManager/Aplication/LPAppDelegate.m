//
//  LPAppDelegate.m
//  LPFTPManager
//
//  Created by Luka Penger on 8/28/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//

#import "LPAppDelegate.h"


@implementation LPAppDelegate

#pragma mark - Application methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self initSIAlertViewAppearance];
    
    LPLoginViewController *loginViewController = [[LPLoginViewController alloc] initWithNibName:@"LPLoginViewController" bundle:nil];
    
    self.window.rootViewController = loginViewController;
    
    [self.window makeKeyAndVisible];

    return YES;
}

#pragma mark - SIAlertView

- (void)initSIAlertViewAppearance
{
    [[SIAlertView appearance] setMessageFont:[UIFont systemFontOfSize:13]];
    [[SIAlertView appearance] setTitleFont:[UIFont boldSystemFontOfSize:15]];
    [[SIAlertView appearance] setTitleColor:[UIColor grayColor]];
    [[SIAlertView appearance] setMessageColor:[UIColor grayColor]];
    [[SIAlertView appearance] setCornerRadius:10];
    [[SIAlertView appearance] setShadowRadius:20];
    [[SIAlertView appearance] setTransitionStyle:SIAlertViewTransitionStyleBounce];
}

@end
