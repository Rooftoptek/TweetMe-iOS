//
// Copyright (c) 2016 - Present, RFTP Technologies Ltd.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import <Foundation/Foundation.h>
#import <Rooftop/Rooftop.h>

@interface TweetModel : RTObject <RTSubclassing>

@property (strong, nonatomic) RTUser *owner;
@property (strong, nonatomic) NSString *text;

@end
