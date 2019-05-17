//
//  SpringboardNotificationObserver.h
//  Lyrics
//
//  Created by Jonny Kuang on 5/12/19.
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
