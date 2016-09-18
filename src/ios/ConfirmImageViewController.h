//
//  ConfirmImageViewController.h
//  CustomCamera
//
//  Created by Patrícia Gabriele Neri on 16/09/16.
//
//

#import <UIKit/UIKit.h>

@interface ConfirmImageViewController : UIViewController

- (id)initWithCallback:(void(^)(BOOL*))callback;
-(UIImageView *)imageView;
-(UIImage *)image;

@end
