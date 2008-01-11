//
//  AquaPathDocument.m
//  XPath Finder
//
//  Created by Todd Ditchendorf on 1/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AquaPathDocument.h"
#import "AquaPathController.h"


@interface AquaPathDocument ( Private ) 


@end


@implementation AquaPathDocument

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
	[self setSource:nil];
	[super dealloc];
}


#pragma mark -
#pragma mark NSDocument methods

- (void)makeWindowControllers;
{
	controller = [[AquaPathController alloc] initWithWindowNibName:@"AquaPathWindow"];
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
	NSString *newSource = [[[NSString alloc] initWithData:[fileWrapper regularFileContents] 
												 encoding:NSUTF8StringEncoding] autorelease];
	[self setSource:newSource];
    return YES;
	
}



#pragma mark -
#pragma mark Accessors

- (NSString *)source;
{
	return source;
}


- (void)setSource:(NSString *)newSource;
{
	if (source != newSource) {
		[source autorelease];
		source = [newSource retain];
	}
}


@end
