//
//  ConfirmImageViewController.m
//  CustomCamera
//
//  Created by Patrícia Gabriele Neri on 16/09/16.
//
//

#import "ConfirmImageViewController.h"

@interface ConfirmImageViewController ()

@end

@implementation ConfirmImageViewController {
    void(^_callback)(UIImage*);
    UIButton *_backButton;
    UIButton *_confirmButton;
    UIImage *_selfie;
    UIView *_bottomPanel;
    UIView *_fullPanel;
}

static const CGFloat kCaptureButtonWidthPhone = 64;
static const CGFloat kCaptureButtonHeightPhone = 64;
static const CGFloat kCaptureButtonVerticalInsetPhone = 10;

- (id)initWithCallback:(void(^)(UIImage*))callback {
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
    self.view.backgroundColor = [UIColor blackColor];
}

- (CALayer*)createLayerCircle {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    int radius = bounds.size.width;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height) cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, (bounds.size.height-bounds.size.width)/2, radius, radius) cornerRadius:radius];
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

    _bottomPanel = [[UIView alloc] initWithFrame:CGRectZero];
    [_bottomPanel setBackgroundColor: [UIColor blackColor]];
    [overlay addSubview:_bottomPanel];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setTitle:@"TIRAR OUTRA FOTO" forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor blackColor]];
    [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:18]];
    [_backButton addTarget:self action:@selector(dismissImagePreview) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:_backButton];

    
    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmButton setTitle:@"OK" forState:UIControlStateNormal];
    [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmButton setBackgroundColor:[UIColor blackColor]];
        [[_confirmButton titleLabel] setFont:[UIFont systemFontOfSize:18]];
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
    
    _backButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthPhone / 2),
                                      bounds.size.height - kCaptureButtonHeightPhone - kCaptureButtonVerticalInsetPhone,
                                      kCaptureButtonWidthPhone,
                                      kCaptureButtonHeightPhone);
    
    _confirmButton.frame = CGRectMake((CGRectGetMinX(_confirmButton.frame) - kCaptureButtonWidthPhone) / 2,
                                   CGRectGetMinY(_confirmButton.frame) + ((kCaptureButtonHeightPhone - kCaptureButtonHeightPhone) / 2),
                                   kCaptureButtonWidthPhone,
                                   kCaptureButtonHeightPhone);
    
    [self layoutForPhoneWithShortScreen];

}

- (void)confirmImage {
    
     _callback(@"");
}

 - (void)layoutForPhoneWithShortScreen {
     CGRect bounds = [[UIScreen mainScreen] bounds];
     
     CGFloat bottomsize = kCaptureButtonHeightPhone + (kCaptureButtonVerticalInsetPhone * 2);
     
     _bottomPanel.frame = CGRectMake(0, bounds.size.height/2 + bottomsize/2,
                                     bounds.size.width,
                                     bounds.size.height/2 - bottomsize);
 }

- (void)layoutForPhoneWithTallScreen {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    CGFloat bottomsize = kCaptureButtonHeightPhone + (kCaptureButtonVerticalInsetPhone * 2);
    
    _bottomPanel.frame = CGRectMake(0, bounds.size.height/2 + bottomsize/2,
                                    bounds.size.width,
                                    bounds.size.height/2 - bottomsize);
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
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return orientation == UIDeviceOrientationPortrait;
}



@end
