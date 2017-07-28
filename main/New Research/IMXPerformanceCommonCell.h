#ifdef IMX_DEBUG_MONITOR
//
//  IMXPerformanceCommonRow.h
//  IMXPerformance
//
//  Created by Erick Xi on 9/6/16.
//  Copyright © 2016 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMXPerformanceCommonCell : UITableViewCell
@property(nonatomic, assign) BOOL *hasDetail;
@property(nonatomic, strong) UISwitch * onoffSW;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)updateWithTitle:(NSString *)title detail:(NSString *)detail;
+ (CGFloat)cellHeight;
@end

#endif
