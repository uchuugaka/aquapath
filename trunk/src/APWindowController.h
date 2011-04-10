//
//  AquaPathController.h
//  XPath Finder
//
//  Created by Todd Ditchendorf on 1/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol XPathService;

@class WebView;


@interface APWindowController : NSWindowController {
	IBOutlet NSTextField *contextField;
	IBOutlet NSTextField *pathField;
	IBOutlet NSButton *evalButton;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *statusField;
	IBOutlet NSTabView *tabView;
	IBOutlet NSScrollView *sourceScrollView;
	IBOutlet NSScrollView *resultScrollView;
	IBOutlet NSTextView *sourceView;
	IBOutlet NSTextView *resultView;
	IBOutlet WebView *webView;
	IBOutlet NSTextView *gutterView;
	IBOutlet NSScrollView *gutterScrollView;
	
	NSMutableAttributedString *source;
	NSAttributedString *results;
	NSString *statusText;
	
	id <XPathService> XPathService;
	
	NSFont *monacoFont;
	float sourceViewOffset;
}

- (IBAction)selectPath:(id)sender;
- (IBAction)evaluate:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)setContextPath:(id)sender;
- (IBAction)switchTab:(id)sender;

- (NSMutableAttributedString *)source;
- (void)setSource:(NSMutableAttributedString *)newSource;
- (NSAttributedString *)results;
- (void)setResults:(NSAttributedString *)newResults;
- (NSString *)statusText;
- (void)setStatusText:(NSString *)newStatusText;

@end
