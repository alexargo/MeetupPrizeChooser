//
//  AKAMeetupRequestManager.h
//  MeetupPrizePicker
//
//  Created by Alex Argo on 1/20/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

@class AKAMeetupAPIKeyProvider;

@interface AKAMeetupRequestManager : AFHTTPRequestOperationManager

- (id)initWithKeyProvider:(AKAMeetupAPIKeyProvider *)keyProvider;

- (RACSignal *)meetupsSignalWithID:(NSString *)meetupId;
- (RACSignal *)rsvpsSignalWithID:(NSString *)eventId;

- (NSArray *)requestEventsForMeetupId:(NSString *)meetupId
    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


- (NSArray *)requestRSVPsForEventId:(NSString *)eventId
    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
