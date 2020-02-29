//
//  SpringboardNotificationObserver.m
//
//  Rhythm <https://github.com/JunyuKuang/Rhythm>
//  Copyright (C) 2019-2020  Junyu Kuang
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
