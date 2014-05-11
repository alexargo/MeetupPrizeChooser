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

- (id)initWithKeyProvider:(AKAMeetupAPIKeyProvider *)keyProvider
{
    self = [super initWithBaseURL:[NSURL URLWithString:@"https://api.meetup.com/2/"]];

    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.keyProvider = keyProvider;
    }

    return self;
}

- (RACSignal *)meetupsSignalWithID:(NSString *)meetupId
{
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        [self requestEventsForMeetupId:meetupId
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
            [subscriber sendNext:response[@"results"]];
            [subscriber sendCompleted];
        }

                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //inspect for api key failure
            self.keyProvider.apiKey = nil;
            [subscriber sendError:error];
        }];
        return nil;
    }];

    return s;
}

- (AFHTTPRequestOperation *)requestEventsForMeetupId:(NSString *)meetupId
    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *params = @{ @"group_id": meetupId, @"key": self.keyProvider.meetupAPIKey, /*@"time":@"1m",*/ @"status": @"past,upcoming", @"rsvp": @"yes" /*@"page":@(25)*/ };
    AFHTTPRequestOperation *operation = [self GET:@"events" parameters:params success:success failure:failure];

    return operation;
}

- (RACSignal *)rsvpsSignalWithID:(NSString *)eventId
{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        @strongify(self);
        [self requestRSVPsForEventId:eventId
                             success:^(AFHTTPRequestOperation *operation, NSDictionary *response) {
            [subscriber sendNext:response[@"results"]];
            [subscriber sendCompleted];
        }

                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (AFHTTPRequestOperation *)requestRSVPsForEventId:(NSString *)eventId
    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *params = @{ @"event_id": eventId, @"key": self.keyProvider.meetupAPIKey, @"page:": @(50), @"rsvp": @"yes" };
    AFHTTPRequestOperation *operation = [self GET:@"rsvps" parameters:params success:success failure:failure];

    return operation;
}

@end
