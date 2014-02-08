//
//  LPPhotoViewController.h
//  LPFTPManager
//
//  Created by Luka Penger on 9/7/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPSharedManager.h"
#import <GRRequestsManager.h>
#import <GRListingRequest.h>


@interface LPPhotoViewController : UIViewController <GRRequestsManagerDelegate>

@property (nonatomic, strong) GRRequestsManager *requestsManager;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
    
- (void)loadPhotoForFilePath:(NSString*)path;
- (NSString*)getLocalFilePathForFileName:(NSString*)filename;
- (BOOL)deleteLocalFilePathForFileName:(NSString*)filename;
    
@end
