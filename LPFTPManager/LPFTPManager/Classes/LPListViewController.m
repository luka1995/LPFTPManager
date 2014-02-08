//
//  LPListViewController.m
//  LPFTPManager
//
//  Created by Luka Penger on 8/28/13.
//  Copyright (c) 2013 Luka Penger. All rights reserved.
//

#import "LPListViewController.h"


@interface LPListViewController ()


@end


@implementation LPListViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [[[LPSharedManager sharedManager] languageDictionary] objectForKey:@"LPListViewController_Title"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initRefreshControl];
    
    if([self.folderName isEqualToString:@""] || !self.folderName)
    {
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem *buttonLogout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
        self.navigationItem.leftBarButtonItem = buttonLogout;
    } else {
        self.navigationItem.hidesBackButton = NO;
    }
    
    //UIBarButtonItem *buttonUpload = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleBordered target:self action:@selector(selectFile)];
   // self.navigationItem.rightBarButtonItem = buttonUpload;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.requestsManager = [[LPSharedManager sharedManager] requestsManagerFTP];
    self.requestsManager.delegate = self;
    
    [self.tableView reloadData];
    
    //NSLog(@"%@",self.folderPath);
}

- (void)logout
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
/*
- (void)selectFile
{

}
*/
- (void)setFolderName:(NSString *)folderName
{
    _folderName = folderName;
    
    if(folderName.length>0)
    {
        self.title = folderName;
    } else {
        self.title = [[[LPSharedManager sharedManager] languageDictionary] objectForKey:@"LPListViewController_Title"];
    }
}

- (void)setListArray:(NSMutableArray *)listArray
{
    _listArray = [self editListArray:listArray];
}

- (void)initRefreshControl
{
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    
    [self.refreshControl addTarget:self action:@selector(refreshControlDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshControlDidBeginRefreshing:(id)sender
{
    [self loadListForPath:self.folderPath];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.listArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.listArray objectAtIndex:section] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        if([[self.listArray objectAtIndex:section] count]>0)
        {
            return [NSString stringWithFormat:@"Folders: %d",[[self.listArray objectAtIndex:section] count]];
        }
    } else {
        if([[self.listArray objectAtIndex:section] count]>0)
        {
            return [NSString stringWithFormat:@"Files: %d",[[self.listArray objectAtIndex:section] count]];
        }
    }
    
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    NSDictionary *file = (NSDictionary*)[[self.listArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [file objectForKey:(id)kCFFTPResourceName];
    
    double size = [[file objectForKey:(id)kCFFTPResourceSize] doubleValue];
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KiB",@"MiB",@"GiB",@"TiB",nil];
    
    while (size > 1024) {
        size /= 1024;
        multiplyFactor++;
    }
    
    //NSLog(@"%@",file.description);

    int type = [[file objectForKey:(id)kCFFTPResourceType] intValue];
    
    if(type==DT_DIR)
    {
        cell.imageView.image = [UIImage imageNamed:@"LPFolder1"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"LPFile1"];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Size: %.2f %@",size, [tokens objectAtIndex:multiplyFactor]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *file = (NSDictionary*)[[self.listArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSString *name = [file objectForKey:(id)kCFFTPResourceName];
    int type = [[file objectForKey:(id)kCFFTPResourceType] intValue];
    
    NSString *path = [self.folderPath stringByAppendingPathComponent:name];
    
    if(type==DT_DIR)
    {
        LPListViewController *listViewController = [[LPListViewController alloc] initWithNibName:@"LPListViewController" bundle:nil];
        listViewController.folderName = name;
        listViewController.folderPath = path;
        [self.navigationController pushViewController:listViewController animated:YES];
        
        [listViewController loadListForPath:path];
    } else if(type==DT_REG) {
        
        if([name hasSuffix:@".jpg"] || [name hasSuffix:@".png"] || [name hasSuffix:@".JPG"] || [name hasSuffix:@".PNG"] || [name hasSuffix:@".JPEG"] || [name hasSuffix:@".jpeg"] || [name hasSuffix:@".gif"] || [name hasSuffix:@".GIF"] || [name hasSuffix:@".bmp"] || [name hasSuffix:@".BMP"])
        {
            LPPhotoViewController *photoViewController = [[LPPhotoViewController alloc] initWithNibName:@"LPPhotoViewController" bundle:nil];
            photoViewController.fileName = name;
            photoViewController.filePath = path;
            [self.navigationController pushViewController:photoViewController animated:YES];
            
            [photoViewController loadPhotoForFilePath:path];
        }
    }
    
    //NSLog(@"%d",type);
}

- (void)loadListForPath:(NSString*)path
{
    if(!path || [path isEqualToString:@""])
    {
        path = @"/";
        
    }
    
    self.requestsManager = [[LPSharedManager sharedManager] requestsManagerFTP];
    self.requestsManager.delegate = self;
    
    [self.requestsManager addRequestForListDirectoryAtPath:path];
    [self.requestsManager startProcessingRequests];
}

- (NSMutableArray*)editListArray:(NSMutableArray*)array
{
    NSMutableArray *newFolderArray = [NSMutableArray new];
    NSMutableArray *newOtherArray = [NSMutableArray new];
    
    for(int a=0;a<array.count;a++)
    {
        NSDictionary *file = (NSDictionary*)[array objectAtIndex:a];
        
        int type = [[file objectForKey:(id)kCFFTPResourceType] intValue];

        switch (type) {
            case DT_DIR:
                [newFolderArray addObject:file];
                break;
            default:
                [newOtherArray addObject:file];
                break;
        }
    }

    NSMutableArray *newArray = [NSMutableArray arrayWithObjects:newFolderArray,newOtherArray, nil];
    
    return newArray;
}

#pragma mark - GRRequestsManagerDelegate

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing
{
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSDictionary *file in ((GRListingRequest *)request).filesInfo) {
        
        if(![[file objectForKey:(id)kCFFTPResourceName] isEqualToString:@"."] && ![[file objectForKey:(id)kCFFTPResourceName] isEqualToString:@".."])
        {
            [array addObject:file];
        }
    }

    self.listArray = array;
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

@end
