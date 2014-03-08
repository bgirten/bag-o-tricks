//
//  calendarPlugin.m
//  Author: Felix Montanez
//  Date: 01-17-2011
//  Notes:
//
// Contributors : Sean Bedford


#import "calendarPlugin.h"
#import <EventKitUI/EventKitUI.h>
#import <EventKit/EventKit.h>


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation calendarPlugin
@synthesize eventStore;

#pragma mark Initialisation functions

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (calendarPlugin*)[super initWithWebView:theWebView];
    if (self) {
		//[self setup];
        [self initEventStoreWithCalendarCapabilities];
    }
    return self;
}

- (void)initEventStoreWithCalendarCapabilities {

        __block BOOL accessGranted = NO;
        eventStore= [[EKEventStore alloc] init];
        if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        } else { // we're on iOS 5 or older
            accessGranted = YES;
        }

        if (accessGranted) {
            self.eventStore = eventStore;
        }

}




- (void) findEventByID:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{
    
            NSString* eventID      = [command.arguments objectAtIndex:0];
            NSArray *matchingEvents = [self findEKEventByID:eventID];
            NSMutableArray *finalResults = [[NSMutableArray alloc] initWithCapacity:matchingEvents.count];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        
            NSString *description = @"";

            for (EKEvent * event in matchingEvents) {
                if(event.notes.length != 0) description = event.notes;

                NSMutableDictionary *entry = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                event.title, @"title",
                event.location, @"location",
                description, @"description",
                [df stringFromDate:event.startDate], @"startDate",
                [df stringFromDate:event.endDate], @"endDate",
                event.eventIdentifier, @"eventID", nil];

                [finalResults addObject:entry];
            }
NSLog(@"FINAL RESULTS for findEventByID inside of plugin are:    %@", finalResults);
            
            if(finalResults.count > 0) {
                CDVPluginResult* result = [CDVPluginResult
                                           resultWithStatus: CDVCommandStatus_OK
                                           messageAsArray:finalResults];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
    
    }];
    
}



#pragma mark Helper Functions

//used with modifyEvent() and deleteEvent() and findEvent() within calendarPlugIn
-(NSArray*)findEKEventByID: (NSString *)eventID {

    
        // Build up a predicateString - this means we only query a parameter if we actually had a value in it
        NSMutableString *predicateString= [[NSMutableString alloc] initWithString:@""];
            if (eventID.length > 0) {
            [predicateString appendString:[NSString stringWithFormat:@"eventIdentifier == '%@'" , eventID]];
        }

        NSPredicate *matches = [NSPredicate predicateWithFormat:predicateString];

        const double secondsInAYear = (60.0*60.0*24.0)*365.0;
        
        NSArray *datedEvents = [self.eventStore eventsMatchingPredicate:[eventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:[NSDate dateWithTimeIntervalSinceNow:secondsInAYear] calendars:nil]];

        NSArray *matchingEvents = [datedEvents filteredArrayUsingPredicate:matches];
        
//NSLog(@"matchingEvents within the findEKEventByID is  :    %@", matchingEvents);

        return matchingEvents;
}




//used with modifyEvent() and deleteEvent() and findEvent() within calendarPlugIn
-(NSArray*)findEKEventsWithTitle: (NSString *)title
                        location: (NSString *)location
                     description: (NSString *)description
                       startDate: (NSDate *)startDate
                         endDate: (NSDate *)endDate {

    
        // Build up a predicateString - this means we only query a parameter if we actually had a value in it
        NSMutableString *predicateString= [[NSMutableString alloc] initWithString:@""];
            if (title.length > 0) {
            [predicateString appendString:[NSString stringWithFormat:@"title == '%@'" , title]];
        }
            if (location.length > 0) {
            [predicateString appendString:[NSString stringWithFormat:@" AND location == '%@'" , location]];
        }

        NSPredicate *matches = [NSPredicate predicateWithFormat:predicateString];

        const double secondsInAYear = (60.0*60.0*24.0)*365.0;
        
        NSArray *datedEvents = [self.eventStore eventsMatchingPredicate:[eventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:[NSDate dateWithTimeIntervalSinceNow:secondsInAYear] calendars:nil]];

        NSArray *matchingEvents = [datedEvents filteredArrayUsingPredicate:matches];
    
NSLog(@"~~~~~~~~~~~~~~~~~~~~      matchingEvents within the findEKEventsWithTitle is  :    %lu", (unsigned long)matchingEvents.count);
NSLog(@" ---------- ~~~  ~~~~ matchingEvents within the findEKEventsWithTitle is  :    %@", matchingEvents);

        return matchingEvents;

}




