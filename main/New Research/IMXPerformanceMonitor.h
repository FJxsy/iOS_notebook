#ifdef IMX_DEBUG_MONITOR
//
//  IMXPerformanceMonitor.h
//  IMXPerformance
//
//  Created by Michael Hanyee on 14/10/31.
//  Copyright (c) 2014年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    double virtualMemory;
    double availableMemory;
    double appMemory;
    double userMemory;
    float cpuUsage;
} IMXPerformanceInfo;

@interface IMXPerformanceMonitor : NSObject

@property(nonatomic, readonly) NSUInteger currentFPS;
@property(nonatomic, readonly) NSUInteger averageFPS;
@property(nonatomic, readonly) double currentMemory;
@property(nonatomic, readonly) double virtualMemory;
@property(nonatomic, readonly) double maxUsedMemory;
@property(nonatomic, readonly) double cpuUsage;
@property(nonatomic, readonly) CFTimeInterval currentMainThreadBlockTime;

+ (instancetype)sharedInstance;
- (void)start;
- (void)stop;
- (IMXPerformanceInfo)performanceInfo;

@end
#endif
