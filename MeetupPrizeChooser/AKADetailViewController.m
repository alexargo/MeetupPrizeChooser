//
//  AKADetailViewController.m
//  MeetupPrizeChooser
//
//  Created by Alex Argo on 1/20/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import "AKADetailViewController.h"
#import "RACEXTScope.h"
#import <AFNetworking/AFNetworking.h>

#import "AKAMeetupAPIKeyProvider.h"
#import "AKAMeetupRequestManager.h"
#import "AKARSVPCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface AKADetailViewController ()

@property (nonatomic, strong) NSMutableArray *rsvps;
@property (nonatomic, strong) AKAMeetupRequestManager *requestManager;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation AKADetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.requestManager = [[AKAMeetupRequestManager alloc] initWithKeyProvider:[[AKAMeetupAPIKeyProvider alloc]init]];

    [self observeEvent];
    [self configureRefresh];

    UIBarButtonItem *subtractBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(byeByeAvatar)];
    self.navigationItem.rightBarButtonItems = @[subtractBarButtonItem];
}

- (void)configureRefresh
{
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.collectionView addSubview:self.refreshControl];
    [[self.refreshControl
      rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        [self downloadRSVPs];
    }];
}

- (void)observeEvent
{
    // Update the user interface for the detail item.
    @weakify(self);
    [[RACObserve(self, event) filter:^BOOL (NSObject *value) {
        return value != nil;
    }] subscribeNext:^(NSDictionary *event) {
        @strongify(self);
        self.navigationItem.title = event[@"name"];
        self.detailDescriptionLabel.text = [event description];
        [self downloadRSVPs];
    }];
}

- (void)downloadRSVPs
{
    [self.refreshControl beginRefreshing];
    [[self.requestManager
      rsvpsSignalWithID:self.event[@"id"]] subscribeNext:^(NSArray *rsvps) {
        self.rsvps = [rsvps mutableCopy];
        [self randomizeRsvps];
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
    }

                                                   error:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.refreshControl endRefreshing];
    }];
}

- (void)randomizeRsvps
{
    NSUInteger count = [self.rsvps count];

    for (uint i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = arc4random_uniform(nElements) + i;
        [self.rsvps
         exchangeObjectAtIndex:i
             withObjectAtIndex:n];
    }
}

- (void)byeByeAvatar
{
    if ([self.rsvps count] > 1) {
        int indexToRemove = arc4random_uniform((int)[self.rsvps count]);
        [self.rsvps removeObjectAtIndex:indexToRemove];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:indexToRemove inSection:0]]];
        int startSuspense = 6;
        double delayInSeconds = 0.1;

        if ([self.rsvps count] < startSuspense) {
            delayInSeconds = 0.5 * (startSuspense - [self.rsvps count]);
        }

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self byeByeAvatar];
        });
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.rsvps) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.rsvps count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AKARSVPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RSVPCell" forIndexPath:indexPath];

    cell.nameLabel.text = self.rsvps[indexPath.row][@"member"][@"name"];
    UIImage *defaultImage = [UIImage imageNamed:@"Forstall"];

    if (self.rsvps[indexPath.row][@"member_photo"]) {
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:self.rsvps[indexPath.row][@"member_photo"][@"photo_link"]] placeholderImage:defaultImage];
    } else {
        cell.avatarImageView.image = defaultImage;
    }

    return cell;
}

@end
