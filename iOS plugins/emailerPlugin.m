//
//  emailerPlugin.m
//  Group-e
//
//  Created by Shari Girten on 12/11/13.
//  Copyright (c) 2013 The Conference Group. All rights reserved.


//need to create a global variable for MF MFMailComposeViewController  ***********************************
 //MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];


#define RETURN_CODE_EMAIL_CANCELLED 0
#define RETURN_CODE_EMAIL_SAVED 1
#define RETURN_CODE_EMAIL_SENT 2
#define RETURN_CODE_EMAIL_FAILED 3
#define RETURN_CODE_EMAIL_NOTSENT 4


#import "emailerPlugin.h"
#import <MobileCoreServices/MobileCoreServices.h>


@implementation emailerPlugin


    - (void) showEmailComposer:(CDVInvokedUrlCommand*)command {

        [self.commandDelegate runInBackground:^{

            //  impport ics, vcf parameters
            NSString *conferenceName = [command.arguments objectAtIndex:0];
            NSString *conferenceNumber = [command.arguments objectAtIndex:1];
            NSString *conferencePasscode = [command.arguments objectAtIndex:2];
            NSString *conferenceStartDate = [command.arguments objectAtIndex:3];
            NSString *conferenceStartTime = [command.arguments objectAtIndex:4];
            NSString *conferenceEndDate = [command.arguments objectAtIndex:5];
            NSString *conferenceEndTime = [command.arguments objectAtIndex:6];
            NSDictionary *ics = [command.arguments objectAtIndex:7];
            NSDictionary *vcf = [command.arguments objectAtIndex:8];
            
NSLog(@">>> we are inside of the plugin showEmailComposer and the parameter[0] is:       %@", ics);
NSLog(@">>> we are inside of the plugin showEmailComposer and the parameter[1] is:       %@", vcf);
            
            NSString* icsName = [command.arguments objectAtIndex:7];
            NSString* icsFileName = nil;
            if(ics != (id)[NSNull null]) {
                icsFileName = [icsName lastPathComponent];
            }
            
            NSString* vcfName = [command.arguments objectAtIndex:8];
            NSString* vcfFileName = nil;
            if(vcf != (id)[NSNull null]) {
                vcfFileName = [vcfName lastPathComponent];
            }
            
            NSString *msg = nil;
            //attach vcf only
            if((vcf != (id)[NSNull null]) && (ics == (id)[NSNull null])) {
                msg = @".\n\nFor your convenience I have attached the conference information as a vCard. Feel free to download as a Contact for one-tap dialing.";

            }

            //attach ics only
            if((ics != (id)[NSNull null]) && (vcf == (id)[NSNull null])) {
                msg = @".\n\nFor your convenience I have attached the conference information as a reminder. Feel free to download it to your calendar.";

            }
            
            //attach ics and vcf
            if((ics != (id)[NSNull null]) && (vcf != (id)[NSNull null])) {
                msg = @".\n\nFor your convenience I have attached the conference information as a vCard. Feel free to download as a Contact for one-tap dialing. \n\nAdditionally, I have attached a calendar reminder.";
            }

            
            mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            
            // set subject
            @try {
                NSString* subject = @"You are invited to ";
                subject = [subject stringByAppendingString:conferenceName];
                if (subject) {
                    [mailComposer setSubject:subject];
                }
            } @catch (NSException *exception) {
                NSLog(@"EmailComposer - Cannot set subject; error: %@", exception);
            }
            
            // set body
            @try {
                NSString *body = @"\n\nPlease join me in attending ";
                body = [body stringByAppendingString:conferenceName];

                if(conferenceStartDate != (id)[NSNull null]) {
                    body = [body stringByAppendingString:@".\n\nIt will occur on "];
                    body = [body stringByAppendingString:conferenceStartDate];
                    body = [body stringByAppendingString:@" from "];
                    body = [body stringByAppendingString:conferenceStartTime];
                    body = [body stringByAppendingString:@" to "];
                    body = [body stringByAppendingString:conferenceEndTime];
                }

                body = [body stringByAppendingString:@".\n\nThe phone number is "];
                body = [body stringByAppendingString:conferenceNumber];
                body = [body stringByAppendingString:@".\n\nThe passcode is "];
                body = [body stringByAppendingString:conferencePasscode];
                body = [body stringByAppendingString:msg];
                BOOL isHTML = [@"false" boolValue];
                if(body) {
                    [mailComposer setMessageBody:body isHTML:isHTML];
                }
            } @catch (NSException *exception) {
                NSLog(@"EmailComposer - Cannot set body; error: %@", exception);
            }
            
            // Set recipients
            @try {
                if(ics != (id)[NSNull null]) {
                    NSData *icsData = [NSData dataWithContentsOfFile:icsName];
                    [mailComposer addAttachmentData:icsData mimeType:@"text/calendar" fileName:icsFileName];          // use for Exchange Server 2008 and above
                    //[mailComposer addAttachmentData:icsData mimeType:@"application/octet-stream" fileName:icsFileName]; // for the sake of Exchange Server 2003 ineptitude
                }

                if(vcf != (id)[NSNull null]) {
                    NSData *vcfData = [NSData dataWithContentsOfFile:vcfName];
                    [mailComposer addAttachmentData:vcfData mimeType:@"text/vcard" fileName:vcfFileName];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"EmailComposer - Cannot set attachments; error: %@", exception);
            }
        
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    
            if (mailComposer != nil) {
                [self.viewController presentViewController:mailComposer animated:YES completion:nil];
            } else {
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }

        }];

    }

    - (void) showVideoEmailComposer:(CDVInvokedUrlCommand*)command {

        [self.commandDelegate runInBackground:^{
NSLog(@"========================>>> in the showVideoEmailComposer       ");

            NSString *videoPath = [command.arguments objectAtIndex:0];
            
            
            mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            
            // set subject
            @try {
                NSString* subject = @"You have a video message!";
                if (subject) {
                    [mailComposer setSubject:subject];
                }
            } @catch (NSException *exception) {
                NSLog(@"EmailComposer - Cannot set subject; error: %@", exception);
            }
            
            // set body
            @try {
                NSString *body = @"Click on the link below to view a video message:\n\n";
                body = [body stringByAppendingString:videoPath];

                BOOL isHTML = [@"false" boolValue];
                if(body) {
                    [mailComposer setMessageBody:body isHTML:isHTML];
                }
            } @catch (NSException *exception) {
                NSLog(@"EmailComposer - Cannot set body; error: %@", exception);
            }
            
        
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    
            if (mailComposer != nil) {
                [self.viewController presentViewController:mailComposer animated:YES completion:nil];
            } else {
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }

        }];

    }


    // Dismisses the email composition interface when users tap Cancel or Send.
    // Proceeds to update the message field with the result of the operation.
    - (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
            // Notifies users about errors associated with the interface
            int webviewResult = 0;
            switch (result) {
                case MFMailComposeResultCancelled:
                    webviewResult = RETURN_CODE_EMAIL_CANCELLED;
                    break;
                case MFMailComposeResultSaved:
                    webviewResult = RETURN_CODE_EMAIL_SAVED;
                    break;
                case MFMailComposeResultSent:
                    webviewResult =RETURN_CODE_EMAIL_SENT;
                    break;
                case MFMailComposeResultFailed:
                    webviewResult = RETURN_CODE_EMAIL_FAILED;
                    break;
                default:
                    webviewResult = RETURN_CODE_EMAIL_NOTSENT;
                    break;
            }
NSLog(@">>> dismissing the email controller and the webviewResult code is :       %d", webviewResult);
            [controller dismissViewControllerAnimated:YES completion:nil];
            [self returnWithCode:webviewResult];
        }
        
 
    // Call the callback with the specified code
    -(void) returnWithCode:(int)code {
        [self writeJavascript:[NSString stringWithFormat:@"window.plugins.emailComposer._didFinishWithResult(%d);", code]];
    }




    - (void) showMMSComposer:(CDVInvokedUrlCommand*)command {
    
       [self.commandDelegate runInBackground:^{
    
            NSString *conferenceName = [command.arguments objectAtIndex:0];
            NSString *conferenceNumber = [command.arguments objectAtIndex:1];
            NSString *conferencePasscode = [command.arguments objectAtIndex:2];
            NSString *conferenceStartDate = [command.arguments objectAtIndex:3];
            NSString *conferenceStartTime = [command.arguments objectAtIndex:4];
            NSString *conferenceEndDate = [command.arguments objectAtIndex:5];
            NSString *conferenceEndTime = [command.arguments objectAtIndex:6];
            NSDictionary *ics = [command.arguments objectAtIndex:7];
            NSString* icsName = [command.arguments objectAtIndex:7];
           
            NSString* icsFileName = nil;
            if(ics != (id)[NSNull null]) {
                icsFileName = [icsName lastPathComponent];
            }

            NSDictionary *vcf = [command.arguments objectAtIndex:8];
            NSString* vcfName = [command.arguments objectAtIndex:8];

            NSString* vcfFileName = nil;
            if(vcf != (id)[NSNull null]) {
                vcfFileName = [vcfName lastPathComponent];
            }
           
            NSLog(@">>> we are inside of the plugin showMMSComposer and the parameters is:       %@", ics);
            NSLog(@">>> we are inside of the plugin showMMSComposer and the parameters is:       %@", vcf);
           
            
            NSString *msg = nil;
            //attach vcf only
            if((vcf != (id)[NSNull null]) && (ics == (id)[NSNull null])) {
                msg = @".\n\nFor your convenience I have attached the conference information as a vCard. Feel free to download as a Contact for one-tap dialing.";
            }

            //attach ics only
            if((ics != (id)[NSNull null]) && (vcf == (id)[NSNull null])) {
                msg = @".\n\nFor your convenience I have attached the conference information as a reminder. Feel free to download it to your calendar.";
            }
            
            //attach ics and vcf
            if((ics != (id)[NSNull null]) && (vcf != (id)[NSNull null])) {
                msg = @".\n\nFor your convenience I have attached the conference information as a vCard. Feel free to download as a Contact for one-tap dialing. \n\nAdditionally, I have attached a calendar reminder.";
            }
           
            composer = [[MFMessageComposeViewController alloc] init];
            composer.messageComposeDelegate = self;
           
           
            if([MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)] && [MFMessageComposeViewController canSendAttachments]) {
                NSString *body = @"\n\nPlease join me in attending ";
                body = [body stringByAppendingString:conferenceName];

                if(conferenceStartDate != (id)[NSNull null]) {
                    body = [body stringByAppendingString:@".\n\nIt will occur on "];
                    body = [body stringByAppendingString:conferenceStartDate];
                    body = [body stringByAppendingString:@" from "];
                    body = [body stringByAppendingString:conferenceStartTime];
                    body = [body stringByAppendingString:@" to "];
                    body = [body stringByAppendingString:conferenceEndTime];
                }

                body = [body stringByAppendingString:@".\n\nThe phone number is "];
                body = [body stringByAppendingString:conferenceNumber];
                body = [body stringByAppendingString:@".\n\nThe passcode is "];
                body = [body stringByAppendingString:conferencePasscode];
                body = [body stringByAppendingString:msg];

                [composer setBody:body];
                
                @try {
                    if(ics != (id)[NSNull null]) {
                        NSData *icsData = [NSData dataWithContentsOfFile:icsName];
                        [composer addAttachmentData:icsData typeIdentifier:@"public.calendar-event" filename:icsFileName];
                    }
                    if(vcf != (id)[NSNull null]) {
                        NSData *vcfData = [NSData dataWithContentsOfFile:vcfName];
                        [composer addAttachmentData:vcfData typeIdentifier:@"text/vcard" filename:vcfFileName];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"Cannot attach file - error: %@", exception);
                }
            }

           CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
            if (composer != nil) {
                [self.viewController presentViewController:composer animated:YES completion:nil];
            } else {
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }

        }];
      
    }



    - (void) showVideoMMSComposer:(CDVInvokedUrlCommand*)command {
    
       [self.commandDelegate runInBackground:^{
    
            NSString *videoPath = [command.arguments objectAtIndex:0];
           
            NSLog(@">>> we are inside of the plugin showVideoMMSComposer and the parameters is:       ");
            
            composer = [[MFMessageComposeViewController alloc] init];
            composer.messageComposeDelegate = self;
            
            NSString *body = @"Click on the link below to view a video message:\n";
            body = [body stringByAppendingString:videoPath];
            [composer setBody:body];

            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
            if (composer != nil) {
                [self.viewController presentViewController:composer animated:YES completion:nil];
            } else {
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }

        }];
      
    }

// -------------------------------------------------------------------------------
//  messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
        int webviewResult = 0;
        // Notifies users about errors associated with the interface
        switch (result)
        {
            case MessageComposeResultCancelled:
                webviewResult = RETURN_CODE_EMAIL_CANCELLED;
                break;
            case MessageComposeResultSent:
                webviewResult = RETURN_CODE_EMAIL_SENT;
                break;
            case MessageComposeResultFailed:
                webviewResult = RETURN_CODE_EMAIL_FAILED;
                break;
            default:
                webviewResult = RETURN_CODE_EMAIL_NOTSENT;
                break;
        }
NSLog(@">>> dismissing the message controller and the webviewResult code is :       %d", webviewResult);
        [controller dismissViewControllerAnimated:YES completion:nil];
        [self returnWithCode:webviewResult];
}


@end