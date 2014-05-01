//
//  AKAMeetupRequestManager.m
//  MeetupPrizePicker
//
//  Created by Alex Argo on 1/20/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import "AKAMeetupRequestManager.h"
#import "AKAMeetupAPIKeyProvider.h"

@interface AKAMeetupRequestManager ()

@property (nonatomic, strong) AKAMeetupAPIKeyProvider *keyProvider;

@end

@implementation AKAMeetupRequestManager

- (id) init {
    self = [super initWithBaseURL:[NSURL URLWithString:@"https://api.meetup.com/2/"]];
    if(self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.keyProvider = [[AKAMeetupAPIKeyProvider alloc] init];
    }
    return self;
}

- (AFHTTPRequestOperation *)requestEventsForMeetupId:(NSString *)meetupId
                                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{

    NSDictionary *params = @{@"group_id":meetupId, @"key":self.keyProvider.meetupAPIKey, /*@"time":@"1m",*/ @"status":@"past,upcoming", @"rsvp":@"yes"/*@"page":@(25)*/};
    AFHTTPRequestOperation *operation = [self GET:@"events" parameters:params success:success failure:failure];
    return operation;
}

- (AFHTTPRequestOperation *)requestRSVPsForEventId:(NSString *)eventId
                                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSDictionary *params = @{@"event_id":eventId, @"key":self.keyProvider.meetupAPIKey, @"page:":@(50), @"rsvp":@"yes"};
    AFHTTPRequestOperation *operation = [self GET:@"rsvps" parameters:params success:success failure:failure];
    return operation;
}

@end
