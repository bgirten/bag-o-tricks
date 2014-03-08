//
//  emailerPlugin.h
//  Group-e
//
//  Created by Bill Girten on 10/26/13.
//  Copyright (c) 2013 The Conference Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>


@interface emailerPlugin : CDVPlugin <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    MFMailComposeViewController *mailComposer;
    MFMessageComposeViewController* composer;
}

//emailer instance methods
- (void) showEmailComposer:(CDVInvokedUrlCommand*)command;
- (void) showVideoEmailComposer:(CDVInvokedUrlCommand*)command;
- (void) showMMSComposer:(CDVInvokedUrlCommand*)command;
- (void) showVideoMMSComposer:(CDVInvokedUrlCommand*)command;

- (void) returnWithCode:(int)code;

@end

