//
// Copyright (c) 2016 - Present, RFTP Technologies Ltd.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import "TweetModel.h"

@implementation TweetModel

@dynamic owner;
@dynamic text;

+ (NSString *)rooftopClassName {
    return @"Tweet";
}

@end
