//
//  CustomCameraViewController.m
//  CustomCamera
//
//  Created by Patrícia Gabriele Neri on 13/09/16.
//
//

#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>
#import "GlobalVars.h"
#import "CustomCameraViewController.h"
#import "ConfirmImageViewController.h"

@implementation CustomCameraViewController {
    void(^_callback)(UIImage*);
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_rearCamera;
    AVCaptureStillImageOutput *_stillImageOutput;
    UIView *_buttonPanel;
    UIButton *_captureButton;
    UIButton *_backButton;
    UIButton *_changeCamera;
    UIActivityIndicatorView *_activityIndicator;
    UIView *_topPanel;
    UIView *_bottomPanel;
    UIView *_fullPanel;
    UILabel *_topTitle;

}


static const CGFloat kChangeCameraButtonWidthPhone = 64;
static const CGFloat kChangeCameraButtonHeightPhone = 64;
static const CGFloat kCaptureButtonWidthPhone = 64;
static const CGFloat kCaptureButtonHeightPhone = 64;
static const CGFloat kBackButtonWidthPhone = 100;
static const CGFloat kBackButtonHeightPhone = 40;
static const CGFloat kCaptureButtonVerticalInsetPhone = 10;

static const CGFloat kChangeCameraButtonWidthTablet = 75;
static const CGFloat kChangeCameraButtonHeightTablet = 75;
static const CGFloat kCaptureButtonWidthTablet = 75;
static const CGFloat kCaptureButtonHeightTablet = 75;
static const CGFloat kBackButtonWidthTablet = 150;
static const CGFloat kBackButtonHeightTablet = 50;
static const CGFloat kCaptureButtonVerticalInsetTablet = 20;

//static const CGFloat kAspectRatio = 125.0f / 86;


- (id)initWithCallback:(void(^)(UIImage*))callback {
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        _callback = callback;
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    return self;
}

- (void)dealloc {
    [_captureSession stopRunning];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];

    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
//    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.view.bounds;
    [[self.view layer] addSublayer:previewLayer];
    [self.view addSubview:[self createOverlay]];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = self.view.center;
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
}

- (UIView*)createOverlayFullScreen {
    UIView *overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _fullPanel = [[UIView alloc] initWithFrame:CGRectZero];
    [_fullPanel setBackgroundColor: [UIColor clearColor]];
    [overlay addSubview:_fullPanel];

    return overlay;
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
    fillLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    fillLayer.opacity = 0.9;

    return fillLayer;
}

- (UIView*)createOverlayTop {
    UIView *overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _topPanel = [[UIView alloc] initWithFrame:CGRectZero];
    [_topPanel setBackgroundColor: [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [overlay addSubview:_topPanel];

    return overlay;

}

- (UIView*)createOverlayBottom {
    UIView *overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _bottomPanel = [[UIView alloc] initWithFrame:CGRectZero];
    [_bottomPanel setBackgroundColor: [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [overlay addSubview:_bottomPanel];

    return overlay;
}

- (UIView*)createOverlay {
    GlobalVars *globals = [GlobalVars sharedInstance]; // Options plugin
    UIView *overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _topTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    [_topTitle setBackgroundColor: [UIColor clearColor]];
    [_topTitle setText:[NSString stringWithFormat:@"%@", globals.title]];
    [_topTitle setTextColor:[UIColor whiteColor]];
    [_topTitle setFont:[UIFont systemFontOfSize:16]];
    [_topTitle setTextAlignment:NSTextAlignmentCenter];
    [overlay addSubview:_topTitle];
    
    _buttonPanel = [[UIView alloc] initWithFrame:CGRectZero];
    [_buttonPanel setBackgroundColor: [UIColor blackColor]];
    [overlay addSubview:_buttonPanel];
    
    if([globals.toggleCamera isEqual:@"YES"]){
        _changeCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeCamera setImage:[UIImage imageNamed:@"www/img/icons/camera_toggle.png"] forState:UIControlStateNormal];
        [_changeCamera setImage:[UIImage imageNamed:@"www/img/icons/camera_toggle-touched.png"] forState:UIControlStateSelected];
        [_changeCamera setImage:[UIImage imageNamed:@"www/img/icons/camera_toggle-touched.png"] forState:UIControlStateHighlighted];
        [_changeCamera addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
        [overlay addSubview:_changeCamera];
    }
    
    _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_captureButton setImage:[UIImage imageNamed:@"www/img/icons/input-foto.png"] forState:UIControlStateNormal];
    [_captureButton setImage:[UIImage imageNamed:@"www/img/icons/input-foto.png"] forState:UIControlStateSelected];
    [_captureButton setImage:[UIImage imageNamed:@"www/img/icons/input-foto.png"] forState:UIControlStateHighlighted];
    [_captureButton addTarget:self action:@selector(takePictureWaitingForCameraToFocus) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:_captureButton];

    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setTitle:[NSString stringWithFormat:@"%@", globals.buttonCancel] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:18]];
    [_backButton addTarget:self action:@selector(dismissCameraPreview) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:_backButton];

    [self.view.layer addSublayer:[self createLayerCircle]];

    return overlay;
}

- (void)viewWillLayoutSubviews {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self layoutForTablet];
    } else {
        [self layoutForPhone];
    }
}

