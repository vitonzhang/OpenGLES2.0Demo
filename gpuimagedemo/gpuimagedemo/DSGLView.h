//
//  DSGLView.h
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-26.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSGLView : UIView
{
    CAEAGLLayer * mEaglLayer;
    EAGLContext * mContext;
}

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setupLayer;

- (void)setupContext;

- (void)onDisappear;

@end
