#ifdef IMX_DEBUG_MONITOR
//
//  IMXStickyControl.h
//  IMXCommonUI
//
//  Created by Michael Hanyee on 14/11/20.
//  Copyright (c) 2014年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class IMXStickyControl;

@protocol IMXStickyControlDelegate <NSObject>
@optional
- (BOOL)stickyControlShouldBeginPan:(IMXStickyControl *)stickyControl;
- (void)stickyControl:(IMXStickyControl *)stickyControl didMoveTo:(CGPoint)point;
- (void)stickyControlDidFinishPan:(IMXStickyControl *)stickyControl;

@end

@interface IMXStickyControl : UIView

- (instancetype)initWithContentView:(UIView *)contentView;
- (void)stick;

@property(nonatomic, strong, readonly) UIView *contentView;
@property(nonatomic, weak) id<IMXStickyControlDelegate> delegate;
@property(nonatomic, assign, getter=shouldAutomaticStick) BOOL automaticStick;

@end

#endif
