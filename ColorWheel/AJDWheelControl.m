//
//  AJDWheelControl.m
//  ColorWheel
//
//  Created by Aaron on 12/5/15.
//  Copyright © 2015 Aaron DeGrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AJDWheelControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface AJDWheelControl ()

@property (weak, nonatomic, readonly) id<AJDWheelDataSource> dataSource;
@property (strong, nonatomic, readonly) UIView *container;
@property (assign, nonatomic) CGAffineTransform initialTransform;
@property (assign, nonatomic) float initialTouchAngle;
@property (strong, nonatomic) NSArray<id<AJDWheelSectionProtocol>> *sections;
@property (strong, nonatomic, readwrite, nullable) id<AJDWheelSectionProtocol> currentSection;

@end

@implementation AJDWheelControl


#pragma mark Lifecycle

- (instancetype)initWithFrame:(CGRect)frame withDataSource:(id<AJDWheelDataSource>)source delegate:(nullable id<AJDWheelDelegate>)wheelDelegate {
    self = [super initWithFrame:frame];
    if (self) {
        _container = [[UIView alloc] initWithFrame:frame];
        _dataSource = source;
        _delegate = wheelDelegate;
        
        // Get the sections from the data source
        _sections = [_dataSource wheelSectionsForControlSize:_container.bounds.size];
        _numberOfSections = [NSNumber numberWithUnsignedInteger:[_sections count]];
        if ([_sections count] > 0) {
            _currentSection = _sections[0];
        }

        // Add the sections to the UIView container
        for (id<AJDWheelSectionProtocol> section in _sections) {
            if ([section isKindOfClass:[UIView class]]) {
                [_container addSubview:(UIView *)section];
            }
        }
        
        // Add the container as a subview of this control
        _container.userInteractionEnabled = NO;
        [self addSubview:_container];
    }
    return self;
}


#pragma mark AJDWheelControl

/**
 *  Returns the distance of the touch point from the center of the wheel.
 *
 *  @param point The touch point
 *
 *  @return The distance from the center.
 */
- (float)ajd_distanceFromCenter:(CGPoint)point {
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    float deltaX = point.x - center.x;
    float deltaY = point.y - center.y;
    return sqrt((deltaX * deltaX) + (deltaY * deltaY));
}

/**
 *  Returns the angle of the touch point for the wheel.
 *
 *  @param touch The touch.
 *
 *  @return The angle of the touch on the wheel.
 */
- (float)ajd_angleFromTouch:(UITouch *)touch {
    // ArcTan using Y & X lengths to get the angle.
    CGPoint touchPoint = [touch locationInView:self];
    float deltaX = touchPoint.x - self.container.center.x;
    float deltaY = touchPoint.y - self.container.center.y;
    return atan2(deltaY, deltaX);
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

/**
 *  Snap the wheel to the nearest section.
 *
 *  @param duration The duration of the rotation animation.
 */
- (void)ajd_snapToSectionWithAnimationDuration:(float)duration {
    // Get the angle of the touch
    CGFloat radians = atan2f(self.container.transform.b, self.container.transform.a);
    radians = (6 * M_PI / 4) - radians;
    radians = [self ajd_normalizeRadians:radians];
    CGFloat transformAngle = 0.0;
    
    // Iterate through the sections to see which one is now selected
    for (id<AJDWheelSectionProtocol> s in self.sections) {
        // Handle sections where the section crosses radian coordinate system threshold
        if (s.endAngle < s.startAngle) {
            if (radians > s.startAngle || radians < s.endAngle) {
                // Set transform value to rotate the container to the midpoint of the selected section.
                if (radians > s.startAngle) {
                    transformAngle = radians - s.midpointAngle;
                } else {
                    transformAngle = 2 * M_PI - s.midpointAngle + radians;
                }
                self.currentSection = s;
                break;
            }
        } else if (radians > s.startAngle && radians < s.endAngle) {
            // Set transform value to rotate the container to the midpoint of the selected section.
            transformAngle = radians - s.midpointAngle;
            self.currentSection = s;
            break;
        }
    }
    
    // Animation to rotate to the midpoint of the selected section
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    self.container.transform = CGAffineTransformRotate(self.container.transform, transformAngle);
    [UIView commitAnimations];
    
    // Notify delegate of new section
    if (self.delegate && [self.delegate respondsToSelector:@selector(wheelDidChangeToSection:)]) {
        [self.delegate wheelDidChangeToSection:self.currentSection];
    }
}

- (void)setSection:(NSNumber *)section withAnimationDuration:(float)duration {
    if (section && section.intValue < self.numberOfSections.intValue) {
        // Iterate through sections to find the matching section number
        for (id<AJDWheelSectionProtocol> s in self.sections) {
            if (s.sectionNumber == section.intValue) {
                // Get current angle
                CGFloat radians = atan2f(self.container.transform.b, self.container.transform.a);
                radians = (6 * M_PI / 4) - radians;
                radians = [self ajd_normalizeRadians:radians];
                
                // Calculate amount need to rotate
                CGFloat transformAngle = radians - s.midpointAngle;
                
                self.currentSection = s;
                
                // Animation to rotate to the new section
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:duration];
                self.container.transform = CGAffineTransformRotate(self.container.transform, transformAngle);
                [UIView commitAnimations];
                
                // Notify delegate of new section
                if (self.delegate && [self.delegate respondsToSelector:@selector(wheelDidChangeToSection:)]) {
                    [self.delegate wheelDidChangeToSection:s];
                }
                break;
            }
        }
    }
}

/**
 *  Called when a user first touches the control.
 *  Store information needed to rotate the wheel.
 *
 *  @param touch The UITouch.
 *  @param event The UIEvent.
 *
 *  @return YES to support dragging.
 */
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    // Ignore touches too close to the center or OOB
    CGPoint touchPoint = [touch locationInView:self];
    float dist = [self ajd_distanceFromCenter:touchPoint];
    if (dist < 30 || dist > 170) {
        return NO;
    }
    
    // Save initial touch angle and transform
    self.initialTouchAngle = [self ajd_angleFromTouch:touch];
    self.initialTransform = self.container.transform;
    
    // return YES to allow dragging
    return YES;
}

/**
 *  Called continuously to track a touch event.
 *  Use the touch/drag event to rotate the wheel.
 *
 *  @param touch The UITouch.
 *  @param event The UIEvent.
 *
 *  @return YES if tracking should continue.
 */
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    // Calculate the difference in angle between current touchpoint and initial
    // Create a transform to animate the wheel rotation
    float angleDifference = self.initialTouchAngle - [self ajd_angleFromTouch:touch];
    self.container.transform = CGAffineTransformRotate(self.initialTransform, -angleDifference);
    return YES;
}

/**
 *  Called when the last touch completely ends.
 *
 *  @param touch The UITouch.
 *  @param event The UIEvent.
 */
- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event {
    [self ajd_snapToSectionWithAnimationDuration:0.2];
}

@end

NS_ASSUME_NONNULL_END
