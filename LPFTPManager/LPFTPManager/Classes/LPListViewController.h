//
//  LPListViewController.h
//  LPFTPManager
//
//  Created by Luka Penger on 8/28/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPSharedManager.h"
#import <GRRequestsManager.h>
#import <GRListingRequest.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <sys/dirent.h>
#import "LPPhotoViewController.h"


@interface LPListViewController : UIViewController <GRRequestsManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) GRRequestsManager *requestsManager;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSString *folderPath;
   
- (void)loadListForPath:(NSString*)path;

@end
