//
//  SpringboardNotificationObserver.m
//  Lyrics
//
//  Created by Jonny Kuang on 5/12/19.
//

#import "SpringboardNotificationObserver.h"
#import <notify.h>

@implementation SpringboardNotificationObserver

+ (instancetype)shared
{
    static SpringboardNotificationObserver *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SpringboardNotificationObserver alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isDeviceSleepModeEnabled = NO;
        self.isCoverSheetVisible = NO;
        [self registerBlankScreenObserver];
        [self registerLockStateObserver];
    }
    return self;
}

- (void)registerBlankScreenObserver
{
    // is in device's sleep mode
    int notify_token;
    
    notify_register_dispatch("com.apple.springboard.hasBlankedScreen", &notify_token, dispatch_get_main_queue(), ^(int token) {
        uint64_t state;
        notify_get_state(token, &state);
        self.isDeviceSleepModeEnabled = state != 0;
    });
}

- (void)registerLockStateObserver
{
    // is Cover Sheet (lock screen) visible
    int notify_token;
    
    notify_register_dispatch("com.apple.springboard.lockstate", &notify_token, dispatch_get_main_queue(), ^(int token) {
        uint64_t state;
        notify_get_state(token, &state);
        self.isCoverSheetVisible = state != 0;
    });
}

@end
