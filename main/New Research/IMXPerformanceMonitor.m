#ifdef IMX_DEBUG_MONITOR
//
//  IMXPerformanceMonitor.m
//  IMXPerformance
//
//  Created by Michael Hanyee on 14/10/31.
//  Copyright (c) 2014年 Alipay. All rights reserved.
//

#import "IMXPerformanceMonitor.h"
#import <QuartzCore/QuartzCore.h>
#import <mach/mach.h>
#import <sys/sysctl.h>
//#import "TBHDMainViewController.h"
//#if defined(PERFORMANCE_MONITOR)
//#import "JDStatusBarNotification.h"
//#endif



@interface IMXPerformanceMonitor ()

@property(nonatomic) NSUInteger currentFPS;
@property(nonatomic) NSUInteger averageFPS;
@property(nonatomic) double currentMemory;
@property(nonatomic) double virtualMemory;
@property(nonatomic) double maxUsedMemory;
@property(nonatomic) double cpuUsage;
@property(nonatomic) CFTimeInterval currentMainThreadBlockTime;
@property(nonatomic, strong) CADisplayLink *displayLink;

@end


static IMXPerformanceMonitor *instance;
static const NSInteger sampleInterval = 10; //取n帧平均
static const CGFloat secondToAverage = 5;   //n s平均

static CFTimeInterval previousTime = -1;
static CFTimeInterval startTimeToAverage = 0;
static NSUInteger framesToAverage = 0;

@implementation IMXPerformanceMonitor


+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IMXPerformanceMonitor alloc] init];
    });

    return instance;
}

- (void)start {
    if (self.displayLink != nil) {
        return;
    }
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    self.displayLink.frameInterval = sampleInterval;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)tick:(CADisplayLink *)displayLink {
    [self monitorCPU];
    [self monitorFPS];
    [self monitorMemory];
    [self monitorMainThreadBlocker];
}

- (void)monitorCPU {
    self.cpuUsage = cpu_usage();
}



- (void)monitorFPS {
    if (previousTime < 0) {
        previousTime = CACurrentMediaTime();
        return;
    }

    //瞬时帧率
    CFTimeInterval currentTime = CACurrentMediaTime();
    CFTimeInterval timeSpentOnFrame = currentTime - previousTime;
    previousTime = currentTime;
    self.currentFPS = sampleInterval / timeSpentOnFrame;

    //平均帧率
    framesToAverage += sampleInterval;
    if (startTimeToAverage == 0) {
        startTimeToAverage = currentTime;
    }
    if (currentTime - startTimeToAverage >= secondToAverage) {
        self.averageFPS = framesToAverage / (currentTime - startTimeToAverage);
        startTimeToAverage = currentTime;
        framesToAverage = 0;

#if defined(PERFORMANCE_MONITOR)
        if (self.averageFPS < 55) {
            [self reportLowFPS:self.averageFPS onPage:[self currentViewControllerName]];
            if (![JDStatusBarNotification isVisible]) {
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@: 平均FPS过低：%d", [self currentViewControllerName], self.averageFPS] dismissAfter:1 styleName:JDStatusBarStyleWarning];
            }
        }
#endif
    }

#if defined(PERFORMANCE_MONITOR)
    if (self.currentFPS < 50) {
        [self reportLowFPS:self.currentFPS onPage:[self currentViewControllerName]];
        if (![JDStatusBarNotification isVisible]) {
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@: 瞬时FPS过低：%d", [self currentViewControllerName], self.currentFPS] dismissAfter:1 styleName:JDStatusBarStyleWarning];
        }
    }
#endif
}


- (void)monitorMemory {
    IMXPerformanceInfo performanceInfo = [self performanceInfo];
    self.currentMemory = performanceInfo.appMemory;
    self.virtualMemory = performanceInfo.virtualMemory;
    if (self.currentMemory > self.maxUsedMemory) {
        self.maxUsedMemory = self.currentMemory;
    }
}

- (void)monitorMainThreadBlocker {
    CFTimeInterval previousMainTheadTime = CACurrentMediaTime();
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentMainThreadBlockTime = CACurrentMediaTime() - previousMainTheadTime;

#if defined(PERFORMANCE_MONITOR)
        if (self.currentMainThreadBlockTime * 1000 > 50) {
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@: 主线程超过50ms：%.1fms", [self currentViewControllerName], self.currentMainThreadBlockTime * 1000] dismissAfter:3 styleName:JDStatusBarStyleError];
        }
#endif
    });
}

#pragma mark - helper

- (IMXPerformanceInfo)performanceInfo {
    IMXPerformanceInfo info = {};

    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return info;
    }
    info.appMemory = taskInfo.resident_size / 1024.0 / 1024.0;
    info.virtualMemory = taskInfo.virtual_size / 1024.0 / 1024.0;


    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount_vm = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn_vm = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount_vm);
    if (kernReturn_vm != KERN_SUCCESS) {
        return info;
    }
    info.availableMemory = ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;


    uint64_t userMemorySize = 0;

    int mib[2];
    size_t length;
    mib[0] = CTL_HW;
    mib[1] = HW_USERMEM;
    length = sizeof(int64_t);
    sysctl(mib, 2, &userMemorySize, &length, NULL, 0);
    info.userMemory = userMemorySize / 1024.0 / 1024.0;

    return info;
}

float cpu_usage() {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;

    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }

    thread_array_t thread_list;
    mach_msg_type_number_t thread_count;

    thread_info_data_t thinfo;
    mach_msg_type_number_t thread_info_count;

    thread_basic_info_t basic_info_th;

    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }


    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;

    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
            (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }

        basic_info_th = (thread_basic_info_t)thinfo;

        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }

    } // for each thread

    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);

    return tot_cpu;
}

//-(TBHDViewController *)currentViewController{
//    TBHDMainViewController *mainController = [TBHDMainViewController sharedMainViewController];
//    TBHDViewController *sidebarController = (TBHDViewController*)mainController.mainSidebarContainerController.sidebarController;
//    TBHDViewController *modalController = (TBHDViewController*)mainController.mainModalContainerController.tbhdModalViewController;
//    TBHDViewController *topController =  (TBHDViewController*)[mainController.mainNavigationController topViewController];
//
//    if (modalController) {
//        return  modalController;
//    }
//
//    if (sidebarController) {
//        return  sidebarController;
//    }
//
//    if (topController) {
//        return  topController;
//    }
//    return nil;
//}
//
//-(NSString *)currentViewControllerName{
//    TBHDViewController *controller = [self currentViewController];
//    if ([controller isKindOfClass:[TBHDViewController class]] && controller.pageName) {
//        return controller.pageName;
//    }else{
//        return NSStringFromClass([controller class]);
//    }
//}
//
//-(void)reportLowFPS:(NSUInteger)fps onPage:(NSString*)pageName{
//    [TBHDPage trackPage:pageName
//                eventId:65102
//                   arg1:pageName
//                   arg2:[NSString stringWithFormat:@"%d",fps]];
//}

@end

#endif
