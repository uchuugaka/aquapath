//
//  TreeBasedDHTMLPrettyPrinter.m
//  AquaPath
//
//  Created by Todd Ditchendorf on 10/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TreeBasedDHTMLPrettyPrinter.h"
#import <WebKit/WebKit.h>


@interface TreeBasedDHTMLPrettyPrinter ( Private )

- (NSString *)contentsOfResourceWithName:(NSString *)name
								  ofType:(NSString *)type;

- (NSArray *)XPathsFromSequence:(NSArray *)sequence;

- (void)processNode:(NSXMLNode *)node;
- (void)handleDocumentNode:(NSXMLDocument *)doc;
- (void)handleStartDocument;
- (void)handleEndDocument;
- (void)handleElement:(NSXMLElement *)el;
- (void)handleStartElement:(NSXMLElement *)el;
- (void)handleEndElement:(NSXMLElement *)el;
- (void)handleAttrs:(NSArray *)attrs;
- (void)handleText:(NSXMLNode *)textNode;
- (void)handleComment:(NSXMLNode *)commentNode;
- (void)handlePI:(NSXMLNode *)piNode;
- (void)handleNamespaces:(NSArray *)namespaces;

- (NSMutableString *)prettyString;
- (void)setPrettyString:(NSMutableString *)newString;

- (NSArray *)XPaths;
- (void)setXPaths:(NSArray *)newXPaths;
- (NSString *)contextPath;
- (void)setContextPath:(NSString *)newPath;

@end


@implementation TreeBasedDHTMLPrettyPrinter

#pragma mark -

- (void)dealloc;
{
	[self setPrettyString:nil];
	[self setXPaths:nil];
	[self setContextPath:nil];
	[super dealloc];
}


#pragma mark -
#pragma mark Public

- (NSString *)prettyStringForDocument:(NSXMLDocument *)doc
					highlightingNodes:(NSArray *)sequence
						  contextPath:(NSString *)path;
{	
	[self setXPaths:[self XPathsFromSequence:sequence]];
	[self setPrettyString:[NSMutableString string]];
	[self setContextPath:path];
		
	[self handleStartDocument];
	[self processNode:doc];
	[self handleEndDocument];
	
	return [self prettyString];
}


#pragma mark -
#pragma mark Private

- (NSArray *)XPathsFromSequence:(NSArray *)sequence;
{
	NSMutableArray *result = [NSMutableArray array];
	id sequenceItem;
	NSEnumerator *e = [sequence objectEnumerator];
	while (sequenceItem = [e nextObject]) {
		if ([sequenceItem isKindOfClass:[NSXMLNode class]]) {
			[result addObject:[sequenceItem XPath]];
		}
	}
	return result;
}


- (void)processNode:(NSXMLNode *)node;
{
	switch ([node kind]) {
		case NSXMLDocumentKind:
			[self handleDocumentNode:(NSXMLDocument *)node];
			break;
		case NSXMLElementKind:
			[self handleElement:(NSXMLElement *)node];
			break;
		case NSXMLTextKind:
			[self handleText:node];
			break;
		case NSXMLCommentKind:
			[self handleComment:node];
			break;
		case NSXMLProcessingInstructionKind:
			[self handlePI:node];
			break;
	}
}


- (NSString *)contentsOfResourceWithName:(NSString *)name
								  ofType:(NSString *)type;
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource:name ofType:type];
    NSURL *furl = [NSURL fileURLWithPath:path];
	return [NSString stringWithContentsOfURL:furl encoding:NSUTF8StringEncoding error:nil];
}


- (void)handleDocumentNode:(NSXMLDocument *)doc;
{
	NSString *currXPath = [doc XPath];
	NSArray *rootPaths = [NSArray arrayWithObjects:@"/",@"",@".",@"//",currXPath,nil];
	
	BOOL isContextNode = [rootPaths containsObject:[self contextPath]];
	
	NSString *resourceName;
	
	if ([[self XPaths] containsObject:currXPath]) {
		if (isContextNode) {
			NSLog(@"document node is context node!");
			resourceName = @"bodyMatched"; // Context";
		} else {
			resourceName = @"bodyMatched";
		}
	} else {
		if (isContextNode) {
			NSLog(@"document node is context node!");
			resourceName = @"body"; // Context";
		} else {
			resourceName = @"body";
		}
	}
	NSString *bodyString = [self contentsOfResourceWithName:resourceName
													 ofType:@"html"];
	
	[prettyString appendString:bodyString];
	
	NSXMLNode *node;
	NSEnumerator *e = [[doc children] objectEnumerator];
	while (node = [e nextObject]) {
		[self processNode:node];
	}
	
}


- (void)handleStartDocument;
{
	NSString *header = [self contentsOfResourceWithName:@"prettyPrintStart"
												 ofType:@"html"];
	[prettyString appendString:header];
}


- (void)handleEndDocument;
{
	NSString *footer = [self contentsOfResourceWithName:@"prettyPrintEnd"
												 ofType:@"html"];
	
	[prettyString appendString:footer];
}


- (void)handleElement:(NSXMLElement *)el;
{
	[self handleStartElement:el];
	
	NSXMLNode *child;
	NSEnumerator *e = [[el children] objectEnumerator];
	while (child = [e nextObject]) {
		[self processNode:child];
	}
	[self handleEndElement:el];
}


