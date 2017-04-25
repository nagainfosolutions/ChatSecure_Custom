//
//  OTRConversationCelll.m
//  ChatSecure
//
//  Created by Bose on 11/04/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//
#import "OTRConversationCell.h"
#import "OTRBuddy.h"
#import "OTRAccount.h"
#import "OTRIncomingMessage.h"
#import "OTROutgoingMessage.h"
#import "OTRDatabaseManager.h"
#import "OTRTheme.h"
#import "OTRColors.h"

@import YapDatabase;
@import PureLayout;
@import OTRAssets;


@interface OTRConversationCell ()


@end


@implementation OTRConversationCell

@synthesize imageViewBorderColor = _imageViewBorderColor;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.buttonCall setImage:[UIImage imageNamed:@"VoiceCallIcon"] forState:UIControlStateNormal];
    [self.buttonCall.imageView setContentMode:UIViewContentModeScaleAspectFit];

    CALayer *cellImageLayer = self.avatarImageView.layer;
    cellImageLayer.borderWidth = 0.0;
    
    [cellImageLayer setMasksToBounds:YES];
    [cellImageLayer setBorderColor:[self.imageViewBorderColor CGColor]];
    self.buttonUnreadCount.backgroundColor = [UIColor redColor];
    
}


-(void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.buttonUnreadCount.bounds
                              byRoundingCorners:UIRectCornerTopRight
                              cornerRadii:CGSizeMake(self.buttonUnreadCount.bounds.size.height * 2, self.buttonUnreadCount.bounds.size.height * 2)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.buttonUnreadCount.layer.mask = maskLayer;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setThread:(id <OTRThreadOwner>)thread
{
   // [super setThread:thread];
    
    UIImage *avatarImage = [thread avatarImage];
    if(avatarImage) {
        self.avatarImageView.image = avatarImage;
    }
    else {
        self.avatarImageView.image = [self defaultImage];
    }
    UIColor *statusColor =  [OTRColors colorWithStatus:[thread currentStatus]];
    if (statusColor) {
        self.avatarImageView.layer.borderWidth = 1.5;
    } else {
        self.avatarImageView.layer.borderWidth = 0.0;
    }
    self.imageViewBorderColor = statusColor;
    
    
    if ([thread isKindOfClass:[OTRBuddy class]]) {
        NSDictionary *user = [OTRAccount fetchUserWithUsernameOrUserId:[(OTRBuddy *)thread username]];
        if (user) {
            self.nameLabel.text = user[@"full_name"];
        } else {
            self.nameLabel.text = @"Unkown buddy";
        }
    } else {
        NSString * nameString = [thread threadName];
        self.nameLabel.text = nameString;
    }
    
    __block OTRAccount *account = nil;
    __block id <OTRMessageProtocol> lastMessage = nil;
    __block NSUInteger unreadMessages = 0;
    
    [[OTRDatabaseManager sharedInstance].readOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        account = [transaction objectForKey:[thread threadAccountIdentifier] inCollection:[OTRAccount collection]];
        unreadMessages = [thread numberOfUnreadMessagesWithTransaction:transaction];
        lastMessage = [thread lastMessageWithTransaction:transaction];
    }];
    
    
    //    UIFont *currentFont = self.nameLabel.font;
    //    CGFloat fontSize = currentFont.pointSize;
    
    self.conversationLabel.text = lastMessage.text;
    
    if (unreadMessages > 0) {
        //unread message
        [self.buttonUnreadCount setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)unreadMessages] forState:UIControlStateNormal];
        self.buttonUnreadCount.hidden = NO;
        self.nameLabel.textColor = [UIColor blackColor];
    } else {
        self.buttonUnreadCount.hidden = YES;
        self.nameLabel.textColor = [UIColor darkGrayColor];
    }
    [self updateDateString:lastMessage.date];
}

- (UIColor *)imageViewBorderColor
{
    if (!_imageViewBorderColor) {
        _imageViewBorderColor = [UIColor blackColor];
    }
    return _imageViewBorderColor;
}

- (void)setImageViewBorderColor:(UIColor *)imageViewBorderColor
{
    _imageViewBorderColor = imageViewBorderColor;
    
    [self.avatarImageView.layer setBorderColor:[_imageViewBorderColor CGColor]];
}

- (void)updateDateString:(NSDate *)date
{
    self.dateLabel.text = [self dateString:date];
}

- (NSString *)dateString:(NSDate *)messageDate
{
    NSTimeInterval timeInterval = fabs([messageDate timeIntervalSinceNow]);
    NSString * dateString = nil;
    if (timeInterval < 60){
        dateString = @"Now";
    }
    else if (timeInterval < 60*60) {
        int minsInt = timeInterval/60;
        NSString * minString = @"mins ago";
        if (minsInt == 1) {
            minString = @"min ago";
        }
        dateString = [NSString stringWithFormat:@"%d %@",minsInt,minString];
    }
    else if (timeInterval < 60*60*24){
        // show time in format 11:00 PM
        dateString = [NSDateFormatter localizedStringFromDate:messageDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    }
    else if (timeInterval < 60*60*24*7) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEE" options:0 locale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:messageDate];
        
    }
    else if (timeInterval < 60*60*25*365) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dMMM" options:0
                                                                    locale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:messageDate];
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dMMMYYYY" options:0
                                                                    locale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:messageDate];
    }
    
    
    
    return dateString;
}


- (UIImage *)defaultImage
{
    return [UIImage imageNamed:@"person" inBundle:[OTRAssets resourcesBundle] compatibleWithTraitCollection:nil];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}


@end
