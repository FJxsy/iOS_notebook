#ifdef IMX_DEBUG_MONITOR
//
//  IMXAssistiveControl.h
//  IMXPerformance
//
//  Created by Erick on 11/26/14.
//  Copyright (c) 2014 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMXAssistiveControl : UIControl

+ (instancetype)showAssistiveControlInView:(UIView *)view;
+ (instancetype)showAssistiveControlInView:(UIView *)view
                    expandedViewController:(UIViewController *)viewController;
+ (void)toggleAssistiveControlInView:(UIView *)view;

- (void)expand;
- (void)collapse;

@end

#endif
