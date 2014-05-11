//
//  AKAMeetupAPIKeyProvider.h
//  MeetupPrizeChooser
//
//  Created by Alex Argo on 5/1/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

extern NSString *const AKAMeetupAPIKeySetNotification;

@interface AKAMeetupAPIKeyProvider : NSObject <UIAlertViewDelegate>
@property (nonatomic, copy) NSString *apiKey;

- (RACSignal *)meetupAPIKeyNeededSignal;
- (RACSignal *)meetupAPIKeySignal;
- (NSString *)meetupAPIKey;

@end
