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

@property (nonatomic, copy) NSString *apiKey;

@end

@implementation AKAMeetupAPIKeyProvider

- (RACSignal *)meetupAPIKeySignal
{
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        if (self.apiKey == nil) {
            //Something
        }

        [subscriber sendNext:self.apiKey];
        [subscriber sendCompleted];
        return nil;
    }];

    return s;
}

- (NSString *)meetupAPIKey
{
    if (!self.apiKey) {
        self.apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"MeetupAPIKey"];

        if (!self.apiKey) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
            [self showAPIPromptAlertView];
//            });
            return @"";
        }
    }

    return self.apiKey;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textField = [alertView textFieldAtIndex:0];

    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"MeetupAPIKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:AKAMeetupAPIKeySetNotification object:self];
}

- (void)showAPIPromptAlertView; {
    UIAlertView *apiAlert = [[UIAlertView alloc] initWithTitle:@"API Key" message:@"What's your meetup.com API key?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    apiAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [apiAlert show];
}


@end
