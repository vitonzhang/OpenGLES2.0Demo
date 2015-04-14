//
//  DSGLDemoViewController.m
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-23.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import "DSGLDemoViewController.h"
#import "DSGLView.h"
#import "AdaptationConstiOS7.h"

@interface DSGLDemoViewController ()

@property (nonatomic) DSGLView * glView;

@end

@implementation DSGLDemoViewController
{
    DSGLView * mGLView;
}

@synthesize glView = mGLView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.navigationItem.title = @"OpenGL ES 2.x Demo";
    
    CGRect rootViewBounds = self.view.bounds;
    rootViewBounds.size.height -= [AdaptationConstiOS7 viewOriginOffset];
    rootViewBounds.origin.y += [AdaptationConstiOS7 viewOriginOffset];
    
    id viewClass = NSClassFromString(self.viewClassName);
    if (nil == viewClass) {
        NSLog(@"viewClass %@ is not exist!", self.viewClassName);
    }
    
    NSLog(@"rootViewBounds: %@", NSStringFromCGRect(rootViewBounds));
    self.glView = [[viewClass alloc] initWithFrame:rootViewBounds];
    [self.view addSubview:self.glView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.glView onDisappear];
}
@end
