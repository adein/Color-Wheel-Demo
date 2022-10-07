//
//  AJDDataConversion.h
//  ColorWheel
//
//  Created by Aaron on 12/6/15.
//  Copyright © 2015 Aaron DeGrow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Utility class that provides class methods for converting data.
 */
@interface AJDDataConversion : NSObject

/**
 *  Returns NSData equivalent to an NSString of hexadecimal characters.
 *
 *  @param string NSString of hex bytes.
 *
 *  @return NSData of the bytes.
 */
+ (NSData *)dataFromHexString:(NSString *)string;

/**
 *  Returns an NSNumber from a 4 byte string of hexadecimal characters.
 *
 *  @param string the string to convert.
 *
 *  @return the NSNumber from the string.
 */
+ (NSNumber *)numberFromHexString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
