//
//  XSLTBasedDHTMLPrettyPrinter.h
//  AquaPath
//
//  Created by Todd Ditchendorf on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XSLTBasedDHTMLPrettyPrinter : NSObject {
}

- (NSString *)prettyStringForDocument:(NSXMLDocument *)doc
					highlightingNodes:(NSArray *)sequence
						  contextPath:(NSString *)path;

@end
