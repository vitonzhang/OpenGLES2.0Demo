//
//  UIButton+CheckFlag.m
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-23.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import "UIButton+CheckFlag.h"
#import <objc/objc-runtime.h>

static void * checkedFlagId = &checkedFlagId;

@implementation UIButton (CheckFlag)

- (void)setIsChecked:(BOOL)isChecked
{
    objc_setAssociatedObject(self, checkedFlagId, [NSNumber numberWithBool:isChecked], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isChecked
{
    id value = objc_getAssociatedObject(self, checkedFlagId);
    NSNumber * boolNunber = (NSNumber *)value;
    return [boolNunber boolValue];
}

@end
