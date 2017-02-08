//
//  Helper.m
//  TweetMe
//
//  Created by Mac on 2/7/17.
//  Copyright © 2017 RFTP Technologies Ltd. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm a"];
    return [dateFormat stringFromDate:date];
}

@end
