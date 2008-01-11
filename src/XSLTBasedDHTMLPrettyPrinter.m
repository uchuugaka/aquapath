//
//  XSLTBasedDHTMLPrettyPrinter.m
//  AquaPath
//
//  Created by Todd Ditchendorf on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XSLTBasedDHTMLPrettyPrinter.h"

static NSData *compiledStylesheet;

@interface XSLTBasedDHTMLPrettyPrinter (Private)
+ (void)compileXSLT;
@end

@implementation XSLTBasedDHTMLPrettyPrinter

+ (void)initialize;
{
	[self compileXSLT];
}


+ (void)compileXSLT;
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"prettyxml" ofType:@"xsl"];
	compiledStylesheet = [[NSData alloc] initWithContentsOfFile:path];
}


- (void)dealloc;
{
	
	[super dealloc];
}


#pragma mark -
#pragma mark Public

- (NSString *)prettyStringForDocument:(NSXMLDocument *)doc
					highlightingNodes:(NSArray *)sequence
						  contextPath:(NSString *)path;
{
	/*
	NSEnumerator *e = [sequence objectEnumerator];
	NSXMLNode *node;
	NSString *xpath;
	while (node = [e nextObject]) {
		xpath = [node XPath];
		NSXMLNode *n = [[doc objectsForXQuery:xpath error:nil] objectAtIndex:0];
		NSString *className = [n valueForKey:@"class"];
		[n setValue:[NSString stringWithFormat:@"%@ TOD_matchedNode", className] forKey:@"class"];
	}
	*/	
	id res = [doc objectByApplyingXSLT:compiledStylesheet
									arguments:nil
										error:nil];
	NSLog(@"res : %@", res);
	//NSLog(@"[res class] : %@", [res class]);
	return [res XMLString];
}

@end
