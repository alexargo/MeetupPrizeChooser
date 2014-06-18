//
//  AKARSVP.m
//  MeetupPrizeChooser
//
//  Created by Alex Argo on 1/20/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import "AKARSVPCell.h"

@interface AKARSVPCell ()
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation AKARSVPCell

- (void)awakeFromNib
{
    [self prepareForReuse];
    self.tapGesture = [[UITapGestureRecognizer alloc]init];
    [self.tapGesture setNumberOfTapsRequired:2];
    [self.avatarImageView addGestureRecognizer:self.tapGesture];
}

- (RACSignal *)tapSignal
{
    return self.tapGesture.rac_gestureSignal;
}

- (void)configureCellWithRsvp:(NSDictionary *)rsvp
{
    self.nameLabel.text = rsvp[@"member"][@"name"];
}

- (void)prepareForReuse
{
    static UIImage *defaultImage;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultImage = [UIImage imageNamed:@"Forstall"];
    });
    self.avatarImageView.image = defaultImage;
}

@end
