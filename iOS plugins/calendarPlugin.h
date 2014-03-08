//
//  calendarPlugin.h
//  Author: Felix Montanez
//  Date: 01-17-2011
//  Notes:
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <EventKitUI/EventKitUI.h>
#import <EventKit/EventKit.h>


@interface calendarPlugin : CDVPlugin

@property (nonatomic, retain) EKEventStore* eventStore;

- (void)initEventStoreWithCalendarCapabilities;

-(NSArray*)findEKEventsWithTitle: (NSString *)title
                        location: (NSString *)location
                     description: (NSString *)description
                       startDate: (NSDate *)startDate
                         endDate: (NSDate *)endDate;

-(NSArray*)findEKEventsWithATitle: (NSString *)title;

    
-(NSArray*)findEKEventByID: (NSString *)eventID;


// Calendar Instance methods

- (void) createEvent:(CDVInvokedUrlCommand*)command;
- (void) modifyEvent:(CDVInvokedUrlCommand*)command;
- (void) modifyEventTitle:(CDVInvokedUrlCommand*)command;
- (void) findEventWithDate:(CDVInvokedUrlCommand*)command;
- (void) findScheduledConference:(CDVInvokedUrlCommand*)command;
- (void) deleteEventByTitle:(CDVInvokedUrlCommand*)command;

@end