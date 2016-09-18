//
//  GlobalVars.m
//  ExempleCustomCamera
//
//  Created by Patrícia Gabriele Neri on 18/09/16.
//
//

#import "GlobalVars.h"

@implementation GlobalVars

@synthesize title = _title;
@synthesize buttonDone = _buttonDone;
@synthesize buttonRestart = _buttonRestart;
@synthesize buttonCancel = _buttonCancel;
@synthesize toggleCamera = _toggleCamera;

+ (GlobalVars *)sharedInstance {
    static dispatch_once_t onceToken;
    static GlobalVars *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalVars alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // Note these aren't allocated as [[NSString alloc] init] doesn't provide a useful object
        _title = nil;
        _buttonDone = nil;
        _buttonRestart = nil;
        _buttonCancel = nil;
        _toggleCamera = nil;
    }
    return self;
}
@end
