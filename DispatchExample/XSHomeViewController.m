//
//  XSHomeViewController.m
//  DispatchExample
//
//  Created by macpps on 13-4-7.
//  Copyright (c) 2013年 ICV. All rights reserved.
//

#import "XSHomeViewController.h"

@interface XSHomeViewController ()

@end

@implementation XSHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)heavyWork {
    NSLog(@"heavy work.");
}

- (IBAction)clickDispatchAsync:(id)sender {
    static BOOL isRunning;
    dispatch_queue_t queue = dispatch_queue_create("com.paopaosa.DispatchExample.async", NULL);
    if (isRunning == YES) {
        NSLog(@"It's running");
        return;
    }
    isRunning = YES;
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; ++i) {
            sleep(1);
            [self heavyWork];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"queue finished!");
            isRunning = NO;
        });
    });
}

- (IBAction)clickDispatchGroup:(id)sender {
    dispatch_queue_t queue = dispatch_queue_create("com.paopaosa.DispatchExample.group", NULL);
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i < 10; ++i) {
        dispatch_group_async(group, queue, ^{
            sleep(1);
            [self heavyWork];
        });
    }
    dispatch_group_notify(group, queue, ^{
        NSLog(@"group finished!");
    });
}

- (IBAction)clickQueueAfterQueue:(id)sender {
    static BOOL isRunning;
    if (isRunning) {
        NSLog(@"it's running:%@",[[(UIButton *)sender titleLabel] text]);
        return;
    }
    isRunning = YES;
    dispatch_queue_t queue = dispatch_queue_create("com.paopaosa.DispatchExample.queueA", NULL);
    dispatch_group_t groupA = dispatch_group_create();
    dispatch_group_async(groupA, queue, ^{
        NSLog(@"task 1");
        sleep(1);
    });
    dispatch_group_async(groupA, queue, ^{
        NSLog(@"task 2");
        sleep(2);
    });
    dispatch_group_async(groupA, queue, ^{
        NSLog(@"task 3");
        sleep(3);
    });
    
    //貌似会阻断主线程
    dispatch_group_wait(groupA, DISPATCH_TIME_FOREVER);
    NSLog(@"task 1,2,3 finished");
    
    groupA = dispatch_group_create();
    dispatch_group_async(groupA, queue, ^{
        NSLog(@"task 4");
        sleep(1);
    });
    dispatch_group_async(groupA, queue, ^{
        NSLog(@"task 5");
        sleep(1);
    });
    dispatch_group_async(groupA, queue, ^{
        NSLog(@"task 6");
        sleep(1);
    });
    
    dispatch_group_wait(groupA, DISPATCH_TIME_FOREVER);
    printf("finished 4,5,6\n");
    isRunning = NO;
}
@end
