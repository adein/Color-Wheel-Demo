//
//  AJDWheelColorSection.h
//  ColorWheel
//
//  Created by Aaron on 12/5/15.
//  Copyright © 2015 Aaron DeGrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AJDWheelControl.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Describes a wheel section that is a filled color.
 */
@interface AJDWheelColorSection : UIView <AJDWheelSectionProtocol>

/**
 *  The fill color for the wheel section.
 */
@property (strong, nonatomic, readonly) UIColor *color;

- (instancetype)initWithFrame:(CGRect)frame sectionNumber:(int)section startAngle:(float)start endAngle:(float)end radius:(float)radius color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
