//
//  LPLoginViewController.m
//  LPFTPManager
//
//  Created by Luka Penger on 8/28/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//

#import "LPLoginViewController.h"


@interface LPLoginViewController ()

@end


@implementation LPLoginViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [[[LPSharedManager sharedManager] languageDictionary] objectForKey:@"LPLoginViewController_Title"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textFieldHostname.delegate = self;
    self.textFieldUsername.delegate = self;
    self.textFieldPassword.delegate = self;
    
    self.labelHostname.text = [[[LPSharedManager sharedManager]  languageDictionary] objectForKey:@"LPLoginViewController_HostnameTitle"];
    self.labelUsername.text = [[[LPSharedManager sharedManager]  languageDictionary] objectForKey:@"LPLoginViewController_UsernameTitle"];
    self.labelPassword.text = [[[LPSharedManager sharedManager]  languageDictionary] objectForKey:@"LPLoginViewController_PasswordTitle"];
    self.labelAutoLogin.text = [[[LPSharedManager sharedManager]  languageDictionary] objectForKey:@"LPLoginViewController_AutoLoginTitle"];
    
    self.textFieldHostname.placeholder = [[[LPSharedManager sharedManager]  languageDictionary] objectForKey:@"LPLoginViewController_HostnameTextFieldPlaceholderText"];
    self.textFieldUsername.placeholder = [[[LPSharedManager sharedManager]  languageDictionary] objectForKey:@"LPLoginViewController_UsernameTextFieldPlaceholderText"];
    self.textFieldPassword.placeholder = [[[LPSharedManager sharedManager]  languageDictionary] objectForKey:@"LPLoginViewController_PasswordTextFieldPlaceholderText"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL autoLogin = [userDefaults boolForKey:@"loginAutoLogin"];
    
    self.switchAutoLogin.on = autoLogin;
    
    if(autoLogin)
    {
        NSString *hostname = [userDefaults objectForKey:@"loginHostname"];
        NSString *username = [userDefaults objectForKey:@"loginUsername"];
        NSString *password = [userDefaults objectForKey:@"loginPassword"];
        
        self.textFieldHostname.text = hostname;
        self.textFieldUsername.text = username;
        self.textFieldPassword.text = password;
        
        if(hostname.length>0 && username.length>0 && password.length>0 && hostname && username && password)
        {
            [self loginWithHostname:hostname username:username password:password];
        } else {
            [[[LPSharedManager sharedManager] requestsManagerFTP] stopAndCancelAllRequests];
        }
    } else {
        [[[LPSharedManager sharedManager] requestsManagerFTP] stopAndCancelAllRequests];
    }
}

- (IBAction)buttonLoginClicked:(id)sender
{    
    NSString *hostname = self.textFieldHostname.text;
    NSString *username = self.textFieldUsername.text;
    NSString *password = self.textFieldPassword.text;
    
    if(hostname.length>0 && username.length>0 && password.length>0 && hostname && username && password)
    {
        [self loginWithHostname:hostname username:username password:password];
    } else {
        [[[LPSharedManager sharedManager] requestsManagerFTP] stopAndCancelAllRequests];
        
        [self showLoginError];
    }
}

- (IBAction)switchAutoLoginChanged:(id)sender
{

}

- (void)loginWithHostname:(NSString*)hostname username:(NSString*)username password:(NSString*)password
{
    GRRequestsManager *requestsManager = [[GRRequestsManager alloc] initWithHostname:hostname user:username password:password];
    requestsManager.delegate = self;

    [requestsManager addRequestForListDirectoryAtPath:@""];
    [requestsManager startProcessingRequests];
    
    [[LPSharedManager sharedManager] setRequestsManagerFTP:requestsManager];
}

- (void)showLoginError
{
    [[LPSharedManager sharedManager] deleteLoginData];
    
    self.textFieldHostname.enabled = YES;
    self.textFieldUsername.enabled = YES;
    self.textFieldUsername.enabled = YES;
    self.textFieldHostname.backgroundColor = [self textFieldEnabledBackgroundColor];
    self.textFieldUsername.backgroundColor = [self textFieldEnabledBackgroundColor];
    self.textFieldPassword.backgroundColor = [self textFieldEnabledBackgroundColor];
    
    NSDictionary *dictionary = [[[LPSharedManager sharedManager] languageDictionary] objectForKey:@"LPLoginViewController_LoginError"];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[dictionary objectForKey:@"Title"] andMessage:[dictionary objectForKey:@"Message"]];
    
    [alertView addButtonWithTitle:[dictionary objectForKey:@"CancelButton"] type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView)
    {
        
    }];
    
    [alertView show];
}

#pragma mark - FTP Manager Delegate

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing
{
    [[LPSharedManager sharedManager] saveLoginHostname:self.textFieldHostname.text username:self.textFieldUsername.text password:self.textFieldPassword.text autoLogin:self.switchAutoLogin.on];
    
    self.textFieldHostname.enabled = NO;
    self.textFieldUsername.enabled = NO;
    self.textFieldUsername.enabled = NO;
    self.textFieldHostname.backgroundColor = [self textFieldDisabledBackgroundColor];
    self.textFieldUsername.backgroundColor = [self textFieldDisabledBackgroundColor];
    self.textFieldPassword.backgroundColor = [self textFieldDisabledBackgroundColor];
    
    NSMutableArray *array = [NSMutableArray new];
    for (NSDictionary *file in ((GRListingRequest *)request).filesInfo) {
        
        if(![[file objectForKey:(id)kCFFTPResourceName] isEqualToString:@"."] && ![[file objectForKey:(id)kCFFTPResourceName] isEqualToString:@".."])
        {
            [array addObject:file];
        }
    }
    
    LPListViewController *listViewController = [[LPListViewController alloc] initWithNibName:@"LPListViewController" bundle:nil];
    listViewController.folderName = @"";
    listViewController.folderPath = @"";
    listViewController.listArray = array;
    listViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:navigationController animated:YES completion:^{
        
    }];
    
    [listViewController.tableView reloadData];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    [self showLoginError];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==self.textFieldHostname)
    {
        [self.textFieldUsername becomeFirstResponder];
    } else if(textField==self.textFieldUsername) {
        [self.textFieldPassword becomeFirstResponder];
    } else {
        [self.textFieldPassword resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Colors

- (UIColor*)textFieldDisabledBackgroundColor
{
    return [UIColor colorWithWhite:0.8f alpha:1.0f];
}

- (UIColor*)textFieldEnabledBackgroundColor
{
    return [UIColor whiteColor];
}

@end
