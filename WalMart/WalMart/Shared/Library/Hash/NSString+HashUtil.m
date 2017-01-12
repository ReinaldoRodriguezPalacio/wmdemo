//
//  HashUtil.m
//  SAMS
//
//  Created by Gerardo Ramirez on 07/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

#import "NSString+HashUtil.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (HashUtil)

- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes,data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString *)sha256
{
    //NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];

    
    CC_SHA256(data.bytes,data.length, digest);
    //CC_SHA256(data.bytes, data.length,  macOut.mutableBytes);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
