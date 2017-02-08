//
//  TYTweetsTableViewCell.h
//  TweetMe
//
//  Created by Mac on 2/7/17.
//  Copyright © 2017 RFTP Technologies Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYTweetsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
