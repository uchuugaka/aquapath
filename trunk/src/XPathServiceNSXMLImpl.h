//
//  XPathServiceNSXMLImpl.h
//  XPath Finder
//
//  Created by Todd Ditchendorf on 1/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XPathService.h"

@class XSLTBasedDHTMLPrettyPrinter;


@interface XPathServiceNSXMLImpl : NSObject < XPathService > {
	id delegate;
	XSLTBasedDHTMLPrettyPrinter *prettyPrinter;
	
	NSArray *sequence;
	NSString *prettyString;
}

@end
