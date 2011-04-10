//
//  AquaPathDocument.m
//  XPath Finder
//
//  Created by Todd Ditchendorf on 1/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "APDocument.h"
#import "APWindowController.h"


@interface APDocument ( Private ) 


@end


@implementation APDocument

#pragma mark -

- (id)init 
{
	self = [super init];
	if (self != nil) {
		source = @"";
	}
	return self;
}


- (void)dealloc 
{
	self.source = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark NSDocument methods

- (void)makeWindowControllers;
{
	controller = [[[APWindowController alloc] initWithWindowNibName:@"APDocumentWindow"] autorelease];
	[self addWindowController:controller];
}


- (NSData *)dataRepresentationOfType:(NSString *)type 
{
    return [source dataUsingEncoding:NSUTF8StringEncoding];
}


- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper 
					 ofType:(NSString *)typeName 
					  error:(NSError **)outError
{
	[[controller window] setTitle:[fileWrapper filename]];
	self.source = [[[NSString alloc] initWithData:[fileWrapper regularFileContents] encoding:NSUTF8StringEncoding] autorelease];
    return YES;
	
}

@synthesize source;
@end
