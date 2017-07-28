#ifdef IMX_DEBUG_MONITOR
//
//  IMXAssistiveControl.m
//  IMXPerformance
//
//  Created by Erick on 11/26/14.
//  Copyright (c) 2014 Alipay. All rights reserved.
//

#import "IMXAssistiveControl.h"
#import "IMXPerformanceSettingViewController.h"
#import "IMXStickyControl.h"
#import <pop/POP.h>
#import <Masonry/Masonry.h>

static const CGFloat kAssistiveControlWidth = 50;
static const CGFloat kAssistiveControlAnimationSpeed = 300;
static const CGFloat kAssistiveControlAnimationDuration = 0.2;
static const CGFloat kAssistiveControlBorderInactiveColorAlpha = 0.3;
static const CGFloat kAssistiveControlInactiveAnimationDelay = 1;
static const CGFloat kAssistiveControlShadowMaskColorAlpha = 0.7;
static const CGFloat kAssistiveControlBorderWidth = 3.f;

static const CGFloat kAssistiveControlBigNumber = 2000.f;

@interface IMXStickyControl ()

@property(nonatomic, assign) CGFloat leftOffset;
@property(nonatomic, assign) CGFloat bottomOffset;

- (void)moveToPosition:(CGPoint)center;

@end

@interface IMXAssistiveControl () <IMXStickyControlDelegate>

@property(nonatomic, weak, readwrite) IMXStickyControl *stickyControl;
@property(nonatomic, assign) CGPoint position;
@property(nonatomic, assign, getter=isAnimating) BOOL animating;
@property(nonatomic, strong) UIView *shadowBackground;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property(nonatomic, assign, getter=isCollapsed) BOOL collapsed;
@property(nonatomic, strong) UIViewController *expandedViewController; //展开的viewController

@property(nonatomic, assign, getter=isVisible) BOOL visible;

@end

@implementation IMXAssistiveControl

+ (instancetype)showAssistiveControlInView:(UIView *)view {
    return [self showAssistiveControlInView:view expandedViewController:nil];
}

+ (instancetype)showAssistiveControlInView:(UIView *)view expandedViewController:(UIViewController *)viewController {
    IMXAssistiveControl *assistiveControl = [[IMXAssistiveControl alloc] init];
    assistiveControl.tag = 19828;
    IMXStickyControl *stickyControl = [[IMXStickyControl alloc] initWithContentView:assistiveControl];
    [stickyControl setDelegate:assistiveControl];
    assistiveControl.stickyControl = stickyControl;
    if (viewController) {
        assistiveControl.expandedViewController = viewController;
    } else {
        IMXPerformanceSettingViewController *settingsVC = [[IMXPerformanceSettingViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:settingsVC];
        assistiveControl.expandedViewController = nc;
    }
    assistiveControl.visible = YES;


    [view addSubview:stickyControl];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:assistiveControl action:@selector(awesomeGestureDidRecognized:)];
    [tap setNumberOfTapsRequired:2];
    [tap setNumberOfTouchesRequired:2];
    [view addGestureRecognizer:tap];
    return assistiveControl;
}

+ (void)toggleAssistiveControlInView:(UIView *)view {
    IMXAssistiveControl *control = (IMXAssistiveControl *)[view viewWithTag:19828];
    //    [control performSelector:@selector(tapGestureDidRecognized:) withObject:nil];
    [control collapse];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _collapsed = YES;
        _animating = NO;
        [self setBounds:CGRectMake(0, 0, kAssistiveControlWidth, kAssistiveControlWidth)];
        [self setClipsToBounds:YES];
        [self.layer setCornerRadius:kAssistiveControlWidth / 2];
        [self.layer setBorderColor:[[UIColor blackColor] colorWithAlphaComponent:kAssistiveControlBorderInactiveColorAlpha].CGColor];
        [self.layer setBorderWidth:kAssistiveControlBorderWidth];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDidRecognized:)];
        self.tapGesture = tap;
        [self addGestureRecognizer:tap];



        [self setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }
    return self;
}


