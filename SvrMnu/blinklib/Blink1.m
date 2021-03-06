//
//  Blink1.m
//  Blink1Control
//
//  Created by Tod E. Kurt on 9/6/12.
//  Copyright (c) 2012 ThingM. All rights reserved.
//

#import "Blink1.h"

#include "blink1-lib.h"

@implementation Blink1

@synthesize serialnums;
@synthesize blink1_id;
@synthesize host_id;
@synthesize lastColor;
@synthesize updateHandler;

//
- (id) init
{
    self = [super init];
    serialnums = [[NSMutableArray alloc] init];
    [self startNotes];
    [self enumerate];
    timer = [[NSTimer alloc] init];
    return self;
}

//
- (NSMutableArray*) enumerate
{
    @synchronized(self) {
        [serialnums removeAllObjects];
        int count = blink1_enumerate();
        for( int i=0; i< count; i++ ) {
            NSString * serstr = [[NSString alloc] initWithBytes:blink1_getCachedSerial(i)
                                                         length:8*4
                                                       encoding:NSUTF32LittleEndianStringEncoding];
            [serialnums addObject: serstr];
        }
    }
    return serialnums;
}

-(bool)isHere
{
    //[self enumerate];
    if(serialnums.count>0)
        return true;
    return false;
}
-(void)off
{
    [self setColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1]];
}

-(void)setColor:(NSColor*)c {
    currentColor=c;
    [self fadeToRGB:currentColor atTime:0];
    //[NSObject cancelPreviousPerformRequestsWithTarget:self];
    [timer invalidate];
}

-(void)setPulse:(NSColor*)c {
    currentColor=c;
    //[NSObject cancelPreviousPerformRequestsWithTarget:self];
    [timer invalidate];
    [self startPulse];
}
-(void)startPulse {
    //NSLog(@"startPulse");
    //[timer invalidate];
    [self fadeToRGB:currentColor atTime:1];
    //[self performSelector:@selector(endPulse) withObject:nil afterDelay:3];
    timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(endPulse) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}
-(void)endPulse {
    //NSLog(@"endPulse");
    //[timer invalidate];
    [self fadeToRGB:[NSColor colorWithCalibratedRed:currentColor.redComponent*.1 green:currentColor.redComponent*.1 blue:currentColor.redComponent*.1 alpha:1] atTime:1];
    timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(startPulse) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}



// Create a blink1_id (aka "IFTTT Key" and other names)
// If no blink1 device is present, create a fake blink1_id with zerod serial
//
// How about:
//- (NSString*) regenerateBlink1Id:(NSString*)lastId
// and we check to see if lastId contained a non-zero serial?
- (NSString*) regenerateBlink1Id
{
    if( host_id == nil ) {
        host_id = [NSString stringWithFormat:@"%8.8X",rand()];
    }
    NSString* blink1_serial = @"00000000"; // 8-hexdigit serialnum
    if( [serialnums count] ) {  // we have a blink1
        blink1_serial = [serialnums objectAtIndex:0];
    }
    blink1_id = [NSString stringWithFormat:@"%@%@",host_id,blink1_serial];
    return blink1_id;
}

//
- (void)fadeToRGBstr:(NSString*) hexcstr atTime:(float)t
{
    [self fadeToRGB:[Blink1 colorFromHexRGB: hexcstr] atTime:t];
}

//
- (void)fadeToRGB:(NSColor*) c atTime:(float) t
{
    if(![self isHere])
        return;
    
    CGFloat r,g,b;
    [c getRed:&r green:&g blue:&b alpha:NULL];
    r *= 255; g *= 255; b*=255;
    //DLog(@"rgb:%d,%d,%d t:%2.3f", (int)r,(int)g,(int)b,t);
    lastColor = c;
    if( updateHandler ) { updateHandler(c,t); }
    if( [serialnums count] == 0 ) return;
    @synchronized(self) {
        hid_device *dev = blink1_openById(0);
        blink1_fadeToRGB(dev, (int)(t*1000), (int)r,(int)g,(int)b );
        blink1_close(dev);
    }
}


//
+ (NSColor *) colorFromInt: (unsigned int)colorCode
{
    NSColor *result = nil;
	unsigned char red, green, blue;

    red		= (unsigned char) (colorCode >> 16);
	green	= (unsigned char) (colorCode >> 8);
	blue	= (unsigned char) (colorCode);	// masks off high bits
    
	result = [NSColor colorWithCalibratedRed:(float)red/0xff
                                       green:(float)green/0xff
                                        blue:(float)blue/0xff
                                       alpha:1.0];
	return result;
}

//
- (NSString*) lastColorHexString
{
    //return [Blink1 toHexColorString:lastColor];
    return [Blink1 hexStringFromColor:lastColor];
}

