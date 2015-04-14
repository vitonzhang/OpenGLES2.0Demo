//
//  GPUImagePolarPixellatePosterizeFilter.h
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-17.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import <GPUImage.h>

@interface GPUImagePolarPixellatePosterizeFilter : GPUImageFilter {
    GLint centerUniform, pixelSizeUniform;
}

// The center about which to apply the distortion, with a default of (0.5, 0.5)
@property (nonatomic) CGPoint center;

// The amount of distortion to apply, from (-2.0, -2.0) to (2.0, 2.0), with a default of (0.05, 0.05)
@property (nonatomic) CGSize pixelSize;

@end
