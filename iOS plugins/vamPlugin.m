//
//  vamPlugin.m
//  Group-e
//
//  Created by Bill Girten on 10/26/13.
//  Copyright (c) 2013 The Conference Group. All rights reserved.
//

#import "vamPlugin.h"


@implementation vamPlugin

     - (void) fileXfer:(CDVInvokedUrlCommand*)command {
     
        [self.commandDelegate runInBackground:^{
    
            NSString *fileName = [command.arguments objectAtIndex:0];

            NSMutableString *stringOutbound = [NSMutableString stringWithString: @"Content-Disposition: form-data; name=\"userfile\"; filename=\""];
            [stringOutbound appendString: fileName];
            [stringOutbound appendString: @"\"\r\n"];

            NSString *escapedUrlString = [fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // NSLog(@"escapedUrlString=%@",escapedUrlString);

            NSData *webdata = [NSData dataWithContentsOfFile:escapedUrlString];
            //NSLog(@"webData = %@",webdata);

            NSString *urlString = @"http://www.brainchildren.net/staging/vamcontrol.php";
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:urlString]];
            [request setHTTPMethod:@"POST"];

            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];

            NSMutableData *body = [NSMutableData data];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            /*
                PHP requirements:
                    fileKey = "file";
                    fileName = promptVideoFilename;
            */
            [body appendData:[stringOutbound dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:webdata]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];

            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];

            NSLog(@">>> returning link %@",returnString);

            NSError *error = nil;
            if([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
                [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
                NSLog(@"%@",error);
            }


            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        }];

    }

@end