//
+ (NSColor *) colorFromHexRGB:(NSString *) hexStr
{
    unsigned int colorInt;
    NSColor *result = nil;
    
 	if (hexStr != nil) {
		NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        [scanner scanUpToString:@"#" intoString:NULL];
        if( [scanner scanString:@"#" intoString:NULL] ) {
            [scanner scanHexInt:&colorInt];
            result = [Blink1 colorFromInt: colorInt];
        }
	}
    
    return result;
}

//
//+ (NSString*) toHexColorString: (NSColor*)colr
+ (NSString*) hexStringFromColor: (NSColor*)colr;
{
    return [NSString stringWithFormat:@"#%0.2X%0.2X%0.2X",
            (int)(255 * [colr redComponent]),
            (int)(255 * [colr greenComponent]),
            (int)(255 * [colr blueComponent])];
}


#pragma mark -
#pragma mark C Callback functions
#pragma mark -

void usbDeviceAppeared(void *refCon, io_iterator_t iterator){
    //NSLog(@"Matching USB device appeared");
    [(__bridge Blink1*)refCon matchingDevicesAdded:iterator];
}
void usbDeviceDisappeared(void *refCon, io_iterator_t iterator){
    //NSLog(@"Matching USB device disappeared");
    [(__bridge Blink1*)refCon matchingDevicesRemoved:iterator];
}



#pragma mark -
#pragma mark Application Methods
#pragma mark -

#define     matchVendorID           0x27B8
#define     matchProductID          0x01ED



- (void)startNotes
{
    io_iterator_t newDevicesIterator;
    io_iterator_t lostDevicesIterator;
    
    newDevicesIterator = 0;
    lostDevicesIterator = 0;
    //NSLog(@" ");
    
    NSMutableDictionary *matchingDict = (__bridge NSMutableDictionary *)IOServiceMatching(kIOUSBDeviceClassName);
    
    if (matchingDict == nil){
        NSLog(@"Could not create matching dictionary");
        return;
    }
    [matchingDict setObject:[NSNumber numberWithShort:matchVendorID] forKey:(NSString *)CFSTR(kUSBVendorID)];
    [matchingDict setObject:[NSNumber numberWithShort:matchProductID] forKey:(NSString *)CFSTR(kUSBProductID)];
    
    //  Add notification ports to runloop
    IONotificationPortRef notificationPort = IONotificationPortCreate(kIOMasterPortDefault);
    CFRunLoopSourceRef notificationRunLoopSource = IONotificationPortGetRunLoopSource(notificationPort);
    CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], notificationRunLoopSource, kCFRunLoopDefaultMode);
    
    kern_return_t err;
    err = IOServiceAddMatchingNotification(notificationPort,
                                           kIOMatchedNotification,
                                           (__bridge CFDictionaryRef)matchingDict,
                                           usbDeviceAppeared,
                                           (__bridge void *)self,
                                           &newDevicesIterator);
    if (err)
    {
        NSLog(@"error adding publish notification");
    }
    [self matchingDevicesAdded: newDevicesIterator];
    
    
    NSMutableDictionary *matchingDictRemoved = (__bridge NSMutableDictionary *)IOServiceMatching(kIOUSBDeviceClassName);
    
    if (matchingDictRemoved == nil){
        NSLog(@"Could not create matching dictionary");
        return;
    }
    [matchingDictRemoved setObject:[NSNumber numberWithShort:matchVendorID] forKey:(NSString *)CFSTR(kUSBVendorID)];
    [matchingDictRemoved setObject:[NSNumber numberWithShort:matchProductID] forKey:(NSString *)CFSTR(kUSBProductID)];
    
    
    err = IOServiceAddMatchingNotification(notificationPort,
                                           kIOTerminatedNotification,
                                           (__bridge CFDictionaryRef)matchingDictRemoved,
                                           usbDeviceDisappeared,
                                           (__bridge void *)self,
                                           &lostDevicesIterator);
    if (err)
    {
        NSLog(@"error adding removed notification");
    }
    [self matchingDevicesRemoved: lostDevicesIterator];
    
    
    //      CFRunLoopRun();
    //      [[NSRunLoop currentRunLoop] run];
    
}

#pragma mark -
#pragma mark ObjC Callback functions
#pragma mark -

- (void)matchingDevicesAdded:(io_iterator_t)devices
{
    io_object_t thisObject;
    while ( (thisObject = IOIteratorNext(devices))) {
        NSLog(@"new Matching device added ");
        IOObjectRelease(thisObject);
    }
    [self enumerate];
}


- (void)matchingDevicesRemoved:(io_iterator_t)devices
{
    io_object_t thisObject;
    while ( (thisObject = IOIteratorNext(devices))) {
        NSLog(@"A matching device was removed ");
        IOObjectRelease(thisObject); 
    } 
    [self enumerate];
}

@end
