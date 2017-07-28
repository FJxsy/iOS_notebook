#ifdef IMX_DEBUG_MONITOR
//
//  IMXPerformanceCommonRow.m
//  IMXPerformance
//
//  Created by Erick Xi on 9/6/16.
//  Copyright © 2016 Alipay. All rights reserved.
//

#import "IMXPerformanceCommonCell.h"

@interface IMXPerformanceCommonCell ()

@end

@implementation IMXPerformanceCommonCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setAccessoryView:nil];
        
        self.onoffSW = [[UISwitch alloc] init];
    }
    return self;
}


- (void)updateWithTitle:(NSString *)title detail:(NSString *)detail {
    [[self detailTextLabel] setText:detail];
    [[self textLabel] setText:title];

    if (self.hasDetail) {
        [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }

    [self setAccessoryView:self.onoffSW];
}

+ (CGFloat)cellHeight {
    return 44;
}

@end

#endif
