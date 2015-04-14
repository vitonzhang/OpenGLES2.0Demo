//
//  DSFilterViewController.m
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-23.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import "DSFilterViewController.h"
#import "UIButton+CheckFlag.h"
#import "GPUImagePolarPixellatePosterizeFilter.h"
#import <GPUImage.h>

@interface DSFilterViewController ()
{
    NSString * mFilterName;
    UIImageView * mImageView;
}

@end

@implementation DSFilterViewController


- (instancetype)initWithFilterName:(NSString *)filterName {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        mFilterName = filterName;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Create the image view.
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat margin = 10;
    CGFloat width = screenSize.width - margin * 2;
    CGFloat height = width;
    CGRect imageViewRc = CGRectMake(margin, margin + 64, width, height);
    mImageView = [[UIImageView alloc] initWithFrame:imageViewRc];
    mImageView.image = [UIImage imageNamed:self.imageName];
    [self.view addSubview:mImageView];
    
    // Create the button.
    UIButton * handleTrigger = [UIButton buttonWithType:UIButtonTypeCustom];
    handleTrigger.isChecked = NO;
    CGFloat yOffset = mImageView.frame.origin.y + mImageView.frame.size.height + margin;
    CGFloat buttonHeight = 60;
    CGRect buttonRc = CGRectMake(margin, yOffset, width, buttonHeight);
    [handleTrigger setFrame:buttonRc];
    [handleTrigger setTitle:@"Trigger" forState:UIControlStateNormal];
    [handleTrigger setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [handleTrigger addTarget:self action:@selector(onTrigger:) forControlEvents:UIControlEventTouchUpInside];
    [handleTrigger setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:handleTrigger];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTrigger:(id)sender {
    
    UIButton * button = (UIButton *)sender;
    [button setEnabled:NO];

    // Load the image from imageName.
    UIImage * originalImage = [UIImage imageNamed:self.imageName];
    
    if (!button.isChecked) {

        GPUImagePicture * stillImageSource = [[GPUImagePicture alloc] initWithImage:originalImage];
        // GPUImageSepiaFilter * stillImageFilter = [[GPUImageSepiaFilter alloc] init];
        GPUImagePolarPixellatePosterizeFilter * stillImageFilter = [[GPUImagePolarPixellatePosterizeFilter alloc] init];
        [stillImageSource addTarget:stillImageFilter];
        [stillImageFilter useNextFrameForImageCapture];
        [stillImageSource processImage];
        
        UIImage * processedImage = [stillImageFilter imageFromCurrentFramebuffer];
        mImageView.image = processedImage;
    } else {
        mImageView.image = originalImage;
    }

    [button setIsChecked:!button.isChecked];
    [button setEnabled:YES];
}

@end
