//
//  LPAppDelegate.h
//  LPFTPManager
//
//  Created by Luka Penger on 8/28/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPLoginViewController.h"
#import <SIAlertView/SIAlertView.h>


@interface LPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - Application methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

#pragma mark - SIAlertView

- (void)initSIAlertViewAppearance;

@end
