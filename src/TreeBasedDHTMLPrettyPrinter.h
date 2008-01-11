//
//  TreeBasedDHTMLPrettyPrinter.h
//  AquaPath
//
//  Created by Todd Ditchendorf on 10/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TreeBasedDHTMLPrettyPrinter : NSObject {
	NSMutableString *prettyString;
	NSArray *XPaths;
	NSString *contextPath;
}

- (NSString *)prettyStringForDocument:(NSXMLDocument *)doc
					highlightingNodes:(NSArray *)sequence
						  contextPath:(NSString *)path;

@end
