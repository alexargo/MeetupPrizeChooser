//
//  AKAMasterViewController.m
//  MeetupPrizeChooser
//
//  Created by Alex Argo on 1/20/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import "ReactiveCocoa.h"
#import "RACEXTScope.h"
#import <AFNetworking/AFNetworking.h>
#import "AKAMasterViewController.h"
#import "AKADetailViewController.h"
#import "AKAMeetupRequestManager.h"
#import "AKAMeetupEventCell.h"
#import "AKAMeetupAPIKeyProvider.h"



@interface AKAMasterViewController ()
@property (nonatomic, strong) AKAMeetupAPIKeyProvider *apiKeyProvider;
@property (nonatomic, strong) AKAMeetupRequestManager *requestManager;
@property (nonatomic, strong) NSArray *objects;

@end

@implementation AKAMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.apiKeyProvider = [[AKAMeetupAPIKeyProvider alloc]init];

    @weakify(self);
    [self.apiKeyProvider.meetupAPIKeyNeededSignal
     subscribeNext:^(id x) {
        @strongify(self);
        [self promptForKey];
    }];

    [self.apiKeyProvider.meetupAPIKeySignal
     subscribeNext:^(id x) {
        @strongify(self);
        self.requestManager = [[AKAMeetupRequestManager alloc] initWithKeyProvider:self.apiKeyProvider];
    }];

    [[RACObserve(self, requestManager)
      filter:^BOOL (id value) {
        @strongify(self);
        return self.requestManager != nil;
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self downloadMeetups];
    }];
}

- (void)promptForKey
{
    UIAlertView *apiAlert = [[UIAlertView alloc] initWithTitle:@"API Key" message:@"What's your meetup.com API key?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];

    apiAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    @weakify(self);
    [apiAlert.rac_buttonClickedSignal
     subscribeNext:^(NSNumber *buttonIndex) {
        @strongify(self);
        UITextField *textField = [apiAlert textFieldAtIndex:0];
        self.apiKeyProvider.apiKey = textField.text;
    }];

    [apiAlert show];
}

- (void)downloadMeetups
{
    [[[self.requestManager
       meetupsSignalWithID:@"1715312"] map:^id (NSArray *events) {
        return [events sortedArrayUsingComparator:^NSComparisonResult (NSDictionary *e1, NSDictionary *e2) {
            return [e2[@"time"]
                    compare:e1[@"time"]];
        }];
    }]
     subscribeNext:^(NSArray *events) {
        NSLog(@"meetups downloaded");
        self.objects = events;
        [self.tableView reloadData];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AKAMeetupEventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];

    NSDictionary *event = _objects[indexPath.row];
    NSNumber *timeSince1970 = event[@"time"];
    NSTimeInterval timeInterval = timeSince1970.longLongValue;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(timeInterval / 1000)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];

    cell.nameLabel.text = event[@"name"];
    cell.dateLabel.text = [formatter stringFromDate:date];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *event = _objects[indexPath.row];
        [[segue destinationViewController] setEvent:event];
    }
}

@end
