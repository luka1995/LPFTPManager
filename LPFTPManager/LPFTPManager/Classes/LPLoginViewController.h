//
//  LPLoginViewController.h
//  LPFTPManager
//
//  Created by Luka Penger on 8/28/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPSharedManager.h"
#import "LPListViewController.h"


@interface LPLoginViewController : UIViewController <GRRequestsManagerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *textFieldHostname;
@property (nonatomic, strong) IBOutlet UITextField *textFieldUsername;
@property (nonatomic, strong) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, strong) IBOutlet UIButton *buttonLogin;
@property (nonatomic, strong) IBOutlet UISwitch *switchAutoLogin;
@property (nonatomic, strong) IBOutlet UILabel *labelHostname;
@property (nonatomic, strong) IBOutlet UILabel *labelUsername;
@property (nonatomic, strong) IBOutlet UILabel *labelPassword;
@property (nonatomic, strong) IBOutlet UILabel *labelAutoLogin;

- (IBAction)buttonLoginClicked:(id)sender;
- (IBAction)switchAutoLoginChanged:(id)sender;

@end
