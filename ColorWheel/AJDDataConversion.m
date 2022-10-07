//
//  AJDDataConversion.m
//  ColorWheel
//
//  Created by Aaron on 12/6/15.
//  Copyright © 2015 Aaron DeGrow. All rights reserved.
//

#import "AJDDataConversion.h"

NS_ASSUME_NONNULL_BEGIN

@implementation AJDDataConversion

+ (NSString *)ajd_padStringWithZerosToNSUIntegerSize:(NSString *)string {
    if ([string length] > 0 && [string length] <= 8) {
        NSUInteger difference = 8 - [string length];
        NSString *pad = [@"" stringByPaddingToLength:difference withString:@"0" startingAtIndex:0];
        return [pad stringByAppendingString:string];
    }
    return string;
}

+ (NSData *)dataFromHexString:(NSString *)string {
    const char *chars = [string UTF8String];
    int i = 0;
    int len = (int)string.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:(len / 2)];
    char byteChars[3] = {'\0', '\0', '\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}

+ (NSNumber *)numberFromHexString:(NSString *)string {
    NSString *stringNoPrefix = [string stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSData *data = [AJDDataConversion dataFromHexString:[AJDDataConversion ajd_padStringWithZerosToNSUIntegerSize:stringNoPrefix]];
    if ([data length] > 4) {
        NSLog(@"Warning: length of string to convert to NSNumber is greater than 4!");
    }
    NSUInteger decodedInteger;
    [data getBytes:&decodedInteger length:sizeof(decodedInteger)];
    decodedInteger = htonl(decodedInteger);
    return [NSNumber numberWithUnsignedInteger:decodedInteger];
}

@end

NS_ASSUME_NONNULL_END
