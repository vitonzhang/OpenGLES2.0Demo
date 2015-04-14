//
//  GPUImagePolarPixellatePosterizeFilter.m
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-17.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import "GPUImagePolarPixellatePosterizeFilter.h"

NSString * const kGPUImagePolarPixellatePosterizeFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform highp vec2 center;
 uniform highp vec2 pixelSize;
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     highp vec2 normCoord = 2.0 * textureCoordinate - 1.0;
     highp vec2 normCenter = 2.0 * center - 1.0;
     
     normCoord -= normCenter;
     
     // Convert from a cartesian to a polar coordinate system.
     highp float r = length(normCoord);                 // to polar coords
     highp float phi = atan(normCoord.y, normCoord.x);  // to polar coords
     
     r = r - mod(r, pixelSize.x) + 0.03;
     phi = phi - mod(phi, pixelSize.y);
     
     // Convert the value back into a cartesian coordinate system.
     normCoord.x = r * cos(phi);
     normCoord.y = r * sin(phi);
     
     normCoord += normCenter;
     
     // Return it to the (0.0, 0.0) ~ (1.0, 1.0)
     mediump vec2 textureCoordinateToUse = normCoord / 2.0 + 0.5;
     mediump vec4 color = texture2D(inputImageTexture, textureCoordinateToUse );
     
     // This will reduce the color range for the red, green, blue(and alpha, but
     // alpha is always 1.0 in our case so ...) from 256 steps for each component
     // (256 cubed or 16.8 M colors) to 10 step (1000 colors)
     color = color - mod(color, 0.1);
     gl_FragColor = color;
     
 }
);

@implementation GPUImagePolarPixellatePosterizeFilter

@synthesize center = _center;

@synthesize pixelSize = _pixelSize;

#pragma mark - Initialization and teardown
- (id)init {
    
    if (! (self = [super initWithFragmentShaderFromString:kGPUImagePolarPixellatePosterizeFragmentShaderString])) {
        return nil;
    }
    
    pixelSizeUniform = [filterProgram uniformIndex:@"pixelSize"];
    centerUniform = [filterProgram uniformIndex:@"center"];
    
    self.pixelSize = CGSizeMake(0.05, 0.05);
    self.center = CGPointMake(0.5, 0.5);
    
    return self;
}

- (void)setPixelSize:(CGSize)pixelSize {
    _pixelSize = pixelSize;
    
    // GPUImageOpenGLESContext --> GPUImageContext
    [GPUImageContext useImageProcessingContext];
    [filterProgram use];
    
    GLfloat pixelS[2];
    pixelS[0] = _pixelSize.width;
    pixelS[1] = _pixelSize.height;
    glUniform2fv(pixelSizeUniform, 1, pixelS);
}

- (void)setCenter:(CGPoint)center {
    
    _center = center;
    
    // These two calls make sure that we have the right shader program loaded when
    // we pass in the data.
    [GPUImageContext useImageProcessingContext];
    [filterProgram use];
    
    GLfloat centerPosition[2];
    centerPosition[0] = _center.x;
    centerPosition[1] = _center.y;
    
    // glUniform2fv passes data of a certain type into our shader program.
    glUniform2fv(centerUniform, 1, centerPosition);
}

@end
