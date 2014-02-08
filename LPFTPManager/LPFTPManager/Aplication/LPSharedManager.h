//
//  LPSharedManager.h
//  LPFTPManager
//
//  Created by Luka Penger on 8/15/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Reachability/Reachability.h>
#import <SIAlertView/SIAlertView.h>
#import <GRRequestsManager.h>

@interface LPSharedManager : NSObject

@property (nonatomic, strong) NSString *languageISO2Code;
@property (nonatomic, strong) NSString *languageISO2DefaultCode;
@property (nonatomic, strong) NSDictionary *languageDictionary;
@property (nonatomic, strong) NSDictionary *settingsDictionary;

@property (nonatomic, strong) GRRequestsManager *requestsManagerFTP;

#pragma mark Singleton Methods

+ (id)sharedManager;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)init;

#pragma mark - Read Settings Dictionary

- (void)readSettingsDictionary;

#pragma mark - Read Language Dictionary

- (void)readLanguageDictionary;

#pragma mark - Network Methods

- (BOOL)checkNetworkAndShowError:(BOOL)error;

#pragma mark - Login

- (void)saveLoginHostname:(NSString*)hostname username:(NSString*)username password:(NSString*)password autoLogin:(BOOL)autoLogin;
- (void)deleteLoginData;

@end
