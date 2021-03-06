//
//  Blink1.h
//  Blink1Control
//
//  Created by Tod E. Kurt on 9/6/12.
//  Copyright (c) 2012 ThingM. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <IOKit/usb/USBSpec.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#include <IOKit/usb/USB.h>

//typedef void (^UpdateHandler)(int someParameter);
typedef void (^UpdateHandler)(NSColor* lastColor, float lastTime);

@interface Blink1 : NSObject {
    NSColor* currentColor;
    NSTimer* timer;
    float time;
}

@property (strong) NSMutableArray* serialnums;
@property (strong) NSString* blink1_id;
@property (strong) NSString* host_id;
@property (strong) NSColor* lastColor;
@property (nonatomic, copy) UpdateHandler updateHandler;

- (NSMutableArray *) enumerate;

- (NSString*) regenerateBlink1Id;

-(bool)isHere;
-(void)setColor:(NSColor*)c;
-(void)setPulse:(NSColor*)c;
-(void)off;

- (void) fadeToRGB:(NSColor*) c atTime:(float) t;
- (void)fadeToRGBstr:(NSString*) hexcstr atTime:(float)t;

- (NSString*) lastColorHexString;

+ (NSColor *) colorFromInt: (unsigned int)colorCode;
+ (NSColor *) colorFromHexRGB:(NSString *) inColorString;
//+ (NSString*) toHexColorString: (NSColor*)colr;
+ (NSString*) hexStringFromColor: (NSColor*)colr;

- (void)matchingDevicesRemoved:(io_iterator_t)devices;
- (void)matchingDevicesAdded:(io_iterator_t)devices;

@end