- (void)layoutForPhone {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _topTitle.frame = CGRectMake(kCaptureButtonVerticalInsetPhone,0,
                                 bounds.size.width-kCaptureButtonVerticalInsetPhone*2,
                                 kChangeCameraButtonHeightPhone);
    
    _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthPhone / 2),
                                      bounds.size.height - kCaptureButtonHeightPhone - kCaptureButtonVerticalInsetPhone,
                                      kCaptureButtonWidthPhone,
                                      kCaptureButtonHeightPhone);

    _changeCamera.frame = CGRectMake(bounds.size.width-kChangeCameraButtonWidthPhone-kCaptureButtonVerticalInsetPhone*2, CGRectGetMinY(_captureButton.frame) + ((kCaptureButtonHeightPhone - kChangeCameraButtonHeightPhone) / 2),
                                      kChangeCameraButtonWidthPhone,
                                      kChangeCameraButtonHeightPhone);

    _backButton.frame = CGRectMake((CGRectGetMinX(_captureButton.frame) - kBackButtonWidthPhone) / 2,
                                   CGRectGetMinY(_captureButton.frame) + ((kCaptureButtonHeightPhone - kBackButtonHeightPhone) / 2),
                                   kBackButtonWidthPhone,
                                   kBackButtonHeightPhone);

    _buttonPanel.frame = CGRectMake(0,
                                    CGRectGetMinY(_captureButton.frame) - kCaptureButtonVerticalInsetPhone,
                                    bounds.size.width,
                                    kCaptureButtonHeightPhone + (kCaptureButtonVerticalInsetPhone * 2));

    CGFloat screenAspectRatio = bounds.size.height / bounds.size.width;
    if (screenAspectRatio <= 1.5f) {
        [self layoutForPhoneWithShortScreen];
    } else {
        [self layoutForPhoneWithTallScreen];
    }
}

 - (void)layoutForPhoneWithShortScreen {
     CGRect bounds = [[UIScreen mainScreen] bounds];

     CGFloat bottomsize = kCaptureButtonHeightPhone + (kCaptureButtonVerticalInsetPhone * 2);

     _fullPanel.frame = CGRectMake(0, 0, bounds.size.width,
                                  bounds.size.height);

     _topPanel.frame = CGRectMake(0, 0, bounds.size.width,
                                  bounds.size.height/2 - bottomsize/2);

     _bottomPanel.frame = CGRectMake(0, bounds.size.height/2 + bottomsize/2,
                                     bounds.size.width,
                                     bounds.size.height/2 - bottomsize);
 }

- (void)layoutForPhoneWithTallScreen {
    CGRect bounds = [[UIScreen mainScreen] bounds];

    CGFloat bottomsize = kCaptureButtonHeightPhone + (kCaptureButtonVerticalInsetPhone * 2);

    _fullPanel.frame = CGRectMake(0, 0, bounds.size.width,
                                  bounds.size.height);

    _topPanel.frame = CGRectMake(0, 0, bounds.size.width,
                                 bounds.size.height/2 - bottomsize/2);

    _bottomPanel.frame = CGRectMake(0, bounds.size.height/2 + bottomsize/2,
                                    bounds.size.width,
                                    bounds.size.height/2 - bottomsize);
}

- (void)layoutForTablet {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _topTitle.frame = CGRectMake(kCaptureButtonVerticalInsetPhone,0,
                                 bounds.size.width-kCaptureButtonVerticalInsetPhone*2,
                                 kChangeCameraButtonHeightPhone);

    _changeCamera.frame = CGRectMake(bounds.size.width-kChangeCameraButtonWidthTablet,0,
                                     kChangeCameraButtonWidthTablet,
                                     kChangeCameraButtonHeightTablet);

    _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthTablet / 2),
                                      bounds.size.height - kCaptureButtonHeightTablet - kCaptureButtonVerticalInsetTablet,
                                      kCaptureButtonWidthTablet,
                                      kCaptureButtonHeightTablet);

    _backButton.frame = CGRectMake((CGRectGetMinX(_captureButton.frame) - kBackButtonWidthTablet) / 2,
                                   CGRectGetMinY(_captureButton.frame) + ((kCaptureButtonHeightTablet - kBackButtonHeightTablet) / 2),
                                   kBackButtonWidthTablet,
                                   kBackButtonHeightTablet);

    _buttonPanel.frame = CGRectMake(0,
                                    CGRectGetMinY(_captureButton.frame) - kCaptureButtonVerticalInsetTablet,
                                    bounds.size.width,
                                    kCaptureButtonHeightTablet + (kCaptureButtonVerticalInsetTablet * 2));

    [self layoutForPhoneWithTallScreen];
}

