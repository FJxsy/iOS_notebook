#ifdef IMX_DEBUG_MONITOR
//
//  IMXPerformanceMonitorView.m
//  IMXPerformance
//
//  Created by Michael Hanyee on 14/10/30.
//  Copyright (c) 2014年 Alipay. All rights reserved.
//

#import "IMXPerformanceMonitorView.h"
#import "IMXPerformanceMonitor.h"
#import <FLEX/FLEX.h>
#import <Masonry/Masonry.h>

//@class ChartView;

CGFloat const kPerformanceViewWidth = 100;
CGFloat const kPerformanceViewHeight = 90;

@interface IMXPerformanceMonitorView () <UIGestureRecognizerDelegate> {
    BOOL _isVisible;
}

@property(nonatomic, strong) IMXPerformanceMonitor *fpsMeter;
@property(nonatomic, strong) NSTimer *updateTimer;
@property(nonatomic, strong) UILabel *textLabel;

@end



@implementation IMXPerformanceMonitorView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //
        self.userInteractionEnabled = YES;

        _isVisible = YES;

        _fpsMeter = [IMXPerformanceMonitor sharedInstance];
        [_fpsMeter start];
        self.backgroundColor = [UIColor colorWithRed:0 green:2 / 255.0 blue:51 / 255.0 alpha:0.45];

        _updateTimer = [NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_updateTimer forMode:NSRunLoopCommonModes];

        _textLabel = [[UILabel alloc] init];
        _textLabel.numberOfLines = 0;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.userInteractionEnabled = NO;
        [self addSubview:_textLabel];

        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)update {

    NSMutableAttributedString *statsString = [[NSMutableAttributedString alloc] init];

    [statsString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"FPS: %lu/60\n", (unsigned long)self.fpsMeter.currentFPS]
                                                                        attributes:@{NSForegroundColorAttributeName : [UIColor yellowColor]}]];

    [statsString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"MAIN: %.3fms\n", self.fpsMeter.currentMainThreadBlockTime * 1000]
                                                                        attributes:@{NSForegroundColorAttributeName : [UIColor greenColor]}]];

    [statsString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"MEM: %.2fMB\n", self.fpsMeter.currentMemory]
                                                                        attributes:@{NSForegroundColorAttributeName : [UIColor cyanColor]}]];

    [statsString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"VM: %.2fMB\n", self.fpsMeter.virtualMemory]
                                                                        attributes:@{NSForegroundColorAttributeName : [UIColor orangeColor]}]];

    [statsString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"CPU: %.1f%%\n", self.fpsMeter.cpuUsage]
                                                                        attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}]];

    self.textLabel.attributedText = statsString;
    self.textLabel.font = [UIFont systemFontOfSize:12];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(kPerformanceViewWidth, kPerformanceViewHeight);
}

//- (void)doubleFingerDoubleTap:(UITapGestureRecognizer *)sender
//{
//    [self toggleMonitorView];
//}

//- (void)toggleMonitorView
//{
//    if (_isVisible)
//    {
//        // hide
//        [[FLEXManager sharedManager] hideExplorer];
//
//        [UIView animateWithDuration:.3 animations:^
//        {
//            [self mas_makeConstraints:^(MASConstraintMaker *make)
//             {
//                 self.hideConstraint = make.right.equalTo(self.superview.mas_left);
//             }];
//            [self layoutIfNeeded];
//        }];
//    }
//    else
//    {
//        // show
//        [self.hideConstraint uninstall];
//        [[FLEXManager sharedManager] showExplorer];
//        [UIView animateWithDuration:.3 animations:^
//         {
//             [self layoutIfNeeded];
//         }];
//    }
//    _isVisible = !_isVisible;
//}

@end

#endif
