//
//  AquaPathController.m
//  XPath Finder
//
//  Created by Todd Ditchendorf on 1/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AquaPathController.h"
#import "AquaPathDocument.h"
#import "XPathService.h"
#import "XPathServiceNSXMLImpl.h"
#import <WebKit/WebKit.h>


@interface AquaPathController ( Private )

- (void)registerForNotifications;
- (void)textDidChange:(NSNotification *)n;
- (void)viewBoundsChanged:(NSNotification *)n;
- (void)scrollGutter;
- (void)configureGutter;
- (int)numberOfLinesInTextView:(NSTextView *)aTextView;
- (NSMutableAttributedString *)attributedStringFromString:(NSString *)str;
- (void)makeTextViewScrollHorizontally:(NSTextView *)textView 
					  withinScrollView:(NSScrollView *)scrollView;
- (void)syntaxHighlight:(NSMutableAttributedString *)source 
		 withAttributes:(NSMutableDictionary *)attrs;
- (void)showEvalCompleted:(NSString *)statusString;
- (NSString *)formattedDescriptionForArray:(NSArray *)array;
- (AquaPathDocument *)AquaPathDocument;

- (DOMElement *)getFirstAncestorOrSelfOfNode:(DOMNode *)target
								 byClassName:(NSString *)className;

@end


@implementation AquaPathController

#pragma mark -

- (id)initWithWindowNibName:(NSString *)name;
{
	self = [super initWithWindowNibName:name];
	if (self != nil) {
		XPathService = [[XPathServiceNSXMLImpl alloc] initWithDelegate:self];
		monacoFont = [[NSFont fontWithName:@"Monaco" size:11] retain];
	}
	return self;
}


- (void)dealloc;
{
	[self setSource:nil];
	[self setResults:nil];
	[self setStatusText:nil];
	[XPathService release];
	[monacoFont release];
	[super dealloc];
}


#pragma mark -
#pragma mark NSWindowController methods

- (void)windowDidLoad;
{
	[self makeTextViewScrollHorizontally:sourceView 
						withinScrollView:sourceScrollView];
	[self makeTextViewScrollHorizontally:resultView
						withinScrollView:resultScrollView];
	
	[self registerForNotifications];
	[self configureGutter];
}


#pragma mark -
#pragma mark Actions

- (IBAction)selectPath:(id)sender;
{
	[pathField selectText:sender];
}


- (IBAction)evaluate:(id)sender;
{
	NSString *XPath = [pathField stringValue];
	NSString *XMLString = [[self AquaPathDocument] source];
	NSString *contextPath = [contextField stringValue];
	
	if (![XPath length] || ![XMLString length]) {
		NSBeep();
		return;
	}
	
	[self clear:self];
	[evalButton setState:NSOffState];
	[progressIndicator startAnimation:self];
	
	[XPathService evaluateInNewThread:XPath
						againstSource:XMLString
					  withContextPath:contextPath];
}


- (IBAction)clear:(id)sender;
{
	[self setResults:nil];
	[[webView mainFrame] loadHTMLString:@"<html/>" baseURL:nil];
	[self setStatusText:@""];
}


- (IBAction)setContextPath:(id)sender;
{
	NSString *XPath = [((NSMenuItem *)sender) representedObject];
	[contextField setStringValue:XPath];
}


- (IBAction)switchTab:(id)sender;
{
	[tabView selectTabViewItemAtIndex:[sender tag]];
}


#pragma mark -
#pragma mark XPathServiceDelegate methods

- (void)resultSequence:(NSArray *)sequence 
		  prettyString:(NSString *)prettyString
	  fromXPathService:(id <XPathService>)service;
{
	NSLog(@"received success");
	NSString *statusString = [NSString stringWithFormat:
		@"Sequence length: %i",
		[[NSNumber numberWithInt:[sequence count]] intValue]];
		
	NSString *sequenceStr = [self formattedDescriptionForArray:sequence];
	[self setResults:[self attributedStringFromString:sequenceStr]];
	
	[[webView mainFrame] loadHTMLString:prettyString
								baseURL:nil];

	[self showEvalCompleted:statusString];
}


