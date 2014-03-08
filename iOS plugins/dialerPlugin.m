//
//  dialerPlugin.m
//  Group-e
//
//  Created by Bill Girten on 10/26/13.
//  Copyright (c) 2013 The Conference Group. All rights reserved.
//

#import "dialerPlugin.h"


@implementation dialerPlugin


     - (void) dialConference:(CDVInvokedUrlCommand*)command {
     
NSLog(@"In the dialerPlugin inside of Objective-C!!!!   ~~~~~~~~~~~~~~  ");

        [self.commandDelegate runInBackground:^{
    
            //Get the strings that javascript sent us
            NSString *conferenceNumber = [command.arguments objectAtIndex:0];
            NSString *trimmedConferenceNumber = [conferenceNumber stringByReplacingOccurrencesOfString:@" " withString:@""];

            //Create the Message that we wish to send to the Javascript
            NSMutableString *stringToReturn = [NSMutableString stringWithString: @"the native class received: "];
            
            //Append the received string to the string we plan to send out
            [stringToReturn appendString: trimmedConferenceNumber];

            //Create Plugin Result
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];

            // pick up the target phone number 4-second pause, and passcode and pass them as DTMF codes to the dialer
            NSString *telString = [NSString stringWithFormat:@"tel:%@", trimmedConferenceNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telString]];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        }];

    }
 
@end

