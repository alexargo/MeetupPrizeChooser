//
//  AKAMeetupAPIKeyProvider.m
//  MeetupPrizeChooser
//
//  Created by Alex Argo on 5/1/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import "AKAMeetupAPIKeyProvider.h"


NSString *const AKAMeetupAPIKeySetNotification = @"AKAMeetupAPIKeySetNotification";

@interface AKAMeetupAPIKeyProvider ()



@end

@implementation AKAMeetupAPIKeyProvider

- (RACSignal *)meetupAPIKeyNeededSignal
{
    return [RACObserve(self, apiKey) filter:^BOOL (NSString *value) {
        return value == nil;
    }];
}

- (RACSignal *)meetupAPIKeySignal
{
    return [RACObserve(self, apiKey) filter:^BOOL (NSString *value) {
        return value != nil;
    }];
}

- (NSString *)meetupAPIKey
{
    if (!self.apiKey) {
        self.apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"MeetupAPIKey"];

        if (!self.apiKey) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
//            [self showAPIPromptAlertView];
//            });
            return @"";
        }
    }

    return self.apiKey;
}

@synthesize apiKey = _apiKey;
- (NSString *)apiKey
{
    if (_apiKey) {
        return _apiKey;
    }

    _apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"MeetupAPIKey"];
    return _apiKey;
}

- (void)setApiKey:(NSString *)apiKey
{
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:@"MeetupAPIKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _apiKey = apiKey;
}

@end
