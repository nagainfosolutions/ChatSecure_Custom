//
//  OTRAppDelegate.h
//  Off the Record
//
//  Created by Chris Ballinger on 8/11/11.
//  Copyright (c) 2011 Chris Ballinger. All rights reserved.
//
//  This file is part of ChatSecure.
//
//  ChatSecure is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ChatSecure is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ChatSecure.  If not, see <http://www.gnu.org/licenses/>.

@import UIKit;

#import "OTRTheme.h"
#import "OTRMessagesViewController.h"
#import "OTRConversationViewController.h"
#import <UserNotifications/UserNotifications.h>
@class PushController;
@class PushOTRListener;
@protocol OTRThreadOwner;


@interface OTRAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) OTRConversationViewController *conversationViewController;
@property (nonatomic, strong) OTRMessagesViewController *messagesViewController;

@property (nonatomic, strong) PushOTRListener *pushListener;

@property (nonatomic, strong) NSTimer *backgroundTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) BOOL didShowDisconnectionWarning;

- (void) showConversationViewController;

- (NSString *)activeThreadYapKey;

+ (instancetype)appDelegate;

- (OTRAccount *)getDefaultAccount;

- (UIViewController *)visibleViewController;
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler;
- (void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken;
#pragma mark Theming

@property (nonatomic, strong, readonly) OTRTheme *theme;
/** Override this in subclass to use a different theme class */
- (Class) themeClass;


@end
