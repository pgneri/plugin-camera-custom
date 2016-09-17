//
//  CustomCamera.h
//  CustomCamera
//
//  Created by Patrícia Gabriele Neri on 13/09/16.
//
//

#import <Cordova/CDV.h>

@interface CustomCamera : CDVPlugin

- (void)takePicture:(CDVInvokedUrlCommand*)command;

@end