- (void)error:(NSError *)err fromXPathService:(id <XPathService>)service;
{
	NSLog(@"received Error");
	NSString *statusString = [NSString stringWithFormat:
		@"Error: %@",
		[err localizedDescription]];

	[self showEvalCompleted:statusString];
	NSBeep();
}


#pragma mark -
#pragma mark WebUIDelegate methods

- (NSArray *)webView:(WebView *)sender 
contextMenuItemsForElement:(NSDictionary *)dict 
	defaultMenuItems:(NSArray *)defaultMenuItems
{
	DOMNode *node = [dict objectForKey:WebElementDOMNodeKey];
	if (!node) {
		return nil;
	}
	DOMElement *el = [self getFirstAncestorOrSelfOfNode:node byClassName:@"us-dalo-node-wrap"];
	NSString *XPath = [el getAttribute:@"xpath"];
	NSString *title = [NSString stringWithFormat:@"Set as Context Node (%@)",XPath];
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
												 action:@selector(setContextPath:) 
										  keyEquivalent:@""];
	[item setTarget:self];
	[item setRepresentedObject:XPath];
	return [NSArray arrayWithObject:item];
}


#pragma mark -
#pragma mark Private

- (void)registerForNotifications;
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textDidChange:)
												 name:NSTextDidChangeNotification
											   object:sourceView];
	
	[[sourceScrollView contentView] setPostsBoundsChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(viewBoundsChanged:)
												 name:NSViewBoundsDidChangeNotification
											   object:[sourceScrollView contentView]];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(viewBoundsChanged:)
												 name:NSWindowDidResizeNotification
											   object:[self window]];
}


- (void)textDidChange:(NSNotification *)n;
{
	int sourceLines = [self numberOfLinesInTextView:sourceView];
	int gutterLines = [self numberOfLinesInTextView:gutterView];
	 
	//NSLog(@"source: %i, gutter: %i",sourceLines, gutterLines);
	if (sourceLines != (gutterLines-1)) {
		//NSLog(@"in");
		NSMutableString *s = [NSMutableString string];
		int i;
		for (i = 0; i <= sourceLines; i++) {
			[s appendFormat:@"%d\n",i+1];
		}
		[gutterView setString:s];
	}
}


- (int)numberOfLinesInTextView:(NSTextView *)aTextView;
{
	NSString *s = [aTextView string];
	unsigned numberOfLines, index, stringLength = [s length];
	
	for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++) {
		index = NSMaxRange([s lineRangeForRange:NSMakeRange(index, 0)]);		
	}
	
	return numberOfLines;
}


- (void)viewBoundsChanged:(NSNotification *)n;
{
	[self scrollGutter];
}


- (void)scrollGutter;
{
	NSClipView *clipView = [sourceScrollView contentView];
	NSPoint p = [clipView bounds].origin;
//	NSLog(@"scrollGutter");
	p.x = 0;
	p.y -= sourceViewOffset;
	[[gutterScrollView contentView] scrollToPoint:p];
	[gutterView setNeedsDisplay:YES];
	[gutterScrollView setNeedsDisplay:YES];
	[[gutterScrollView contentView] setNeedsDisplay:YES];
	//NSLog(@"boundsChanged: %f, %f",p.x,p.y);
}


- (void)configureGutter;
{
	sourceViewOffset 
		= [[sourceScrollView contentView] bounds].origin.y - [[[self window] contentView] bounds].origin.y;
	[gutterView setAlignment:NSRightTextAlignment];
	[gutterView setString:@"1"];
	[gutterView setFont:monacoFont];
	[gutterView setBackgroundColor:[NSColor controlColor]];
	[self textDidChange:nil];
	[self scrollGutter];
	[[gutterScrollView contentView] setNeedsDisplay:YES];
}


- (NSMutableAttributedString *)attributedStringFromString:(NSString *)str;
{
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	[attrs setObject:monacoFont forKey:NSFontAttributeName];
	NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] initWithString:str
																			   attributes:attrs] autorelease];
	//[self syntaxHighlight:result withAttributes:attrs];
	return result;
}


