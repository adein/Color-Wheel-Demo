//
//  AJDWheelColorSection.m
//  ColorWheel
//
//  Created by Aaron on 12/5/15.
//  Copyright © 2015 Aaron DeGrow. All rights reserved.
//

#import "AJDWheelColorSection.h"

NS_ASSUME_NONNULL_BEGIN

@implementation AJDWheelColorSection

@synthesize sectionNumber = _sectionNumber;
@synthesize startAngle = _startAngle;
@synthesize midpointAngle = _midpointAngle;
@synthesize endAngle = _endAngle;
@synthesize radius = _radius;

- (instancetype)initWithFrame:(CGRect)frame sectionNumber:(int)section startAngle:(float)start endAngle:(float)end radius:(float)radius color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        _sectionNumber = section;
        _startAngle = [self ajd_normalizeRadians:start];
        _endAngle = [self ajd_normalizeRadians:end];
        _midpointAngle = [self ajd_normalizeRadians:(start + end) / 2];
        _radius = radius;
        _color = color;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame sectionNumber:(int)section startAngle:(float)start endAngle:(float)end radius:(float)radius {
    return [self initWithFrame:frame sectionNumber:section startAngle:start endAngle:end radius:radius color:[UIColor blackColor]];
}

/**
 *  Returns an angle in radians normalized to [0 : 2*PI]
 *
 *  @param radians The radians to normalize
 *
 *  @return The angle normalized between 0 and 2PI.
 */
- (float)ajd_normalizeRadians:(float)radians {
    float result = (radians > 2 * M_PI) ? radians - (2 * M_PI) : radians;
    result = (result >= 0) ? result : result + (2 * M_PI);
    return result;
}

- (void)drawRect:(CGRect)rect {
    // Create a path for the wheel section
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:center];
    [path addArcWithCenter:center radius:self.radius startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    [path closePath];
    
    // Create a CALayer with the path and color
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.fillColor = self.color.CGColor;
    slice.lineWidth = 0;
    slice.path = path.CGPath;

    [self.layer addSublayer:slice];
}

@end

NS_ASSUME_NONNULL_END
