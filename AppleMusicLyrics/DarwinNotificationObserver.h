//
//  DarwinNotificationObserver.h
//  Lyrics
//
//  Created by Jonny Kuang on 5/12/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DarwinNotificationObserver : NSObject

@property (nonatomic) BOOL isDeviceSleepModeEnabled;
@property (nonatomic) BOOL isCoverSheetVisible;
@property (nonatomic, class, readonly) DarwinNotificationObserver *shared;

@end

NS_ASSUME_NONNULL_END
