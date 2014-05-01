//
//  AKADetailViewController.h
//  MeetupPrizeChooser
//
//  Created by Alex Argo on 1/20/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKADetailViewController : UICollectionViewController <UICollectionViewDataSource>

@property (strong, nonatomic) NSDictionary *event;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
