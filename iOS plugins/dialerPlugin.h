//
//  dialerPlugin.h
//  Group-e
//
//  Created by Bill Girten on 10/26/13.
//  Copyright (c) 2013 The Conference Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>


@interface dialerPlugin : CDVPlugin {
}

- (void) dialConference:(CDVInvokedUrlCommand*)command;
 
@end