- (CGSize)intrinsicContentSize {
    if (self.isCollapsed && !self.isAnimating) {
        return CGSizeMake(kAssistiveControlWidth, kAssistiveControlWidth);
    }
    return [self.expandedViewController.view bounds].size;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)resignFirstResponder {
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBorderColor];
    [animation setToValue:(id)[[UIColor blackColor] colorWithAlphaComponent:kAssistiveControlBorderInactiveColorAlpha].CGColor];
    [animation setDuration:kAssistiveControlAnimationDuration];
    [animation setBeginTime:CACurrentMediaTime() + kAssistiveControlInactiveAnimationDelay];
    [self.layer pop_addAnimation:animation forKey:@"border"];

    return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBorderColor];
    [animation setToValue:(id)[UIColor blackColor].CGColor];
    [animation setDuration:kAssistiveControlAnimationDuration];
    [self.layer pop_addAnimation:animation forKey:@"border"];
    return [super becomeFirstResponder];
}

- (void)expand {
    self.collapsed = NO;
    [self addSubview:self.expandedViewController.view];
    [self showExpandSpringAnimation];
    [self.expandedViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self becomeFirstResponder];
}

- (void)collapse {
    self.collapsed = YES;
    [self showCollapseSpringAnimation];
    [self.expandedViewController.view removeFromSuperview];
    [self.stickyControl stick];
    [self resignFirstResponder];
}

- (void)tapGestureDidRecognized:(UITapGestureRecognizer *)tap {
    self.collapsed = ![self isCollapsed];
    if (![self isCollapsed]) {
        [self expand];
    } else {
        [self collapse];
    }

    [self invalidateIntrinsicContentSize];
}

- (POPSpringAnimation *)newPopAnimation {
    self.animating = YES;
    POPSpringAnimation *animation = [POPSpringAnimation animation];
    [animation setProperty:[POPAnimatableProperty propertyWithName:@"com.taobao.movie.assistivecontrol.animation"
                                                       initializer:^(POPMutableAnimatableProperty *prop) {
                                                           [prop setReadBlock:^(id obj, CGFloat value[]) {
                                                               value[0] = self.expandedViewController.view.bounds.size.width;
                                                               value[1] = self.expandedViewController.view.bounds.size.height;
                                                           }];
                                                           [prop setWriteBlock:^(id obj, const CGFloat value[]) {
                                                               CGFloat width = value[0];
                                                               CGFloat height = value[1];
                                                               [self.expandedViewController.view setBounds:CGRectMake(0, 0, width, height)];
                                                               [self invalidateIntrinsicContentSize];
                                                           }];
                                                       }]];
    [animation setVelocity:[NSValue valueWithCGSize:CGSizeMake(kAssistiveControlAnimationSpeed, kAssistiveControlAnimationSpeed)]];
    [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        self.animating = NO;
    }];
    return animation;
}

- (POPBasicAnimation *)centerAnimation {
    POPBasicAnimation *centerAnimation = [POPBasicAnimation easeInEaseOutAnimation];
    [centerAnimation setProperty:[POPAnimatableProperty propertyWithName:@"toCenter"
                                                             initializer:^(POPMutableAnimatableProperty *prop) {
                                                                 [prop setReadBlock:^(id obj, CGFloat value[]) {
                                                                     value[0] = self.stickyControl.leftOffset;
                                                                     value[1] = self.stickyControl.bottomOffset;
                                                                 }];

                                                                 [prop setWriteBlock:^(id obj, const CGFloat value[]) {
                                                                     self.stickyControl.leftOffset = value[0];
                                                                     self.stickyControl.bottomOffset = value[1];

                                                                     [self.stickyControl setNeedsUpdateConstraints];
                                                                 }];
                                                             }]];
    return centerAnimation;
}

- (void)showExpandSpringAnimation {
    self.stickyControl.automaticStick = NO;
    POPSpringAnimation *animation = [self newPopAnimation];
    [self.expandedViewController.view setBounds:CGRectMake(0, 0, kAssistiveControlWidth, kAssistiveControlWidth)];
    [animation setName:@"ExpandAnimation"];
    [animation setFromValue:[NSValue valueWithCGSize:CGSizeMake(kAssistiveControlWidth, kAssistiveControlWidth)]];
    [animation setToValue:[NSValue valueWithCGSize:self.expandedViewController.preferredContentSize]];
    [self pop_addAnimation:animation forKey:@"expand"];

    POPBasicAnimation *centerAnimation = [self centerAnimation];
    [centerAnimation setFromValue:[NSValue valueWithCGSize:CGSizeMake(self.stickyControl.leftOffset, self.stickyControl.bottomOffset)]];
    [centerAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake((IMX_DEBUG_WINDOW_WIDTH - self.expandedViewController.preferredContentSize.width) / 2, (IMX_DEBUG_WINDOW_HEIGHT - self.expandedViewController.preferredContentSize.height) / 2)]];
    [self pop_addAnimation:centerAnimation forKey:@"center"];

    UIView *superView = [self.stickyControl superview];
    UIView *shadowBackground = nil;
    if (IMX_DEBUG_IOSVersionEqualOrLater(8.0)) {
        shadowBackground = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [shadowBackground setFrame:[superView bounds]];
    } else {
        shadowBackground = [[UIView alloc] initWithFrame:superView.bounds];
        [shadowBackground setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.0]];
    }
    self.shadowBackground = shadowBackground;
    [superView insertSubview:shadowBackground belowSubview:self.stickyControl];
    [self.shadowBackground addGestureRecognizer:self.tapGesture];
    [self.expandedViewController.view setAlpha:0];

    [self.shadowBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];


    [UIView animateWithDuration:.2
                     animations:^{
                         [self.shadowBackground setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:kAssistiveControlShadowMaskColorAlpha]];
                         [self.expandedViewController.view setAlpha:1];
                     }];
}

