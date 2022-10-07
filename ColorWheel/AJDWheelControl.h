//
//  AJDWheelControl.h
//  ColorWheel
//
//  Created by Aaron on 12/5/15.
//  Copyright © 2015 Aaron DeGrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AJDWheelControl;


/**
 *  Describes the protocol for a generic AJDWheel section.
 */
@protocol AJDWheelSectionProtocol <NSObject>

@required

/**
 *  The section/index number of the section in the wheel control.
 */
@property (assign, nonatomic, readonly) int sectionNumber;

/**
 *  The starting angle of the section.
 */
@property (assign, nonatomic, readonly) float startAngle;

/**
 *  The mid-point angle of the section.
 */
@property (assign, nonatomic, readonly) float midpointAngle;

/**
 *  The end angle of the section.
 */
@property (assign, nonatomic, readonly) float endAngle;

/**
 *  The radius of the section.
 */
@property (assign, nonatomic, readonly) float radius;

/**
 *  Creates a wheel section for a wheel control.
 *
 *  @param frame   The frame that the section will be drawn in.
 *  @param section The section number in the wheel control.
 *  @param start   The start angle.
 *  @param end     The ending angle.
 *  @param radius  The radius.
 *
 *  @return Instance of an object that implements AJDWheelSectionProtocol.
 */
- (instancetype)initWithFrame:(CGRect)frame sectionNumber:(int)section startAngle:(float)start endAngle:(float)end radius:(float)radius;

@end


/**
 *  Describes the protocol of an AJDWheel sections data source.
 */
@protocol AJDWheelDataSource <NSObject>

@required

/**
 *  Returns the sections for a wheel control
 *
 *  @param size The size of the control containing the sections.
 *
 *  @return Array of wheel section objects implementing the AJDWheelSectionProtocol protocol.
 */
- (NSArray<id<AJDWheelSectionProtocol>> *)wheelSectionsForControlSize:(CGSize)size;

@end


/**
 *  Describes the protocol of an AJDWheel delegate.
 */
@protocol AJDWheelDelegate <NSObject>

@optional

/**
 *  Called when the position of the wheel changes.
 *
 *  @param section the new section selected by the wheel.
 */
- (void)wheelDidChangeToSection:(id<AJDWheelSectionProtocol>)section;

@end


/**
 *  Describes a rotary wheel control with custom sections.
 */
@interface AJDWheelControl : UIControl

/**
 *  The delegate of the wheel control that gets notified when it changes.
 */
@property (weak, nonatomic, nullable) id<AJDWheelDelegate> delegate;

/**
 *  The number of sections in the wheel control.
 */
@property (strong, nonatomic, readonly) NSNumber *numberOfSections;

/**
 *  The current section selected.
 */
@property (strong, nonatomic, readonly, nullable) id<AJDWheelSectionProtocol> currentSection;

/**
 *  Creates a wheel control.
 *
 *  @param frame         The for the control.
 *  @param source        The data source for the sections.
 *  @param wheelDelegate The wheel delegate.
 *
 *  @return Instance of AJDWheelControl.
 */
- (instancetype)initWithFrame:(CGRect)frame withDataSource:(id<AJDWheelDataSource>)source delegate:(nullable id<AJDWheelDelegate>)wheelDelegate;

/**
 *  Change the wheel control to select a specific section.
 *
 *  @param section  The section to set the wheel to.
 *  @param duration The duration of the rotation animation.
 */
- (void)setSection:(NSNumber *)section withAnimationDuration:(float)duration;

@end

NS_ASSUME_NONNULL_END
