//
//  XPathServiceNSXMLImpl.m
//  XPath Finder
//
//  Created by Todd Ditchendorf on 1/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "XPathServiceNSXMLImpl.h"
#import "XSLTBasedDHTMLPrettyPrinter.h"

static NSString *XPathKey = @"XPath";
static NSString *XMLStringKey = @"XMLString";
static NSString *ContextPathKey = @"ContextPath";


@interface XPathServiceNSXMLImpl ( Private )

- (void)doEvaluate:(NSDictionary *)userInfo;
- (NSXMLDocument *)documentFromXMLString:(NSString *)XMLString;
- (void)doSuccess;
- (void)doError:(NSString *)msg;

- (NSArray *)sequence;
- (void)setSequence:(NSArray *)newSequence;
- (NSString *)prettyString;
- (void)setPrettyString:(NSString *)newString;

@end


@implementation XPathServiceNSXMLImpl

#pragma mark - 

- (id)initWithDelegate:(id)aDelegate;
{
	self = [super init];
	if (self != nil) {
		[self setDelegate:aDelegate];
		prettyPrinter = [[XSLTBasedDHTMLPrettyPrinter alloc] init];
	}
	return self;
}


- (void) dealloc 
{
	[self setDelegate:nil];
	[self setSequence:nil];
	[self setPrettyString:nil];
	[prettyPrinter release];
	[super dealloc];
}


#pragma mark XPathService Methods

- (void)evaluateInNewThread:(NSString *)XPath 
			  againstSource:(NSString *)XMLString
			withContextPath:(NSString *)contextPath;
{

	[self setSequence:nil];
	[self setPrettyString:nil];

	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		XPath, XPathKey,
		XMLString, XMLStringKey,
		contextPath, ContextPathKey,
		nil];
	[NSThread detachNewThreadSelector:@selector(doEvaluate:)
							 toTarget:self 
						   withObject:userInfo];
}

#pragma mark - 
#pragma mark Private

- (void)doEvaluate:(NSDictionary *)userInfo;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *XPath		  = [userInfo objectForKey:XPathKey];
	NSString *XMLString   = [userInfo objectForKey:XMLStringKey];
	NSString *contextPath = [userInfo objectForKey:ContextPathKey];

	NSXMLDocument *doc = nil;
	@try {
		NSError *err = nil;
		doc = [self documentFromXMLString:XMLString];
		NSXMLNode *contextNode = doc;
		
		if ([contextPath length]) {
			NSArray *contextResult = [doc nodesForXPath:contextPath error:&err];
			if (![contextResult count]) {
				[NSException raise:@"XPathServiceException"
							format:@"Context Node Path returned the empty sequence '()'."];
			}
			if ([contextResult count] > 1) {
				[NSException raise:@"XPathServiceException"
							format:@"Must use a Context Node Path that returns a sequence containing a single node. Yours returned %i.",[contextResult count]];
			}
			
			contextNode = [contextResult objectAtIndex:0];
			
			if (!contextNode || err) {
				[NSException raise:@"XPathServiceException"
							format:@"Invalid Context Node Path."];
			}
		}
		
		[self setSequence:[contextNode objectsForXQuery:XPath error:&err]];
		//NSLog(@"result sequence : %@",[self sequence]);
		
		if (err) {
			[NSException raise:@"XPathServiceException"
						format:@"Invalid XPath Expression."];
		}
	} 
	@catch (NSException *e) {
		[self performSelectorOnMainThread:@selector(doError:) 
							   withObject:[e reason]
							waitUntilDone:NO];
		[pool release];
		return;
	}
	
	[self setPrettyString:[prettyPrinter prettyStringForDocument:doc 
											   highlightingNodes:[self sequence]
													 contextPath:contextPath]];

	[self performSelectorOnMainThread:@selector(doSuccess)
						   withObject:nil
						waitUntilDone:NO];
	
	[pool release];
}


- (NSXMLDocument *)documentFromXMLString:(NSString *)XMLString;
{
	NSXMLDocument *doc;
    NSError *err = nil;

    doc = [[[NSXMLDocument alloc] initWithXMLString:XMLString options:NSXMLDocumentTidyXML error:&err] autorelease];
    
    if (!doc)  {
		[NSException raise:@"XPathServiceException" format:@"Could not parse input XML"];
	}
	
	if (err) {
		[NSException raise:@"XPathServiceException" format:@"%@", [err localizedDescription]];
	}

	return doc;
}


- (void)doSuccess;
{
	[[self delegate] resultSequence:[self sequence]
					   prettyString:[self prettyString]
				   fromXPathService:self];
}


- (void)doError:(NSString *)msg;
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg
														 forKey:NSLocalizedDescriptionKey];
	NSError *err = [NSError errorWithDomain:@"XPathService" code:1 userInfo:userInfo];
	[[self delegate] error:err fromXPathService:self];
}


#pragma mark - 
#pragma mark Accessors

- (id)delegate;
{
	return delegate;
}


- (void)setDelegate:(id)aDelegate;
{
	if (delegate != aDelegate) {
		[delegate autorelease];
		delegate = [aDelegate retain];
	}
}


- (NSArray *)sequence;
{
	return sequence;
}


- (void)setSequence:(NSArray *)newSequence;
{
	if (sequence != newSequence) {
		[sequence autorelease];
		sequence = [newSequence retain];
	}
}


- (NSString *)prettyString;
{
	return prettyString;
}


- (void)setPrettyString:(NSString *)newString;
{
	if (prettyString != newString) {
		[prettyString autorelease];
		prettyString = [newString retain];
	}
}


@end
