//
//  AKAMeetupRequestManager.h
//  MeetupPrizePicker
//
//  Created by Alex Argo on 1/20/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface AKAMeetupRequestManager : AFHTTPRequestOperationManager

- (NSArray *)requestEventsForMeetupId:(NSString *)meetupId
                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


- (NSArray *)requestRSVPsForEventId:(NSString *)eventId
                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