- (void)showCollapseSpringAnimation {
    POPSpringAnimation *animation = [self newPopAnimation];
    [animation setFromValue:[NSValue valueWithCGSize:self.expandedViewController.preferredContentSize]];
    [animation setToValue:[NSValue valueWithCGSize:CGSizeMake(kAssistiveControlWidth, kAssistiveControlWidth)]];
    [self pop_addAnimation:animation forKey:@"collapse"];


    [UIView animateWithDuration:kAssistiveControlAnimationDuration
        animations:^{
            [self.shadowBackground setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.0]];
        }
        completion:^(BOOL finished) {
            [self.shadowBackground removeFromSuperview];
            [self.stickyControl stick];
            [self addGestureRecognizer:self.tapGesture];
            [self.stickyControl setAutomaticStick:YES];

            if ([self.expandedViewController isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)self.expandedViewController popToRootViewControllerAnimated:NO];
            }
        }];
}

#pragma mark - Stick View Delegate
- (BOOL)stickyControlShouldBeginPan:(IMXStickyControl *)stickyControl {
    [self becomeFirstResponder];
    return YES;
}

- (void)stickyControlDidFinishPan:(IMXStickyControl *)stickyControl {
    if (self.isCollapsed) {
        [self resignFirstResponder];
    }
}

- (void)awesomeGestureDidRecognized:(UITapGestureRecognizer *)tap {
    if (self.isCollapsed) {
        if (self.visible) {
            //hide
            [self showInvisibleAnimation];
            self.visible = NO;
        } else {
            //show
            [self showVisibleAnimation];
            self.visible = YES;
        }
    }
}

- (void)showInvisibleAnimation {
    POPBasicAnimation *boundsAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBounds];
    [boundsAnimation setFromValue:[NSValue valueWithCGRect:CGRectMake(0, 0, kAssistiveControlWidth, kAssistiveControlWidth)]];
    [boundsAnimation setToValue:[NSValue valueWithCGRect:CGRectMake(0, 0, kAssistiveControlBigNumber, kAssistiveControlBigNumber)]];
    [self.layer pop_addAnimation:boundsAnimation forKey:@"invisible.bounds"];

    POPBasicAnimation *cornerAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    [cornerAnimation setFromValue:@(kAssistiveControlWidth / 2)];
    [cornerAnimation setToValue:@(kAssistiveControlBigNumber / 2)];
    [self.layer pop_addAnimation:cornerAnimation forKey:@"invisible.corner"];
    [cornerAnimation setCompletionBlock:^(POPAnimation *animation, BOOL completed) {
        self.stickyControl.hidden = YES;
    }];
}

- (void)showVisibleAnimation {
    self.stickyControl.hidden = NO;
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerBounds];
    [animation setFromValue:[NSValue valueWithCGRect:CGRectMake(0, 0, kAssistiveControlBigNumber, kAssistiveControlBigNumber)]];
    [animation setToValue:[NSValue valueWithCGRect:CGRectMake(0, 0, kAssistiveControlWidth, kAssistiveControlWidth)]];
    [self.layer pop_addAnimation:animation forKey:@"invisible.bounds"];

    POPBasicAnimation *cornerAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    [cornerAnimation setFromValue:@(kAssistiveControlBigNumber / 2)];
    [cornerAnimation setToValue:@(kAssistiveControlWidth / 2)];
    [self.layer pop_addAnimation:cornerAnimation forKey:@"invisible.corner"];
    [cornerAnimation setCompletionBlock:^(POPAnimation *animation, BOOL completed){

    }];
}



@end

#endif