-(NSArray*)findEKEventsWithATitle: (NSString *)title {
        NSMutableString *predicateString= [[NSMutableString alloc] initWithString:@""];
        if (title.length > 0) {
            [predicateString appendString:[NSString stringWithFormat:@"title == '%@'" , title]];
        }
        NSPredicate *matches = [NSPredicate predicateWithFormat:predicateString];

        const double secondsInAYear = (60.0*60.0*24.0)*365.0;
        
        NSArray *datedEvents = [self.eventStore eventsMatchingPredicate:[eventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:[NSDate dateWithTimeIntervalSinceNow:secondsInAYear] calendars:nil]];

        NSArray *matchingEvents = [datedEvents filteredArrayUsingPredicate:matches];
NSLog(@"matchingEvents within the findEKEventsWithTitle is  :    %@", matchingEvents);
        return matchingEvents;
}



#pragma mark Cordova functions

//used with onCreateSuccess()
- (void)createEvent:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{
    
        // Import arguments
        NSLog(@"In the createEvent inside of Objective-C!!!!   >>>>>>>>>>>>>");


        // NSString *callbackId = [arguments pop];
        NSString* title = [command.arguments objectAtIndex:0];
NSLog(@">>>>>>>>>>>>>>>>> notes = %@", [command.arguments objectAtIndex:1]);
        NSString* description = [command.arguments objectAtIndex:1];
        NSString* location = [command.arguments objectAtIndex:2];
        NSString *startDate = [command.arguments objectAtIndex:3];
        NSString *endDate = [command.arguments objectAtIndex:4];
    
        NSString *recurrenceFrequency = [command.arguments objectAtIndex:5];
        int recurrenceDateSpan = [[command.arguments objectAtIndex:6] intValue];
        int recurrenceTimeSpan = [[command.arguments objectAtIndex:7] intValue];
        
        //creating the dateformatter object
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *myStartDate = [df dateFromString:startDate];
        NSDate *myEndDate = [df dateFromString:endDate];
        
        
        EKEvent *myEvent = [EKEvent eventWithEventStore: self.eventStore];
        myEvent.title = title;
        myEvent.notes = description;
        myEvent.location = location;
        myEvent.startDate = myStartDate;
        myEvent.endDate = myEndDate;
        myEvent.calendar = self.eventStore.defaultCalendarForNewEvents;
        

        if(![recurrenceFrequency isEqual: @"Never"]) {
            NSTimeInterval timeSpan = recurrenceTimeSpan;
            NSDate *eventEndDate = [myStartDate dateByAddingTimeInterval:timeSpan];
            myEvent.endDate = eventEndDate;
            
            NSTimeInterval dateSpan = recurrenceDateSpan;
            NSDate *dateSpanFromNow = [myStartDate dateByAddingTimeInterval:dateSpan];
            
            // Set the recurrence end date
            EKRecurrenceEnd *recurEnd = [EKRecurrenceEnd recurrenceEndWithEndDate:dateSpanFromNow];
            
            EKRecurrenceRule *recurringRule = nil;
            if([recurrenceFrequency isEqualToString:@"Every Day"]) {
                recurringRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:recurEnd];
            }
            if([recurrenceFrequency isEqualToString:@"Every Week"]) {
                recurringRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 end:recurEnd];
            }
            if([recurrenceFrequency isEqualToString:@"Every 2 Weeks"]) {
                recurringRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:2 end:recurEnd];
            }
            if([recurrenceFrequency isEqualToString:@"Every Month"]) {
                recurringRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:1 end:recurEnd];
            }
            if([recurrenceFrequency isEqualToString:@"Every Year"]) {
                recurringRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly interval:1 end:recurEnd];
            }


            //Set the recurring rule for the event
            myEvent.recurrenceRules = [[NSArray alloc] initWithObjects:recurringRule, nil];
NSLog(@"The recurrence rule for this event is   >>>>>>>>>>>>>%@", myEvent);
        }
        
       
        //Save the event
        NSError *error = nil;
        [self.eventStore saveEvent:myEvent span:EKSpanFutureEvents error:&error];

        // Check error code + return result
        CDVPluginResult* pluginResult = nil;

        if (!error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    }];

}


