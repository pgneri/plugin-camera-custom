//
//  GlobalVars.h
//  ExempleCustomCamera
//
//  Created by Patrícia Gabriele Neri on 18/09/16.
//
//

#import <Foundation/Foundation.h>

@interface GlobalVars : NSObject
{
    NSString *_title;
    NSString *_buttonDone;
    NSString *_buttonRestart;
    NSString *_buttonCancel;
    NSString *_toggleCamera;
}

+ (GlobalVars *)sharedInstance;

@property(strong, nonatomic, readwrite) NSString *title;
@property(strong, nonatomic, readwrite) NSString *buttonDone;
@property(strong, nonatomic, readwrite) NSString *buttonRestart;
@property(strong, nonatomic, readwrite) NSString *buttonCancel;
@property(strong, nonatomic, readwrite) NSString *toggleCamera;

@end