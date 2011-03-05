//
//  EventBasedDHTMLPrettyPrinter.m
//  AquaPath
//
//  Created by Todd Ditchendorf on 10/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "EventBasedDHTMLPrettyPrinter.h"


@interface EventBasedDHTMLPrettyPrinter ( Private )

- (void)doParse:(NSData *)data;
- (NSString *)contentsOfResourceWithName:(NSString *)name
								  ofType:(NSString *)type;
- (void)handleAttrs:(NSDictionary *)attrs;
- (void)callbackDelegate;

- (NSMutableString *)prettyString;
- (void)setPrettyString:(NSMutableString *)newString;

@end


@implementation EventBasedDHTMLPrettyPrinter

#pragma mark -

- (id)initWithDelegate:(id)aDelegate;
{
	self = [super init];
	if (self) {
		[self setDelegate:aDelegate];
	}
	return self;
}


- (void)dealloc 
{
	[self setDelegate:nil];
	[self setPrettyString:nil];
	[super dealloc];
}


#pragma mark -
#pragma mark Public

- (void)parseXMLString:(NSString *)XMLString;
{	
	[self setPrettyString:[NSMutableString string]];
	
	NSData *data = [XMLString dataUsingEncoding:NSUTF8StringEncoding];

	[NSThread detachNewThreadSelector:@selector(doParse:)
							 toTarget:self
						   withObject:data];
	
}


#pragma mark -
#pragma mark Private

- (void)doParse:(NSData *)data;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
	[parser setDelegate:self];
	[parser parse];
	
	[pool release];
}


- (NSString *)contentsOfResourceWithName:(NSString *)name
								  ofType:(NSString *)type;
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource:name ofType:type];
    NSURL *furl = [NSURL fileURLWithPath:path];
	return [NSString stringWithContentsOfURL:furl encoding:NSUTF8StringEncoding error:nil];
}


- (void)handleAttrs:(NSDictionary *)attrs;
{
	NSString *attrFormat = [self contentsOfResourceWithName:@"attr"
													 ofType:@"html"];
	
	NSString *attrName;
	NSString *attrValue;
	NSEnumerator *e = [attrs keyEnumerator];
	while (attrName = [e nextObject]) {
		attrValue = [attrs objectForKey:attrName];
		[prettyString appendFormat:attrFormat,attrName,attrValue];
	}
	
}


- (void)callbackDelegate;
{
	[[self delegate] performSelectorOnMainThread:@selector(prettyPrinterDidFinishParsing:)
									  withObject:prettyString
								   waitUntilDone:NO];
}


#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser;
{
	NSString *header = [self contentsOfResourceWithName:@"prettyPrintStart"
												 ofType:@"html"];

	[prettyString appendString:header];
}


- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
	//NSLog(@"prettyPrinter didEndDocument");
	NSString *footer = [self contentsOfResourceWithName:@"prettyPrintEnd"
												 ofType:@"html"];
	
	[prettyString appendString:footer];
	[self callbackDelegate];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
										namespaceURI:(NSString *)namespaceURI 
									   qualifiedName:(NSString *)qName 
										  attributes:(NSDictionary *)attrs;
{
	NSString *openStartTagFormat = [self contentsOfResourceWithName:@"openStartTag"
															 ofType:@"html"];
	NSString *closeStartTagStr	 = [self contentsOfResourceWithName:@"closeStartTag"
															 ofType:@"html"];
	[prettyString appendFormat:openStartTagFormat,@"",elementName];
	[self handleAttrs:attrs];
	[prettyString appendFormat:closeStartTagStr,elementName];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
									  namespaceURI:(NSString *)namespaceURI 
								     qualifiedName:(NSString *)qName;
{
	NSString *endTagFormat = [self contentsOfResourceWithName:@"endTag"
													   ofType:@"html"];
	[prettyString appendFormat:endTagFormat,elementName];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
	[prettyString appendString:string];
}


#pragma mark -
#pragma mark Accessor methods

- (id)delegate;
{
	return delegate;
}


- (void)setDelegate:(id)newDelegate;
{
	if (delegate != newDelegate) {
		[delegate release];
		delegate = [newDelegate retain];
	}
}


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


@end
