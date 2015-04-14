//
//  FilterListTableViewController.m
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-23.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import "FilterListTableViewController.h"
#import "DSFilterViewController.h"
#import "DSGLDemoViewController.h"

#import <objc/objc-runtime.h>

static NSString * reuseIdentifier = @"reuseIdentifier";

@interface FilterListTableViewController ()
{
    NSMutableDictionary *mFilterMapping;
    NSMutableDictionary *mGLESDemoMapping;
}
@end

@implementation FilterListTableViewController


- (instancetype)init
{
    self = [super init];
    return self;
}

/**
 * "[UIStoryboard instantiateWithOwner:options:]" call this initializer.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    /*
    mFilterMapping = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"DSSepiaFilter",
                      @"SepiaFilter", nil];
    */
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (nil == self) {
        return nil;
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (nil == self) {
        return nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mFilterMapping = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"DSFilterViewController",
                      @"DSSepiaFilter", nil];
    mGLESDemoMapping = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"DSGLDemoViewController",
                        @"DSGLDemoView",
                        @"DSGLDemoViewController",
                        @"DSGLProjectionDemoView",
                        @"DSGLDemoViewController",
                        @"DSGLModelTransformView",
                        @"DSGLDemoViewController",
                        @"DSGL3DView",
                        @"DSGLDemoViewController",
                        @"DSGL3DCubeView",
                        @"DSGLDemoViewController",
                        @"DSGLTextureView",
                        @"DSGLDemoViewController",
                        @"DSGLFancyTextureView", nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // - (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
    UIBarButtonItem * demoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Demo"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(onGLESDemo)];
    self.navigationItem.rightBarButtonItem = demoButtonItem;
    
    UINib * filterCellNib = [UINib nibWithNibName:@"FilterCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:filterCellNib forCellReuseIdentifier:reuseIdentifier];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onGLESDemo {
    
    NSLog(@"Noop!");
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id viewController = nil;
    
    if (indexPath.section == 0) {
        NSArray * filterList = [mFilterMapping allValues];
        NSString * className = [filterList objectAtIndex:indexPath.row];
        
        Class filterClass = NSClassFromString(className);
        if (nil == filterClass) {
            NSLog(@"Class %@ does not exist!", className);
            return ;
        }
        id filter = [[filterClass alloc] init];
        [(DSFilterViewController *)filter setImageName:@"house.jpeg"];
        viewController = filter;
        
    } else if (indexPath.section == 1) {
        NSArray * demoList = [mGLESDemoMapping allValues];
        NSString * className = [demoList objectAtIndex:indexPath.row];
        Class demoClass = NSClassFromString(className);
        if (nil == demoClass) {
            NSLog(@"Class %@ does not exist!", className);
            return ;
        }
        id demo = [[demoClass alloc] init];
        NSString *viewClassName = [[mGLESDemoMapping allKeys] objectAtIndex:indexPath.row];
        [(DSGLDemoViewController *)demo setViewClassName:viewClassName];
        viewController = demo;
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        NSLog(@"viewController is nil!");
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return [[mFilterMapping allKeys] count];
    } else if (section == 1) {
        return [[mGLESDemoMapping allKeys] count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                                            forIndexPath:indexPath];
    
    // Configure the cell...
    NSString * titleName = @"Unknown";
    if (indexPath.section == 0) {
        titleName = [[mFilterMapping allKeys] objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        titleName = [[mGLESDemoMapping allKeys] objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = titleName;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
