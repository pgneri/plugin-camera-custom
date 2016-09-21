//
//  PortrateNavigation.m
//  CustomCamera
//
//  Created by Patrícia Gabriele Neri on 21/09/16.
//
//

#import "PortrateNavigation.h"

@interface PortrateNavigation ()

@end

@implementation PortrateNavigation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
