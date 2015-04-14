//
//  ViewController.m
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-17.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

// 1. http://indieambitions.com/idevblogaday/learning-opengl-gpuimage/
// 2. https://github.com/fibasile/Instagram-Filters/tree/master/InstaFilters

#import <GPUImage.h>
#import "ViewController.h"
#import "GPUImagePolarPixellatePosterizeFilter.h"


@interface ViewController () {
    GPUImageVideoCamera *videoCamera;
    GPUImagePolarPixellatePosterizeFilter *ppFilter;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Create the video camera.
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480
                                                      cameraPosition:AVCaptureDevicePositionFront];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // Create the filter.
    ppFilter = [[GPUImagePolarPixellatePosterizeFilter alloc] init];
    [videoCamera addTarget:ppFilter];
    
    // Create the target imageview.
    GPUImageView * imageView = [[GPUImageView alloc] init];
    [ppFilter addTarget:imageView];
    self.view = imageView;
    
    // Start capture.
    [videoCamera startCameraCapture];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self.view];
    
    // What does pixelS mean?
    CGSize pixelS = CGSizeMake(location.x / self.view.bounds.size.width * 0.5,
                               location.y / self.view.bounds.size.height * 0.5);
    [ppFilter setPixelSize:pixelS];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self.view];
    CGSize pixelS = CGSizeMake(location.x / self.view.bounds.size.width * 0.5,
                               location.y / self.view.bounds.size.height * 0.5);
    [ppFilter setPixelSize:pixelS];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