- (void)makeTextViewScrollHorizontally:(NSTextView *)textView 
					  withinScrollView:(NSScrollView *)scrollView;
{
	[textView setFont:monacoFont];
	[scrollView setHasHorizontalScroller:YES];
	[textView setHorizontallyResizable:YES];
	[textView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
	[[textView textContainer] setContainerSize:NSMakeSize(MAXFLOAT, MAXFLOAT)];
	[[textView textContainer] setWidthTracksTextView:NO];	
	[textView setMaxSize:NSMakeSize(MAXFLOAT, MAXFLOAT)];
}


- (void)syntaxHighlight:(NSMutableAttributedString *)attrString 
		 withAttributes:(NSMutableDictionary *)attrs;
{
	NSScanner *scanner = [NSScanner scannerWithString:[attrString string]];
	
	[attrs setValue:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
	
	int start, end;
	while (![scanner isAtEnd]) {
		
		[scanner scanUpToString:@"<" intoString:nil];
		start = [scanner scanLocation];
		if (![scanner scanUpToString:@">" intoString:nil]) {
			break;
		}
		end = [scanner scanLocation] + 1;
		[attrString setAttributes:attrs range:NSMakeRange(start,end-start)];
		
	}
}


- (void)showEvalCompleted:(NSString *)statusString;
{
	[self setStatusText:statusString];
	[progressIndicator stopAnimation:self];
	[evalButton setState:NSOnState];
	[[NSSound soundNamed:@"Hero"] play];
}


- (NSString *)formattedDescriptionForArray:(NSArray *)array;
{
	NSMutableString *result = [NSMutableString string];
	
	id item;
	NSString *itemStringValue;
	NSMutableString *tmp;

	NSEnumerator *e = [array objectEnumerator];
	while (item = [e nextObject]) {
		if ([item isKindOfClass:[NSXMLNode class]]) {
			itemStringValue = [item stringValue];
		} else {
			itemStringValue = [item description];
		}
		tmp = [NSMutableString stringWithString:itemStringValue];
		
		[tmp replaceOccurrencesOfString:@"\n"
								withString:@" "
								   options:NSCaseInsensitiveSearch
									 range:NSMakeRange(0,[tmp length])];

		[result appendString:tmp];
		[result appendString:@"\n"];
	}

	return result;
}


- (DOMElement *)getFirstAncestorOrSelfOfNode:(DOMNode *)target
								 byClassName:(NSString *)className;
{
	DOMElement *el;
	NSString *value;
	NSRange r;
	do {
		if (DOM_ELEMENT_NODE == [target nodeType]) {
			el = (DOMElement *)target;
			value = [el getAttribute:@"class"];
			r = [value rangeOfString:className];
			if (r.length) {
				return el;
			}
		}
	} while (target = [target parentNode]);
	return nil;
}


- (AquaPathDocument *)AquaPathDocument;
{
	return (AquaPathDocument *)[self document];
}


#pragma mark -
#pragma mark Accessors

- (NSMutableAttributedString *)source;
{
	if (!source) {
		[self setSource:[self attributedStringFromString:[[self AquaPathDocument] source]]];
	}
	return source;
}


- (void)setSource:(NSMutableAttributedString *)newSource;
{
	if (source != newSource) {
		newSource = [[[NSMutableAttributedString alloc] initWithAttributedString:newSource] autorelease];
		[source autorelease];
		source = [newSource retain];

		[[self AquaPathDocument] setSource:[source string]];
	}
}


- (NSAttributedString *)results;
{
	return results;
}


- (void)setResults:(NSAttributedString *)newResults;
{
	if (results != newResults) {
		[results autorelease];
		results = [newResults retain];
	}
}


- (NSString *)statusText;
{
	return statusText;
}


- (void)setStatusText:(NSString *)newStatusText;
{
	if (statusText != newStatusText) {
		[statusText autorelease];
		statusText = [newStatusText retain];
	}
}

@end
