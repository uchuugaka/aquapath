//
//  XPathService.h
//  XPath Finder
//
//  Created by Todd Ditchendorf on 1/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol XPathService < NSObject >

- (id)initWithDelegate:(id)aDelegate;

- (void)evaluateInNewThread:(NSString *)XPath 
			  againstSource:(NSString *)XMLString
			withContextPath:(NSString *)contextPath;

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

@end


@interface NSObject ( XPathServiceDelegate )

- (void)resultSequence:(NSArray *)sequence 
		  prettyString:(NSString *)prettyString
	  fromXPathService:(id <XPathService>)service;

- (void)error:(NSError *)err fromXPathService:(id <XPathService>)service;

@end