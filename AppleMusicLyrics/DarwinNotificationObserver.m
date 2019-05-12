//
//  DarwinNotificationObserver.m
//  Lyrics
//
//  Created by Jonny Kuang on 5/12/19.
//

#import "DarwinNotificationObserver.h"
#import <notify.h>

@implementation DarwinNotificationObserver

+ (instancetype)shared
{
    static DarwinNotificationObserver *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DarwinNotificationObserver alloc] init];
        [instance registerBlankScreenObserver];
        [instance registerLockStateObserver];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isDeviceSleepModeEnabled = NO;
        self.isCoverSheetVisible = NO;
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
