//
//  AquaPathDocument.h
//  XPath Finder
//
//  Created by Todd Ditchendorf on 1/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class APWindowController;

@interface APDocument : NSDocument {
	APWindowController *controller;
	NSString *source;
}

@property (nonatomic, copy) NSString *source;
@end
