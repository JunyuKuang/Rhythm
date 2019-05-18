//
//  SpringboardNotificationObserver.h
//
//  Rhythm <https://github.com/JunyuKuang/Rhythm>
//  Copyright (C) 2019  Junyu Kuang
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpringboardNotificationObserver : NSObject

@property (nonatomic) BOOL isDeviceSleepModeEnabled;
@property (nonatomic) BOOL isCoverSheetVisible;
@property (nonatomic, class, readonly) SpringboardNotificationObserver *shared;

- (instancetype)init NS_SWIFT_UNAVAILABLE("Use SpringboardNotificationObserver.shared instead.");

@end

NS_ASSUME_NONNULL_END