- (void)handleStartElement:(NSXMLElement *)el;
{
	NSString *resourceName;
	NSString *currXPath = [el XPath];
	BOOL isContextNode = [[self contextPath] isEqualToString:currXPath];

	if ([[self XPaths] containsObject:currXPath]) {
		if (isContextNode) {
			resourceName = @"openStartTagMatched"; // Context";
		} else {
			resourceName = @"openStartTagMatched";
		}
	} else {
		if (isContextNode) {
			resourceName = @"openStartTag"; // Context";
		} else {
			resourceName = @"openStartTag";
		}
	}
	
	NSString *openStartTagFormat = [self contentsOfResourceWithName:resourceName
															 ofType:@"html"];
	
	NSString *closeStartTagStr	 = [self contentsOfResourceWithName:@"closeStartTag"
															 ofType:@"html"];
	[prettyString appendFormat:openStartTagFormat,[el XPath],[el name]];
	[self handleNamespaces:[el namespaces]];
		
	[self handleAttrs:[el attributes]];
	[prettyString appendFormat:closeStartTagStr,[el name]];
}


- (void)handleEndElement:(NSXMLElement *)el;
{
	NSString *endTagFormat = [self contentsOfResourceWithName:@"endTag"
													   ofType:@"html"];
	[prettyString appendFormat:endTagFormat,[el name]];
}


- (void)handleNamespaces:(NSArray *)namespaces;
{
	NSString *nsFormat = [self contentsOfResourceWithName:@"attr"
												   ofType:@"html"];
	NSXMLNode *ns;
	NSString *name;
	NSEnumerator *e = [namespaces objectEnumerator];
	while (ns = [e nextObject]) {
		name = [ns name];
		if (!name || 0 == [name length]) {
			name = @"xmlns";
		} else {
			name = [NSString stringWithFormat:@"xmlns:%@",name];
		}
		
		[prettyString appendFormat:nsFormat,[ns XPath],name,[ns stringValue]];	
	}	
}


- (void)handleAttrs:(NSArray *)attrs;
{
	NSString *attrFormat;
	NSString *resourceName;
	
	NSXMLNode *attr;
	NSEnumerator *e = [attrs objectEnumerator];
	NSString *currXPath;
	BOOL isContextNode;
	while (attr = [e nextObject]) {

		currXPath = [attr XPath];
		isContextNode = [[self contextPath] isEqualToString:currXPath];
		
		if ([[self XPaths] containsObject:currXPath]) {
			if (isContextNode) {
				resourceName = @"attrMatched"; // Context";
			} else {
				resourceName = @"attrMatched";
			}
		} else {
			if (isContextNode) {
				resourceName = @"attr"; // Context";
			} else {
				resourceName = @"attr";
			}
		}
		attrFormat = [self contentsOfResourceWithName:resourceName
											   ofType:@"html"];
		[prettyString appendFormat:attrFormat,[attr XPath],[attr name],[attr stringValue]];	
	}	
}


- (void)handleText:(NSXMLNode *)textNode;
{
	NSString *resourceName;
	
	NSString *currXPath = [textNode XPath];
	BOOL isContextNode = [[self contextPath] isEqualToString:currXPath];
	
	if ([[self XPaths] containsObject:currXPath]) {
		if (isContextNode) {
			resourceName = @"textMatched"; // Context";
		} else {
			resourceName = @"textMatched";
		}
	} else {
		if (isContextNode) {
			resourceName = @"text"; // Context";
		} else {
			resourceName = @"text";
		}
	}
	NSString *textFormat = [self contentsOfResourceWithName:resourceName
													 ofType:@"html"];
	[prettyString appendFormat:textFormat,[textNode XPath],[textNode stringValue]];
}


- (void)handleComment:(NSXMLNode *)commentNode;
{
	NSString *resourceName;
	
	NSString *currXPath = [commentNode XPath];
	BOOL isContextNode = [[self contextPath] isEqualToString:currXPath];
	
	if ([[self XPaths] containsObject:currXPath]) {
		if (isContextNode) {
			resourceName = @"commentMatched"; // Context";
		} else {
			resourceName = @"commentMatched";
		}
	} else {
		if (isContextNode) {
			resourceName = @"comment"; // Context";
		} else {
			resourceName = @"comment";
		}
	}
	
	NSString *commentFormat = [self contentsOfResourceWithName:resourceName
														ofType:@"html"];
	[prettyString appendFormat:commentFormat,[commentNode XPath],[commentNode stringValue]];	
}


- (void)handlePI:(NSXMLNode *)piNode;
{
	NSString *resourceName;
	
	NSString *currXPath = [piNode XPath];
	BOOL isContextNode = [[self contextPath] isEqualToString:currXPath];
		
	if ([[self XPaths] containsObject:currXPath]) {
		if (isContextNode) {
			resourceName = @"piMatched"; // Context";
		} else {
			resourceName = @"piMatched";
		}
	} else {
		if (isContextNode) {
			resourceName = @"pi"; // Context";
		} else {
			resourceName = @"pi";
		}
	}
	NSString *piFormat = [self contentsOfResourceWithName:resourceName
												   ofType:@"html"];
	[prettyString appendFormat:piFormat,[piNode XPath],[piNode stringValue]];	
}


#pragma mark -
#pragma mark Accessor methods

- (NSMutableString *)prettyString;
{
	return prettyString;
}


- (void)setPrettyString:(NSMutableString *)newString;
{
	if (prettyString != newString) {
		[prettyString release];
		prettyString = [newString retain];
	}
}


- (NSArray *)XPaths;
{
	return XPaths;
}


- (void)setXPaths:(NSArray *)newXPaths;
{
	if (XPaths != newXPaths) {
		[XPaths release];
		XPaths = [newXPaths retain];
	}
}


- (NSString *)contextPath;
{
	return contextPath;
}


- (void)setContextPath:(NSString *)newPath;
{
	if (contextPath != newPath) {
		[contextPath release];
		contextPath = [newPath retain];
	}
}


@end