- (void)viewDidLoad {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
            if ([device hasMediaType:AVMediaTypeVideo] && [device position] == AVCaptureDevicePositionFront) {
                _rearCamera = device;
            }
        }
        AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:_rearCamera error:nil];

        if(cameraInput == nil){
            NSLog(@"Bricked Camera");
            for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
                if ([device hasMediaType:AVMediaTypeVideo] && [device position] == AVCaptureDevicePositionBack) {
                    _rearCamera = device;
                }
            }
            cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:_rearCamera error:nil];
        }

        [_captureSession addInput:cameraInput];
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [_captureSession addOutput:_stillImageOutput];
        [_captureSession startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityIndicator stopAnimating];
        });
    });
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

- (void)changeCamera {
    NSLog(@"Camera toggled");
    //Change camera source
    if(_captureSession)
    {
        //Indicate that some changes will be made to the session
        [_captureSession beginConfiguration];

        //Remove existing input
        AVCaptureInput* currentCameraInput = [_captureSession.inputs objectAtIndex:0];
        [_captureSession removeInput:currentCameraInput];

        //Get new input
//        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            _rearCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else
        {
            _rearCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }

        //Add input to session
        NSError *err = nil;
        AVCaptureDeviceInput *newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:_rearCamera error:nil];
        if(!newVideoInput || err)
        {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);

            if(((AVCaptureDeviceInput*)newVideoInput).device.position == AVCaptureDevicePositionBack)
            {
                _rearCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            }
            else
            {
                _rearCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }
            newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:_rearCamera error:nil];
        }

        [_captureSession addInput:newVideoInput];

        //Commit all the configuration changes at once
        [_captureSession commitConfiguration];
    }
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return orientation == UIDeviceOrientationPortrait;
}

- (void)dismissCameraPreview {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)takePictureWaitingForCameraToFocus {
    _captureButton.userInteractionEnabled = NO;
    _captureButton.selected = YES;
    if (_rearCamera.focusPointOfInterestSupported && [_rearCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [_rearCamera addObserver:self forKeyPath:@"adjustingFocus" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
        [self autoFocus];
        [self autoExpose];
    } else {
        [self takePicture];
    }
}

- (void)autoFocus {

    [_rearCamera lockForConfiguration:nil];
    _rearCamera.focusMode = AVCaptureFocusModeAutoFocus;
    _rearCamera.focusPointOfInterest = CGPointMake(0.5, 0.5);
    [_rearCamera unlockForConfiguration];
}

- (void)autoExpose {
    [_rearCamera lockForConfiguration:nil];
    if (_rearCamera.exposurePointOfInterestSupported && [_rearCamera isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        _rearCamera.exposureMode = AVCaptureExposureModeAutoExpose;
        _rearCamera.exposurePointOfInterest = CGPointMake(0.5, 0.5);
    }
    [_rearCamera unlockForConfiguration];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    BOOL wasAdjustingFocus = [[change valueForKey:NSKeyValueChangeOldKey] boolValue];
    BOOL isNowFocused = ![[change valueForKey:NSKeyValueChangeNewKey] boolValue];
    if (wasAdjustingFocus && isNowFocused) {
        [_rearCamera removeObserver:self forKeyPath:@"adjustingFocus"];
        [self takePicture];
    }
}

- (void)takePicture {
    AVCaptureConnection *videoConnection = [self videoConnectionToOutput:_stillImageOutput];
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {

        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];

        UIImage *imagem = [UIImage imageWithData:imageData];

        CGRect rect = CGRectMake(0, (imagem.size.height-imagem.size.width) / 2, imagem.size.width, imagem.size.width);

        CGAffineTransform rectTransform = [self orientationTransformedRectOfImage:imagem];
        rect = CGRectApplyAffineTransform(rect, rectTransform);

        CGImageRef imageRef = CGImageCreateWithImageInRect([imagem CGImage], rect);

        UIImage *imageCrop = [UIImage imageWithCGImage:imageRef  scale:imagem.scale orientation:imagem.imageOrientation];

        CGImageRelease(imageRef);
        
        ConfirmImageViewController *confirmImage  = [ConfirmImageViewController alloc];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:confirmImage];
        
        UIImage *image = [UIImage imageWithCGImage:imageRef  scale:imagem.scale orientation:imagem.imageOrientation];
        confirmImage.imageView.image = image;
        navController.navigationBarHidden = true;

        (void) [confirmImage initWithCallback:^(BOOL confirmed) {
            if(confirmed) {
                _callback(imageCrop);
            } else {
                _captureButton.userInteractionEnabled = YES;
                _captureButton.selected = NO;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [self presentViewController:navController animated:YES completion:nil];
        
    }];
}


- (CGAffineTransform)orientationTransformedRectOfImage:(UIImage *)img
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation) {
        case UIImageOrientationLeft:
        rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -img.size.height);
        break;
        case UIImageOrientationRight:
        rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -img.size.width, 0);
        break;
        case UIImageOrientationDown:
        rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -img.size.width, -img.size.height);
        break;
        default:
        rectTransform = CGAffineTransformIdentity;
    }

    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}

- (AVCaptureConnection*)videoConnectionToOutput:(AVCaptureOutput*)output {
    for (AVCaptureConnection *connection in output.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                return connection;
            }
        }
    }
    return nil;
}

@end
