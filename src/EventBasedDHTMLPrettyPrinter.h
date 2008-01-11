//
//  EventBasedDHTMLPrettyPrinter.h
//  AquaPath
//
//  Created by Todd Ditchendorf on 10/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EventBasedDHTMLPrettyPrinter : NSObject {
	id delegate;
	NSMutableString *prettyString;
}

- (id)initWithDelegate:(id)delegate;
- (void)parseXMLString:(NSString *)XMLString;

- (id)delegate;
- (void)setDelegate:(id)delegate;

@end

@interface NSObject ( EventBasedDHTMLPrettyPrinterDelegate )

- (void)prettyPrinterDidFinishParsing:(NSString *)prettyString;

@end

