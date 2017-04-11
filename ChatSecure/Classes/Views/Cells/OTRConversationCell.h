//
//  OTRConversationCelll.h
//  ChatSecure
//
//  Created by Bose on 11/04/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

#import "OTRBuddyImageCell.h"

@interface OTRConversationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonCall;
@property (weak, nonatomic) IBOutlet UILabel *conversationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *buttonUnreadCount;

@property (nonatomic, strong) UIColor *imageViewBorderColor;


- (void)updateDateString:(NSDate *)date;
- (void)setThread:(id <OTRThreadOwner>)thread;
+ (NSString *)reuseIdentifier;

@end
