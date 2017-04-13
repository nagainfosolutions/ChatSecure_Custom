//
//  OTRBuddyApprovalCell.m
//  ChatSecure
//
//  Created by Chris Ballinger on 6/1/16.
//  Copyright © 2016 Chris Ballinger. All rights reserved.
//

#import "OTRBuddyApprovalCell.h"
#import <AFNetworking/AFNetworking.h>
#import "OTRAccount.h"
#import "OTRDatabaseManager.h"
#import "OTRAccountsManager.h"
@import OTRAssets;
@import PureLayout;

@implementation OTRBuddyApprovalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat fontSize = 20.0f;
        self.approveButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeSuccess style:BButtonStyleBootstrapV3 icon:FACheck fontSize:fontSize];
        self.denyButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeDanger style:BButtonStyleBootstrapV3 icon:FATimes fontSize:fontSize];
        [self.contentView addSubview:self.approveButton];
        [self.contentView addSubview:self.denyButton];
        [self.approveButton addTarget:self action:@selector(approveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.denyButton addTarget:self action:@selector(denyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setThread:(id<OTRThreadOwner>)thread
{
    [super setThread:thread];
    __block NSString * name = [thread threadName];
    self.nameLabel.text = name;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.identifierLabel.text = [NSString stringWithFormat:@"%@ %@", name, WANTS_TO_CHAT_STRING()];
    if ([def valueForKey:[NSString stringWithFormat:@"user_name_%@",name]]) {
        name = [def valueForKey:[NSString stringWithFormat:@"user_name_%@",name]];
        self.nameLabel.text = name;
        self.identifierLabel.text = [NSString stringWithFormat:@"%@ %@", name, WANTS_TO_CHAT_STRING()];
    }else{
        [self getmyUserDataFromVROServer:name success:^(id responseObject) {
            [def setObject:[responseObject valueForKeyPath:@"data.full_name"] forKey:[NSString stringWithFormat:@"user_name_%@",name]];
            [def synchronize];
            name = [def valueForKey:[NSString stringWithFormat:@"user_details_%@",name]];
            self.nameLabel.text = name;
            self.identifierLabel.text = [NSString stringWithFormat:@"%@ %@", name, WANTS_TO_CHAT_STRING()];        } failure:^(NSError *error) {
                
        }];
    }
    
    
}

- (void)updateConstraints
{
    
    if (!self.addedConstraints) {
        CGSize size = CGSizeMake(35, 35);
        [self.approveButton autoSetDimensionsToSize:size];
        [self.approveButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.denyButton withOffset:-OTRBuddyImageCellPadding];
        [self.approveButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.denyButton autoSetDimensionsToSize:size];
        [self.denyButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:OTRBuddyImageCellPadding];
        [self.denyButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    }
    [super updateConstraints];
}

- (void) approveButtonPressed:(id)sender {
    if (self.actionBlock) {
        self.actionBlock(self, YES);
    }
}

- (void) denyButtonPressed:(id)sender {
    if (self.actionBlock) {
        self.actionBlock(self, NO);
    }
}
-(void)getmyUserDataFromVROServer:(NSString *)userId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure{
    //    if (!userId) {
    //        failure(nil);
    //    }
    NSOperationQueue *apiOperationQueue = [[NSOperationQueue alloc]init];
    apiOperationQueue.maxConcurrentOperationCount = 2;
    [apiOperationQueue addOperationWithBlock:^{
               NSString *urlString  ;
            urlString = [NSString stringWithFormat:@"users/%@",userId];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://vrocloud.com/vro_v3/v1/"]];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        OTRAccount *account = [self getDefaultAccount];
        if (account.accessToken) {
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", account.accessToken] forHTTPHeaderField:@"Authorization"];
        }
        [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    success(responseObject);
                }];
            }else{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failure(nil);
                }];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    }];
}
- (OTRAccount *)getDefaultAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"zom_DefaultAccount"] != nil) {
        NSString *accountUniqueId = [defaults objectForKey:@"zom_DefaultAccount"];
        
        __block OTRAccount *account = nil;
        [[OTRDatabaseManager sharedInstance].readOnlyDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            account = [OTRAccount fetchObjectWithUniqueID:accountUniqueId transaction:transaction];
        }];
        if (account != nil) {
            return account;
        }
    }
    NSArray *accounts = [OTRAccountsManager allAccountsAbleToAddBuddies];
    if (accounts != nil && accounts.count > 0)
    {
        return (OTRAccount *)accounts[0];
    }
    return nil;
}


@end
