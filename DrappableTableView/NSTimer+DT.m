//
//  NSTimer+DT.m
//  DrappableTableView
//
//  Created by Chris on 2017/12/4.
//  Copyright © 2017年 Chris. All rights reserved.
//

#import "NSTimer+DT.h"

@implementation NSTimer (DT)

+ (NSTimer *)dt_scheduledTimerWithTimeInterval:(NSTimeInterval)interval action:(DTTimerAction)action repeats:(BOOL)repeats{
    
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(dt_blockInvoke:) userInfo:[action copy] repeats:repeats];
}

+ (void)dt_blockInvoke:(NSTimer *)timer{
    DTTimerAction action = timer.userInfo;
    !action?:action();
}

@end