//used with onRemoveSuccess()
- (void)deleteEventByID:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{

        NSLog(@"In the deleteEventByID inside of Objective-C!!!!   >>>>>>>>>>>>>");
    
        NSString* eventID       = [command.arguments objectAtIndex:0];
        NSArray *matchingEvents = [self findEKEventByID:eventID];
    
        if(matchingEvents.count > 0) {
            // Definitive single match - delete it!      
            NSError *error = NULL;
            bool hadErrors = false;
            for(EKEvent *event in matchingEvents) {
                //[self.eventStore removeEvent:event span:EKSpanThisEvent error:&error];
                [self.eventStore removeEvent:[matchingEvents firstObject] span:EKSpanThisEvent error:&error];
            }

            //[self.eventStore removeEvent:[matchingEvents lastObject] span:EKSpanThisEvent error:&error];
            
            // Check for error codes and return result
            CDVPluginResult* pluginResult = nil;
            if (error || hadErrors) {
                NSString *messageString;
                if (hadErrors) {
                    messageString = @"Error deleting events";
                    NSLog(@"~~~~~   inside of deleteEventByID and had an error deleting     :    %@", messageString);
                }
                else {
                    messageString = error.userInfo.description;
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                   messageAsString:messageString];
            }
            else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            NSLog(@"~~~~~   inside of deleteEventByID and matching events are     :    %@", matchingEvents);
            
        }

    }];
 
}


//used with onRemoveSuccess()
- (void)deleteEventByTitle:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{

        NSLog(@"In the deleteEventByTitle inside of Objective-C!!!!   >>>>>>>>>>>>>");
    
        NSString *title         = [command.arguments objectAtIndex:0];
        NSArray *matchingEvents = [self findEKEventsWithATitle:title];

        if(matchingEvents.count > 0) {
        
            // Definitive single match - delete it!      
            NSError *error = NULL;
            bool hadErrors = false;
            for(EKEvent *event in matchingEvents) {
                [self.eventStore removeEvent:event span:EKSpanThisEvent error:&error];
            }
            
            // Check for error codes and return result
            CDVPluginResult* pluginResult = nil;
            if (error || hadErrors) {
                NSString *messageString;
                if(hadErrors) {
                    messageString = @"Error deleting events";
                } else {
                    messageString = error.userInfo.description;
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                   messageAsString:messageString];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }

    }];
 
}


