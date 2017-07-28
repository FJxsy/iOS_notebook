#ifdef IMX_DEBUG_MONITOR
//
//  IMXStickyControl.m
//  IMXCommonUI
//
//  Created by Michael Hanyee on 14/11/20.
//  Copyright (c) 2014年 Alipay. All rights reserved.
//

#import "IMXStickyControl.h"
#import <Masonry/Masonry.h>
#import <pop/POP.h>

typedef NS_ENUM(NSInteger, AnimationDirection) {
    AnimationDirectionTop = 0,
    AnimationDirectionBottom,
    AnimationDirectionLeft,
    AnimationDirectionRight
};

@interface IMXStickyControl () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property(nonatomic, readwrite, strong) UIView *contentView;
@property(nonatomic, assign, getter=hasCreated) BOOL created;

@property(nonatomic, assign) CGFloat leftOffset;
@property(nonatomic, assign) CGFloat bottomOffset;
@property(nonatomic, assign) CGFloat leftBase;
@property(nonatomic, assign) CGFloat bottomBase;
@property(nonatomic, strong) MASConstraint *leftConstraint;
@property(nonatomic, strong) MASConstraint *bottomConstraint;

@end

@implementation IMXStickyControl

- (id)init {
    self = [super init];
    if (self) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDidRecognize:)];
        _panGesture.delegate = self;
        
        [self addGestureRecognizer:_panGesture];
        self.userInteractionEnabled = YES;

        _automaticStick = YES;
    }

    return self;
}

- (instancetype)initWithContentView:(UIView *)contentView {
    self = [self init];
    if (self) {
        _contentView = contentView;
        [self addSubview:contentView];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    self.created = NO;
    if (self.superview != nil) {
        [self setNeedsUpdateConstraints];
    }
}


- (void)updateConstraints {
    UIView *superview = self.superview;
    if (!self.hasCreated) {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(superview).priorityHigh();
            make.right.lessThanOrEqualTo(superview).priorityHigh();
            make.top.greaterThanOrEqualTo(superview).priorityHigh();
            make.bottom.lessThanOrEqualTo(superview).priorityHigh();

            self.leftConstraint = make.left.equalTo(superview.mas_left).with.offset(self.leftOffset).priorityMedium();
            self.bottomConstraint = make.bottom.equalTo(superview.mas_bottom).with.offset(-self.bottomOffset).priorityMedium();
        }];
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.created = YES;
    } else {
        [self.leftConstraint setOffset:self.leftOffset];
        [self.bottomConstraint setOffset:-self.bottomOffset];
    }
    [super updateConstraints];
}

- (CGSize)intrinsicContentSize {
    if (self.contentView) {
        return [self.contentView bounds].size;
    }
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

- (void)moveToPosition:(CGPoint)center {
    CGRect superRect = self.superview.bounds;
    self.leftOffset = center.x - CGRectGetWidth(self.bounds) / 2;
    self.bottomOffset = CGRectGetHeight(superRect) + CGRectGetHeight(self.bounds) - center.y;

    [self setNeedsUpdateConstraints];
}

- (AnimationDirection)magnetDirection {
    CGRect superRect = self.superview.bounds;
    CGFloat x = (CGRectGetWidth(superRect) / 2) > self.center.x ? self.center.x : self.center.x - CGRectGetWidth(superRect);
    CGFloat y = (CGRectGetHeight(superRect) / 2) > self.center.y ? self.center.y : self.center.y - CGRectGetHeight(superRect);
    if (ABS(x) <= ABS(y)) {
        return x > 0 ? AnimationDirectionLeft : AnimationDirectionRight;
    } else {
        return y > 0 ? AnimationDirectionTop : AnimationDirectionBottom;
    }
}

- (void)showMagnetAnimation:(CGPoint)beginPoint {
    AnimationDirection direction = [self magnetDirection];
    CGRect superRect = self.superview.bounds;

    POPBasicAnimation *animation = [POPBasicAnimation animation];
    [animation setProperty:[POPAnimatableProperty propertyWithName:@"com.taobao.movie.performance.animation.magnet"
                                                       initializer:^(POPMutableAnimatableProperty *prop) {
                                                           [prop setReadBlock:^(id obj, CGFloat *value) {
                                                               switch (direction) {
                                                                   case AnimationDirectionTop:
                                                                   case AnimationDirectionBottom:
                                                                       *value = self.bottomOffset;
                                                                       break;
                                                                   case AnimationDirectionLeft:
                                                                   case AnimationDirectionRight:
                                                                       *value = self.leftOffset;
                                                                       break;
                                                                   default:
                                                                       break;
                                                               }
                                                           }];
                                                           [prop setWriteBlock:^(id obj, const CGFloat *value) {
                                                               switch (direction) {
                                                                   case AnimationDirectionTop:
                                                                   case AnimationDirectionBottom:
                                                                       self.bottomOffset = *value;
                                                                       break;
                                                                   case AnimationDirectionLeft:
                                                                   case AnimationDirectionRight:
                                                                       self.leftOffset = *value;
                                                                       break;
                                                                   default:
                                                                       break;
                                                               }

                                                               [self setNeedsUpdateConstraints];
                                                           }];
                                                       }]];
    [animation setRemovedOnCompletion:YES];
    switch (direction) {
        case AnimationDirectionTop:
            [animation setFromValue:@(self.bottomOffset)];
            [animation setToValue:@(CGRectGetHeight(superRect) - CGRectGetHeight(self.bounds))];
            break;
        case AnimationDirectionBottom:
            [animation setFromValue:@(self.bottomOffset)];
            [animation setToValue:@0];
            break;
        case AnimationDirectionLeft:
            [animation setFromValue:@(self.leftOffset)];
            [animation setToValue:@0];
            break;
        case AnimationDirectionRight:
            [animation setFromValue:@(self.leftOffset)];
            [animation setToValue:@(CGRectGetWidth(superRect) - CGRectGetWidth(self.bounds))];
            break;
        default:
            break;
    }


    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setDuration:.2];
    [self pop_addAnimation:animation forKey:@"magnet"];
}


- (void)panGestureDidRecognize:(UIPanGestureRecognizer *)panGesture {
    UIGestureRecognizerState state = [panGesture state];
    CGPoint translation = [panGesture translationInView:self];
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        self.leftOffset = self.leftBase + translation.x;
        self.bottomOffset = self.bottomBase - translation.y;
    } else if (state == UIGestureRecognizerStateEnded) {
        if (self.shouldAutomaticStick) {
            [self showMagnetAnimation:translation];
        }
        if ([self.delegate respondsToSelector:@selector(stickyControlDidFinishPan:)]) {
            [self.delegate stickyControlDidFinishPan:self];
        }
    }

    [self setNeedsUpdateConstraints];
}

#pragma mark - UIGestureRecognizer Delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([self.delegate respondsToSelector:@selector(stickyControlShouldBeginPan:)]) {
            if (![self.delegate stickyControlShouldBeginPan:self]) {
                return NO;
            }
        }
        self.leftBase = CGRectGetMinX(self.frame);
        self.bottomBase = CGRectGetHeight(self.superview.bounds) - CGRectGetMaxY(self.frame);
    }
    return YES;
}

- (void)stick {
    [self showMagnetAnimation:self.center];
}

@end

#endif
