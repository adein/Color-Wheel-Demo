//
//  ViewController.m
//  ColorWheel
//
//  Created by Aaron on 12/5/15.
//  Copyright © 2015 Aaron DeGrow. All rights reserved.
//

#import "ViewController.h"
#import "AJDWheelControl.h"
#import "AJDWheelColorSection.h"
#import "AJDDataConversion.h"
#import <WatchConnectivity/WatchConnectivity.h>

static NSString *const AJDLastSelectionKey = @"LastSelection";

@interface ViewController () <AJDWheelDelegate, AJDWheelDataSource, WCSessionDelegate>

@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic, nullable) AJDWheelControl *wheelControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Start watchkit connectivity session if possible
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    // Create a wheel control
    self.wheelControl = [[AJDWheelControl alloc] initWithFrame:CGRectMake(0, 0, 340, 340) withDataSource:self delegate:self];
    
    // Read and set the last know selected section from user defaults if present
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sectionNumber = [defaults objectForKey:AJDLastSelectionKey];
    if (sectionNumber) {
        [self.wheelControl setSection:sectionNumber withAnimationDuration:0];
    } else {
        [self.wheelControl setSection:@(0) withAnimationDuration:0];
    }
    
    // Add the wheel to the view
    [self.centerView addSubview:self.wheelControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Reads an array of UI colors from a plist.
 *  The array items should be hex strings.
 *
 *  @return The UIColor array.
 */
- (NSArray<UIColor *> *)ajd_colorsFromPlist {
    NSMutableArray<UIColor *> *colors = [[NSMutableArray alloc] init];
    
    // Read the colors from the plist file
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"AJDWheelColors" ofType:@"plist"];
    NSDictionary<NSString *, id> *plistContents = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray<NSString *> *plistColors = [plistContents objectForKey:@"Colors"];
    
    // Iterate through the colors and convert the hex strings to UIColors
    for (NSString *colorString in plistColors) {
        NSNumber *colorHex = [AJDDataConversion numberFromHexString:colorString];
        if (colorHex) {
            CGFloat red = (colorHex.unsignedIntValue & 0x00ff0000) >> 16;
            CGFloat green = (colorHex.unsignedIntValue & 0x0000ff00) >> 8;
            CGFloat blue = (colorHex.unsignedIntValue & 0x000000ff);
            [colors addObject:[UIColor colorWithRed:red green:green blue:blue alpha:1]];
        }
    }
    return [colors copy];
}


#pragma mark AJDWheelDataSource

- (NSArray<id<AJDWheelSectionProtocol>> *)wheelSectionsForControlSize:(CGSize)size {
    NSMutableArray<AJDWheelColorSection *> *sections = [[NSMutableArray alloc] init];
    
    // Get the colors from the plist file
    NSArray<UIColor *> *colors = [self ajd_colorsFromPlist];
    unsigned long numberOfSections = [colors count];
    float radius = 170;
    CGFloat arcWidth = M_PI * 2 / numberOfSections;
    CGFloat startingAngle = - M_PI / 2;
    
    // Iterate through the section colors and create the wheel section objects
    for (int i = 0; i < numberOfSections; i++) {
        UIColor *color = colors[i];
        float startAngle = startingAngle + (i * arcWidth) - (arcWidth / 2);
        float endAngle = startAngle + arcWidth;
        AJDWheelColorSection *section = [[AJDWheelColorSection alloc] initWithFrame:CGRectMake(0, 0, radius, 40) sectionNumber:i startAngle:startAngle endAngle:endAngle radius:radius color:color];
        section.opaque = NO;
        section.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        section.layer.position = CGPointMake(size.width / 2.0, size.height / 2.0);
        [sections addObject:section];
    }
    return [sections copy];
}


#pragma mark AJDWheelDelegate

- (void)wheelDidChangeToSection:(id<AJDWheelSectionProtocol>)section {
    // Verify object class and get the color to send to the watch
    if ([section isKindOfClass:[AJDWheelColorSection class]]) {
        UIColor *color = ((AJDWheelColorSection *)section).color;
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        CGFloat r = components[0];
        CGFloat g = components[1];
        CGFloat b = components[2];
        NSDictionary *messageDict = [[NSDictionary alloc] initWithObjects:@[@(r), @(b), @(g)] forKeys:@[@"red", @"blue", @"green"]];
        [[WCSession defaultSession] sendMessage:messageDict
                                   replyHandler:^(NSDictionary *reply) {}
                                   errorHandler:^(NSError *error) {}
        ];
    }
    
    // Save current section to user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(section.sectionNumber) forKey:AJDLastSelectionKey];
    [defaults synchronize];
}


#pragma mark WCSessionDelegate

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    // When the watch sends a message, assume it's a touch event to change to the next color
    if (self.wheelControl.currentSection) {
        dispatch_async(dispatch_get_main_queue(), ^{
            int nextSection = self.wheelControl.currentSection.sectionNumber + 1;
            nextSection = (nextSection >= self.wheelControl.numberOfSections.intValue) ? 0 : nextSection;
            [self.wheelControl setSection:@(nextSection) withAnimationDuration:0.2];
        });
    }
}

@end
