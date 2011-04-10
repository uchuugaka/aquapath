//
//  APPrefsWindowController.m
//  AquaPath
//
//  Created by Todd Ditchendorf on 4/9/11.
//  Copyright 2011 Todd Ditchendorf. All rights reserved.
//

#import "APPrefsWindowController.h"

@implementation APPrefsWindowController

+ (APPrefsWindowController *)instance {
    static APPrefsWindowController *instance = nil;
    if (!instance) {
        instance = [[APPrefsWindowController alloc] initWithWindowNibName:@"APPrefsWindow"];
    }
    return instance;
}

@end
