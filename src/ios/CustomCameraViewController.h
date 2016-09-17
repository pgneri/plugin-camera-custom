//
//  CustomCameraViewController.h
//  CustomCamera
//
//  Created by Patrícia Gabriele Neri on 13/09/16.
//
//

#import <UIKit/UIKit.h>

@interface CustomCameraViewController : UIViewController

- (id)initWithCallback:(void(^)(UIImage*))callback;

@end
