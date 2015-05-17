//
//  oc.h
//  instabtbu
//
//  Created by 杨培文 on 14/12/15.
//  Copyright (c) 2014年 杨培文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ifaddrs.h>
#import <arpa/inet.h>


@interface oc : NSObject
- (NSString*)getIP;
- (NSString *)gb2312:(NSData*)data;
@end
