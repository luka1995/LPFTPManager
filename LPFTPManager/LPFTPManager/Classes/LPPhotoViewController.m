//
//  LPPhotoViewController.m
//  LPFTPManager
//
//  Created by Luka Penger on 9/7/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//


#import "LPPhotoViewController.h"


@interface LPPhotoViewController ()

@end


@implementation LPPhotoViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [[[LPSharedManager sharedManager] languageDictionary] objectForKey:@"LPPhotoViewController_Title"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveImage = [[UIBarButtonItem alloc] initWithTitle:@"Save Image" style:UIBarButtonItemStyleBordered target:self action:@selector(saveImageToCameraRool)];
     self.navigationItem.rightBarButtonItem = saveImage;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.requestsManager = [[LPSharedManager sharedManager] requestsManagerFTP];
    self.requestsManager.delegate = self;

    //NSLog(@"%@",self.filePath);
}
    
- (void)viewDidDisappear:(BOOL)animated
{
    [self deleteLocalFilePathForFileName:self.fileName];
}
    
- (void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
    
    if(fileName.length>0)
    {
        self.title = fileName;
    } else {
        self.title = [[[LPSharedManager sharedManager] languageDictionary] objectForKey:@"LPPhotoViewController_Title"];
    }
}

- (void)loadPhotoForFilePath:(NSString*)path
{
    if(!path || [path isEqualToString:@""])
    {
        path = @"/";
        
    }
    
    self.requestsManager = [[LPSharedManager sharedManager] requestsManagerFTP];
    self.requestsManager.delegate = self;
    
    [self.requestsManager addRequestForDownloadFileAtRemotePath:path toLocalPath:[self getLocalFilePathForFileName:self.fileName]];
    [self.requestsManager startProcessingRequests];
}

- (NSString*)getLocalFilePathForFileName:(NSString*)filename
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:filename];

    return localFilePath;
}
    
- (BOOL)deleteLocalFilePathForFileName:(NSString*)filename
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:filename];

    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:localFilePath error:&error];
    
    if(error)
    {
        NSLog(@"%@",error.description);
        
        return NO;
    }
    
    return YES;
}
    
- (void)saveImageToCameraRool
{
    NSString *filePath = [self getLocalFilePathForFileName:self.fileName];
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if(image)
    {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
}
    
#pragma mark - GRRequestsManagerDelegate
    
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDownloadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    NSString *filePath = [self getLocalFilePathForFileName:self.fileName];
    
    [self.imageView setImage:[UIImage imageWithContentsOfFile:filePath]];
}
    
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailWritingFileAtPath:(NSString *)path forRequest:(id<GRDataExchangeRequestProtocol>)request error:(NSError *)error
{
    NSLog(@"error writing file at path");
}
    
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    NSLog(@"error loading image");
}
    
@end
