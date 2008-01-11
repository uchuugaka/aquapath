//
//  AquaPathDocument.h
//  XPath Finder
//
//  Created by Todd Ditchendorf on 1/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AquaPathController;


@interface AquaPathDocument : NSDocument {
	AquaPathController *controller;
	NSString *source;
}

- (NSString *)source;
- (void)setSource:(NSString *)newSource;

@end
