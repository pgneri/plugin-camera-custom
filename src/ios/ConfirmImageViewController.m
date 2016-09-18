//
//  ConfirmImageViewController.m
//  CustomCamera
//
//  Created by Patrícia Gabriele Neri on 16/09/16.
//
//

#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>
#import "ConfirmImageViewController.h"

@implementation ConfirmImageViewController {
    void(^_callback)(BOOL*);
    UIButton *_backButton;
    UIButton *_confirmButton;
    UIImage *_selfie;
    UIView *_bottomPanel;
    UIView *_fullPanel;
}

static const CGFloat kCaptureButtonWidthPhone = 64;
static const CGFloat kCaptureButtonHeightPhone = 64;
static const CGFloat kCaptureButtonVerticalInsetPhone = 10;

- (id)initWithCallback:(void(^)(BOOL*))callback {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _callback = callback;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:[self createOverlay]];
}

- (CALayer*)createLayerCircle {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    int radius = bounds.size.width;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height) cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, (bounds.size.height-bounds.size.width)/2-kCaptureButtonVerticalInsetPhone*2, radius, radius) cornerRadius:radius];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 1;

    return fillLayer;
}

- (UIView*)createOverlay {
    UIView *overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setTitle:@"TIRAR OUTRA FOTO" forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor whiteColor]];
    [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:16]];
    [_backButton addTarget:self action:@selector(dismissImagePreview) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:_backButton];

    
    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmButton setTitle:@"OK" forState:UIControlStateNormal];
    [_confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_confirmButton setBackgroundColor:[UIColor whiteColor]];
        [[_confirmButton titleLabel] setFont:[UIFont systemFontOfSize:16]];
    [_confirmButton addTarget:self action:@selector(confirmImage) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:_confirmButton];

    [self.view.layer addSublayer:[self createLayerCircle]];
    
    return overlay;
}

- (void)viewWillLayoutSubviews {
    [self layoutForPhone];
}

- (void)layoutForPhone {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _backButton.frame = CGRectMake(kCaptureButtonVerticalInsetPhone,
                                      bounds.size.height - kCaptureButtonHeightPhone,
                                      bounds.size.width-kCaptureButtonVerticalInsetPhone*2,
                                      kCaptureButtonHeightPhone - kCaptureButtonVerticalInsetPhone*2);
    _backButton.layer.cornerRadius = 5;
    _backButton.clipsToBounds = YES;

    
    _confirmButton.frame = CGRectMake(kCaptureButtonVerticalInsetPhone,
                                      bounds.size.height - kCaptureButtonHeightPhone - kCaptureButtonHeightPhone + kCaptureButtonVerticalInsetPhone,
                                      bounds.size.width-kCaptureButtonVerticalInsetPhone*2,
                                      kCaptureButtonHeightPhone - kCaptureButtonVerticalInsetPhone*2);
    _confirmButton.layer.cornerRadius = 5;
    _confirmButton.clipsToBounds = YES;
    
    
    [self layoutForPhoneWithShortScreen];

}

- (void)confirmImage {

    _callback(TRUE);
    
}

 - (void)layoutForPhoneWithShortScreen {
     CGRect bounds = [[UIScreen mainScreen] bounds];
     
     CGFloat bottomsize = kCaptureButtonHeightPhone + (kCaptureButtonVerticalInsetPhone * 2);
     
     _bottomPanel.frame = CGRectMake(0, bounds.size.height/4 + bottomsize/2,
                                     bounds.size.width,
                                     bounds.size.height/4- bottomsize);
 }

- (void)layoutForPhoneWithTallScreen {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    CGFloat bottomsize = kCaptureButtonHeightPhone + (kCaptureButtonVerticalInsetPhone * 2);
    
    _bottomPanel.frame = CGRectMake(0, bounds.size.height/4 + bottomsize/2,
                                    bounds.size.width,
                                    bounds.size.height/4- bottomsize);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)dismissImagePreview {
    _callback(NO);
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return orientation == UIDeviceOrientationPortrait;
}



@end
