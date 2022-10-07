//
//  InterfaceController.m
//  ColorWheel WatchKit App Extension
//
//  Created by Aaron on 12/6/15.
//  Copyright © 2015 Aaron DeGrow. All rights reserved.
//

#import "InterfaceController.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController() <WCSessionDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *image;

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    // Start watchkit connectivity session if possible
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

/**
 *  Returns a UIImage of a filled circle with a given color.
 *
 *  @param color The color of the circle.
 *
 *  @return The UIImage of a circle.
 */
- (UIImage *)ajd_createImageForColor:(UIColor *)color {
    // Get the dimensions of the circle
    CGSize size = self.contentFrame.size;
    CGFloat minDim = MIN(size.width, size.height);
    size.height = minDim;
    size.width = minDim;
    
    // Create the circle (and image) using CG
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    rect = CGRectInset(rect, 1, 1);
    CGContextFillEllipseInRect(context, rect);
    CGContextStrokeEllipseInRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


- (IBAction)didTapColor {
    // When the circle/button is pressed, send a message (with no data) to the iPhone app
    [[WCSession defaultSession] sendMessage:@{}
                               replyHandler:^(NSDictionary *reply) {}
                               errorHandler:^(NSError *error) {}
     ];
}


#pragma mark WCSessionDelegate

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    
    // Get the color from the message data
    UIColor *color;
    NSNumber *red = [message objectForKey:@"red"];
    NSNumber *green = [message objectForKey:@"green"];
    NSNumber *blue = [message objectForKey:@"blue"];
    if (red && green && blue) {
        color = [UIColor colorWithRed:red.doubleValue green:green.doubleValue blue:blue.doubleValue alpha:1];
    }
    
    // If a color was received, draw a new circle with that color
    if (color) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [self ajd_createImageForColor:color];
            [self.image setImage:image];
        });
    }
}

@end



