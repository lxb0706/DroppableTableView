//
//  NSTimer+DT.h
//  DrappableTableView
//
//  Created by Chris on 2017/12/4.
//  Copyright © 2017年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DTTimerAction)(void);
@interface NSTimer (DT)


+ (NSTimer *)dt_scheduledTimerWithTimeInterval:(NSTimeInterval) interval action:(DTTimerAction)action repeats:(BOOL)repeats;


@end