//used with presentConferencesSchedule()
- (void) findEventWithDate:(CDVInvokedUrlCommand*)command {

NSLog(@">>>>>>>>>>>>>>>>>>>>>> findEventWithDate");

    [self.commandDelegate runInBackground:^{

            // Import arguments
            NSString *startDate  = [command.arguments objectAtIndex:0];
            NSString *endDate    = [command.arguments objectAtIndex:1];


            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *myStartDate = [df dateFromString:startDate];
            NSDate *myEndDate = [df dateFromString:endDate];
        
            // Create the predicate from the event store's instance method
            NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:myStartDate
                                                                endDate:myEndDate
                                                              calendars:nil];


            // Fetch all events that match the predicate
            NSArray *matchingEvents = [self.eventStore eventsMatchingPredicate:predicate];
            NSMutableArray *finalResults = [[NSMutableArray alloc] initWithCapacity:matchingEvents.count];
            
            
            // Stringify the results - Cordova can't deal with Obj-C objects
            NSString *description = @"";
            for (EKEvent * event in matchingEvents) {
            /*
            NSLog(@">>>> calendar ID = %@", event.calendarItemIdentifier);
            NSLog(@">>>> event ID = %@", event.eventIdentifier);
            NSLog(@">>>> title = %@", event.title);
            NSLog(@">>>> notes = %@", event.notes);
            NSLog(@">>>> start date = %@", [df stringFromDate:event.startDate]);
            NSLog(@">>>> end date = %@", [df stringFromDate:event.endDate]);
            */
                if(event.notes.length != 0) {
                    description = event.notes;
                }

                NSMutableDictionary *entry = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                event.title, @"title",
                description, @"description",
                [df stringFromDate:event.startDate], @"startDate",
                [df stringFromDate:event.endDate], @"endDate",
                event.eventIdentifier, @"eventID", nil];
                [finalResults addObject:entry];
            }
        //NSLog(@"~~~~~   FINAL RESULTS inside of findEventWithDate plugin are:    %@", finalResults);

        // Check error code + return result
        CDVPluginResult* pluginResult = nil;

        if (finalResults.count > 0) {
                pluginResult = [CDVPluginResult
                                   resultWithStatus: CDVCommandStatus_OK
                                   messageAsArray:finalResults
                               ];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
    
}

 
//used with updateAScheduledConference()
- (void)modifyEvent:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{

                // Import arguments
            NSLog(@"In the modifyEvent inside of PlugIn     %%%%%%%%%%**********   ");
        
                NSString* eventID      = [command.arguments objectAtIndex:0];
                NSString* nlocation   = [command.arguments objectAtIndex:1];
                NSString* ndescription    = [command.arguments objectAtIndex:2];
                NSString *nstartDate  = [command.arguments objectAtIndex:3];
                NSString *nendDate    = [command.arguments objectAtIndex:4];
        
                // Make NSDates from our strings
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd HH:mm"];

                // Find matches using the findEKEventByID
                NSArray *matchingEvents = [self findEKEventByID:eventID];

                NSLog(@"In the modifyEvent and the matchingEvents are:    %lu", (unsigned long)matchingEvents.count);

                
                if (matchingEvents.count > 0) {

                    // Presume we have to have an exact match to modify it!
                    // Need to load this event from an EKEventStore so we can edit it
                    EKEvent *theEvent = [self.eventStore eventWithIdentifier:((EKEvent*)[matchingEvents firstObject]).eventIdentifier];
                    if (nlocation) {
                        theEvent.location = nlocation;
                    }
                    if (ndescription) {
                        theEvent.notes = ndescription;
                    }
                    if (nstartDate) {
                        NSDate *newMyStartDate = [df dateFromString:nstartDate];
                        theEvent.startDate = newMyStartDate;
                    }
                    if (nendDate) {
                        NSDate *newMyEndDate = [df dateFromString:nendDate];
                        theEvent.endDate = newMyEndDate;
                    }
                    
                    // Now save the new details back to the store
                    NSError *error = nil;
                    [self.eventStore saveEvent:theEvent span:EKSpanThisEvent error:&error];
                    
                    // Check error code + return result
                    if (error) {
                        CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                           messageAsString:error.userInfo.description];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                        
                    }
                    else {
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                }
                else {
                    // Otherwise return a no result error
                    CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                    
                    //[self writeJavascript:[pluginResult toErrorCallbackString:command.callbackId]];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
    
     }];
    
}



 
//used with onUpdateSuccess() of changing a conference name
- (void)modifyEventTitle:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{

        // Import arguments
        NSLog(@"In the modifyEventTitle inside of PlugIn     %%%%%%%%%%**********   ");
        
        NSString *oldTitle = [command.arguments objectAtIndex:0];
        NSString *newTitle = [command.arguments objectAtIndex:1];

        // Find matches using the findEKEventsWithTitle function
        NSArray *matchingEvents = [self findEKEventsWithATitle:oldTitle];

        if(matchingEvents.count > 0) {
            NSError *error = nil;
            for(EKEvent *event in matchingEvents) {
                if(newTitle) {
                    event.title = newTitle;
                    // Now save the new details back to the store
                    [self.eventStore saveEvent:event span:EKSpanThisEvent error:&error];
                }
            }
        
            // Check error code + return result
            if(error) {
                CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                   messageAsString:error.userInfo.description];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        } else {
            // Otherwise return a no result error
            CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    
     }];
}


 
//used with deleting a conference contact to verify there are no existing events using the conference about to be deleted
- (void)findScheduledConference:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{

        // Import arguments
        NSLog(@"In the findScheduledConference inside of PlugIn     %%%%%%%%%%**********   ");
        
        NSString *title = [command.arguments objectAtIndex:0];

        // Find matches using the findEKEventsWithTitle function
        NSArray *matchingEvents = [self findEKEventsWithATitle:title];

        NSLog(@"~~~~~   FINAL RESULTS inside of findScheduledConference plugin are:    %lu", (unsigned long)matchingEvents.count);

        // Check error code + return result
        CDVPluginResult* pluginResult = nil;
        
        pluginResult = [CDVPluginResult
           resultWithStatus: CDVCommandStatus_OK
           messageAsInt:matchingEvents.count];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    }];

}


@end
