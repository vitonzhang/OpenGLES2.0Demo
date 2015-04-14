//
//  DSGLView.m
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-26.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import "DSGLView.h"


@implementation DSGLView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    mEaglLayer = (CAEAGLLayer *)self.layer;
    mEaglLayer.opaque = YES;
}

- (void)setupContext {
    /*
     An EAGLContext manages all of the information iOS needs to draw with OpenGL.
     It’s similar to how you need a Core Graphics context to do anything with Core Graphics.
     */
    
    EAGLRenderingAPI apiLevel = kEAGLRenderingAPIOpenGLES2;
    mContext = [[EAGLContext alloc] initWithAPI:apiLevel];
    
    if (!mContext) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context.");
    }
    
    if (![EAGLContext setCurrentContext:mContext]) {
        NSLog(@"Failed to set current OpenGLES context.");
    }
}

- (void)onDisappear {
    
}
@end
