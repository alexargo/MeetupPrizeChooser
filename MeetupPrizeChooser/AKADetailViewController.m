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

@property (nonatomic, strong, readonly) RACCommand *executionCommand;

@end

@implementation AKADetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.requestManager = [[AKAMeetupRequestManager alloc] initWithKeyProvider:[[AKAMeetupAPIKeyProvider alloc]init]];

    [self observeEvent];
    [self configureRefresh];

    UIBarButtonItem *subtractBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:nil action:nil];
    subtractBarButtonItem.rac_command = [self executionCommand];
    [[subtractBarButtonItem.rac_command.executionSignals flatten]
     subscribeNext:^(NSArray *executions) {
        int startSuspense = 6;
        int count = 0;
        int executionsCount = [executions count];

        for (NSNumber * num in executions) {
            double delay = 0.1;
            int diff = executionsCount - count++;

            if (diff < startSuspense) {
                delay = 0.5 * (startSuspense - diff);
            }

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSInteger index = [num integerValue];
                [self execute:index];
            });
        }
    }];

    [RACObserve(self, rsvps) subscribeNext:^(NSArray *rsvps) {
        BOOL shouldEnable = (rsvps != nil) && ([rsvps count] > 1);
        subtractBarButtonItem.enabled = shouldEnable;
    }];

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

        [self randomizeRsvps:self.rsvps];
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

- (void)randomizeRsvps:(NSMutableArray *)rsvps
{
    NSUInteger count = [rsvps count];

    for (uint i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = arc4random_uniform(nElements) + i;
        [self.rsvps
         exchangeObjectAtIndex:i
             withObjectAtIndex:n];
    }
}

@synthesize executionCommand = _executionCommand;
- (RACCommand *)executionCommand
{
    if (_executionCommand == nil) {
        @weakify(self);
        _executionCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            return [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
                [subscriber sendNext:[self executionSequence]];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }

    return _executionCommand;
}

- (NSArray *)executionSequence
{
    NSMutableArray *picks = [[NSMutableArray alloc]initWithCapacity:[self.rsvps count]];
    NSInteger count = [self.rsvps count];

    for (uint i = 0; i < count - 1; ++i) {
        [picks addObject:@(arc4random_uniform(count - i))];
    }

    return picks;
}

- (void)execute:(NSInteger)index
{
    [self.rsvps removeObjectAtIndex:index];
    [self.collectionView
     deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index
                                                   inSection:0]]];
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
