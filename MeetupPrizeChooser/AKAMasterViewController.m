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

@property (nonatomic, strong) AKAMeetupRequestManager *requestManager;
@property (nonatomic, strong) NSMutableArray *objects;

@end

@implementation AKAMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    AKAMeetupAPIKeyProvider *apiKeyProvider = [[AKAMeetupAPIKeyProvider alloc]init];
    [apiKeyProvider.meetupAPIKeySignal
     subscribeNext:^(id x) {
        self.requestManager = [[AKAMeetupRequestManager alloc] init];
    }];

    [RACObserve(self, requestManager) subscribeNext:^(id x) {
        [self downloadMeetups];
    }];
}

- (void)downloadMeetups
{
    [self.requestManager
     requestEventsForMeetupId:@"1715312"
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        NSDictionary *responseDictionary = responseObject;
        NSArray *events = responseDictionary[@"results"];
        NSLog(@"Count: %@", @([events count]));

        for (NSDictionary * event in events) {
            if (!_objects) {
                _objects = [[NSMutableArray alloc] init];
            }

            [_objects insertObject:event
                           atIndex:0];
            NSLog(@"Event: %@", event[@"name"]);
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                        inSection:0];
            [self.tableView
             insertRowsAtIndexPaths:@[indexPath]
                   withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }

                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
   // Override to support rearranging the table view.
   - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
   {
   }
 */

/*
   // Override to support conditional rearranging of the table view.
   - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
   {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
   }
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *event = _objects[indexPath.row];
        [[segue destinationViewController] setEvent:event];
    }
}

@end
