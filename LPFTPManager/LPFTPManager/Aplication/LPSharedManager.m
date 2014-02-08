//
//  LPSharedManager.m
//  LPFTPManager
//
//  Created by Luka Penger on 8/15/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//

#import "LPSharedManager.h"


static LPSharedManager *sharedMyManager = nil;


@interface LPSharedManager ()

@property (nonatomic, assign) BOOL networkAlertViewShown;

@end


@implementation LPSharedManager

#pragma mark Singleton Methods

+ (id)sharedManager {
    @synchronized(self) {
        if(sharedMyManager == nil)
        {
            sharedMyManager = [[super allocWithZone:NULL] init];
        }
    }
    return sharedMyManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init {
    if (self = [super init])
    {
        //Read language plist
        self.languageISO2Code = [[NSLocale preferredLanguages] objectAtIndex:0];
        self.languageISO2DefaultCode = @"en";
        [self readLanguageDictionary];
        
        //Read settings plist
        [self readSettingsDictionary];
    }
    return self;
}

#pragma mark - Read Settings Dictionary

- (void)readSettingsDictionary
{
    NSString *errorDesc;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"LPSettings.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"LPSettings" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    self.settingsDictionary = [[NSDictionary alloc] initWithDictionary:[NSPropertyListSerialization
                                                                  propertyListFromData:plistXML
                                                                  mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                  format:&format
                                                                  errorDescription:&errorDesc]];
    
    if (!self.settingsDictionary || [self.settingsDictionary count]==0)
    {
        NSLog(@"Error reading LPSettings plist: %@, format: %d", errorDesc, format);
    }
}

#pragma mark - Read Language Dictionary

- (void)readLanguageDictionary
{
    NSString *errorDesc;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",self.languageISO2Code]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:self.languageISO2Code ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    self.languageDictionary = [[NSDictionary alloc] initWithDictionary:[NSPropertyListSerialization
                                                                  propertyListFromData:plistXML
                                                                  mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                  format:&format
                                                                  errorDescription:&errorDesc]];
    if(!self.languageDictionary || [self.languageDictionary count]==0)
    {
        self.languageISO2Code=self.languageISO2DefaultCode;
        
        NSString *errorDesc;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",self.languageISO2Code]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:self.languageISO2Code ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        
        self.languageDictionary = [[NSDictionary alloc] initWithDictionary:[NSPropertyListSerialization
                                                                      propertyListFromData:plistXML
                                                                      mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                      format:&format
                                                                      errorDescription:&errorDesc]];
    }

    if (!self.languageDictionary || [self.languageDictionary count]==0)
    {
        NSLog(@"Error reading Language plist: %@, format: %d", errorDesc, format);
    }
}

#pragma mark - Network Methods

- (BOOL)checkNetworkAndShowError:(BOOL)error
{
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(internetStatus==NotReachable)
    {
        if(!self.networkAlertViewShown && error)
        {
            self.networkAlertViewShown = YES;
            
            NSDictionary *dic=[[[LPSharedManager sharedManager] languageDictionary] objectForKey:@"LPNoInternetConnectionError"];
            
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[dic objectForKey:@"Title"] andMessage:[dic objectForKey:@"Message"]];
            
            [alertView addButtonWithTitle:[dic objectForKey:@"ExitButton"] type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView)
            {
                self.networkAlertViewShown = NO;
                
                [alertView setDidDismissHandler:^(SIAlertView *alertView) {
                    exit(0);
                }];
            }];
            
            [alertView addButtonWithTitle:[dic objectForKey:@"OKButton"] type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView)
            {
                self.networkAlertViewShown = NO;
            }];
            
            [alertView show];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - Login

- (void)saveLoginHostname:(NSString*)hostname username:(NSString*)username password:(NSString*)password autoLogin:(BOOL)autoLogin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:hostname forKey:@"loginHostname"];
    [userDefaults setObject:username forKey:@"loginUsername"];
    [userDefaults setObject:password forKey:@"loginPassword"];
    [userDefaults setBool:autoLogin forKey:@"loginAutoLogin"];
    
    [userDefaults synchronize];
}

- (void)deleteLoginData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:@"loginHostname"];
    [userDefaults removeObjectForKey:@"loginUsername"];
    [userDefaults removeObjectForKey:@"loginPassword"];
    [userDefaults removeObjectForKey:@"loginAutoLogin"];
    
    [userDefaults synchronize];
}

@end
