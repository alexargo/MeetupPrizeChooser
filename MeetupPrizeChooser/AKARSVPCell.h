//
//  AKARSVP.h
//  MeetupPrizeChooser
//
//  Created by Alex Argo on 1/20/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

@interface AKARSVPCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

- (void)configureCellWithRsvp:(NSDictionary *)rsvp;
- (RACSignal *)tapSignal;
@end
