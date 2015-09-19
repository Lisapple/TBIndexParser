//
//  IndexWebView.m
//  test
//
//  Created by Max on 24/10/12.
//  Copyright (c) 2012 Lis@cintosh. All rights reserved.
//

#import "IndexWebView.h"

#import "NSMutableString+additions.h"
#import "NSPasteboardItem+additions.h"

@implementation IndexWebView

@synthesize delegate = _delegate;
@dynamic contentHeight;

- (void)loadIndexAtPath:(NSString *)path
{
	[self loadIndexAtURL:[NSURL fileURLWithPath:path]];
}

- (BOOL)loadIndexAtURL:(NSURL *)indexURL
{
	if (!indexURL)
		return NO;
	
	/* Check if the file has been updated since the last loading */
	if (lastModificationDate) {
		NSDate * date = nil;
		[indexURL getResourceValue:&date forKey:NSURLContentModificationDateKey error:NULL];
		
		if ([lastModificationDate isEqualToDate:date]) {// If no changes have been made, don't reload
			return YES;
		} else {
			lastModificationDate = date;
		}
	} else {
        NSDate * date;
		[indexURL getResourceValue:&date forKey:NSURLContentModificationDateKey error:NULL];
        lastModificationDate = date;
	}
	
	NSMutableString * string = [[NSMutableString alloc] initWithContentsOfURL:indexURL
																 usedEncoding:nil
																		error:NULL];
	if (!string)
		return NO;
	
	/* Headers */
	[string enumerateOccurencesOfStringBeginningWith:@"###" endingWith:kEndingStringLineBreak option:OptionStartAtLineBeginning usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:@"<b style=\"font-size:1.17em\">" atIndex:0];
		[mutableOccurence appendString:@"</b>"];
	}];
	
	[string enumerateOccurencesOfStringBeginningWith:@"##" endingWith:kEndingStringLineBreak option:OptionStartAtLineBeginning usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:@"<b style=\"font-size:1.5em\">" atIndex:0];
		[mutableOccurence appendString:@"</b>"];
	}];
	
	[string enumerateOccurencesOfStringBeginningWith:@"#" endingWith:kEndingStringLineBreak option:OptionStartAtLineBeginning usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:@"<b style=\"font-size:2em\">" atIndex:0];
		[mutableOccurence appendString:@"</b>"];
	}];
	
	/* Text Format */
	[string enumerateOccurencesOfStringBeginningWith:@"*" endingWith:kEndingStringLikeStartingString option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:@"<b>" atIndex:0];
		[mutableOccurence appendString:@"</b>"];
	}];
	
	[string enumerateOccurencesOfStringBeginningWith:@"_" endingWith:kEndingStringLikeStartingString option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:@"<i>" atIndex:0];
		[mutableOccurence appendString:@"</i>"];
	}];
	
	[string enumerateOccurencesOfStringBeginningWith:@"~~" endingWith:kEndingStringLikeStartingString option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:@"<span style=\"text-decoration:line-through;\">" atIndex:0];
		[mutableOccurence appendString:@"</span>"];
	}];
	
	/* Web Links */
	[string enumerateOccurencesOfStringBeginningWith:@"@" endingWith:kEndingStringWhiteSpaceOrLineBreak option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:[NSString stringWithFormat:@"<a href=\"%@\">", mutableOccurence] atIndex:0];
		[mutableOccurence appendString:@"</a>"];
	}];
	
	/* Checkboxes */
	[string enumerateOccurencesOfStringBeginningWith:@"]" endingWith:kEndingStringLineBreak option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:@"] <span>" atIndex:0];// Re-add the "]" from the search
		[mutableOccurence insertString:@"</span>" atIndex:mutableOccurence.length];
	}];
	
	[string enumerateOccurencesOfStringBeginningWith:@"- [ ] " endingWith:kEndingStringLineBreak option:OptionStartAtLineBeginning usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:@"<input class=\"checkbox\" type=\"checkbox\"/>" atIndex:0];
	}];
	
	[string enumerateOccurencesOfStringBeginningWith:@"- [x] " endingWith:kEndingStringLineBreak option:OptionStartAtLineBeginning usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		[mutableOccurence insertString:@"<input class=\"checkbox\" type=\"checkbox\" checked/>" atIndex:0];
	}];
	
	/* Countdowns */
	[string enumerateOccurencesOfStringBeginningWith:@"}" endingWith:kEndingStringLineBreak option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		/* Look for "}" char to add "<span></span>" after it to draw a line through the string when the countdown is finished (if it's not a countdown, the "span" doesn't change the layout) */
		[mutableOccurence insertString:@"}<span>" atIndex:0];// Re-add the "}" from the search
		[mutableOccurence insertString:@"</span>" atIndex:mutableOccurence.length];
	}];
	
	[string enumerateOccurencesOfStringBeginningWith:@"{" endingWith:@"}" option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		NSArray * components = [mutableOccurence componentsSeparatedByString:@"/"];
		if (components.count == 2) {
			NSString * countString = (NSString *)components[0];
			NSString * finalCountString = components[1];
			
			NSInteger count, finalCount;
			if ([[NSScanner scannerWithString:countString] scanInteger:&count] &&
				[[NSScanner scannerWithString:finalCountString] scanInteger:&finalCount]) {
				NSString * string = [NSString stringWithFormat:@"<span class='countdown'><input type='button' class='up' value='+' onclick='increment(this);'/><input type='button' class='down' value='-' onclick='decrement(this);'/><span>%ld / %ld</span></span>", count, finalCount];
				[mutableOccurence replaceCharactersInRange:NSMakeRange(0, mutableOccurence.length)
												withString:string];
			}
		}
	}];
	
	/* Step Links */
	// @TODO: check if "[Step Name]" is on the same line than "- [ ]" or "- [x] or a countdown"
	// @TODO: if a countdown or a checkbox is finished, close the step and put it at the end of the list
	__block NSUInteger index = 0;
	NSMutableArray * _linkedSteps = [[NSMutableArray alloc] initWithCapacity:10];
	[string enumerateOccurencesOfStringBeginningWith:@"[" endingWith:@"]" option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		NSString * step = [mutableOccurence copy];
		[_linkedSteps addObject:step];
		
		[mutableOccurence insertString:[NSString stringWithFormat:@"&emsp;&emsp;<a href=\"step/%lu\">", index++]
							   atIndex:0];
		[mutableOccurence appendString:@"</a>"];
	}];
	linkedSteps = (NSArray *)_linkedSteps;
	
	[string replaceOccurrencesOfString:@"\n" withString:@"<br>\n" options:0 range:NSMakeRange(0, string.length)];
	
	NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
	NSString * sourceHTML = [NSString stringWithContentsOfFile:htmlPath
													  encoding:NSUTF8StringEncoding
														 error:NULL];
	self.UIDelegate = nil;
	self.resourceLoadDelegate = nil;
	
	self.mainFrame.frameView.allowsScrolling = NO;
	[self.mainFrame stopLoading];
	[self.mainFrame loadHTMLString:[sourceHTML stringByReplacingOccurrencesOfString:@"{{@}}" withString:string]
						   baseURL:nil];
	
	self.UIDelegate = self;
	self.resourceLoadDelegate = self;
	
	return YES;
}

- (int)contentHeight
{
	WebFrame * frame = self.mainFrame;
	DOMElement * document = frame.DOMDocument.documentElement;
	return document.offsetHeight;
}

#pragma mark - WebView Drag & Drop -

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
	BOOL shouldDrag = YES;
	if ([_delegate respondsToSelector:@selector(indexWebView:shouldDragFile:dragOperation:)]) {
		NSArray * items = [sender draggingPasteboard].pasteboardItems;
		if (items.count == 1) {
			NSPasteboardItem * item = items[0];
			shouldDrag = [_delegate indexWebView:self shouldDragFile:item.filePath dragOperation:[sender draggingSourceOperationMask]];
		}
	}
	return shouldDrag;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
	if ([_delegate respondsToSelector:@selector(indexWebView:didDragFile:dragOperation:)]) {
		NSArray * items = [sender draggingPasteboard].pasteboardItems;
		if (items.count == 1) {
			NSPasteboardItem * item = items[0];
			[_delegate indexWebView:self didDragFile:item.filePath dragOperation:[sender draggingSourceOperationMask]];
		}
	}
	return YES;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender { }

#pragma mark - WebView UI Delegate -

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
	if (request.URL.fileURL || [request.URL.absoluteString isEqualToString:@"about:blank"])
		return nil;
	
	return request;
}

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
	if (![request.URL.relativeString isEqualToString:@"about:blank"]) {// For other links than "about:blank"
		/* URL looks like "applewebdata://XXX-XXX-XXX/www.example.com/search/query?q=test", remove unused part */
		NSMutableArray * components = [[request.URL.relativeString componentsSeparatedByString:@"/"] mutableCopy];
		if (components.count > 3) {
			[components removeObjectsInRange:NSMakeRange(0, 3)];
			
			if (components.count == 2 && [components[0] isEqualToString:@"step"]) {
				NSInteger step = -1;
				if ([[NSScanner scannerWithString:components[1]] scanInteger:&step]) {
					NSString * stepName = linkedSteps[step];
					if ([self.delegate respondsToSelector:@selector(indexWebView:didSelectLinkedStepWithName:)])
						[self.delegate indexWebView:self didSelectLinkedStepWithName:stepName];
				}
			} else {
				NSString * urlString = [components componentsJoinedByString:@"/"];
				if (urlString.length > 7 && [urlString rangeOfString:@"http://"].location == NSNotFound)
					urlString = [@"http://" stringByAppendingString:urlString];
				
				NSURL * webURL = [NSURL URLWithString:urlString];
				if ([self.delegate respondsToSelector:@selector(indexWebView:didClickOnLink:)])
					[self.delegate indexWebView:self didClickOnLink:webURL];
			}
		}
	}
	
	NSString * identifier = request.URL.host;
	return (identifier)? identifier : request;
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	return @[];
}

- (void)saveIndexAtPath:(NSString *)path
{
	[self saveIndexAtURL:[NSURL fileURLWithPath:path]];
}

- (void)saveIndexAtURL:(NSURL *)indexURL
{
	if (!indexURL)
		return ;
	
	/* Checkboxes */
	DOMNodeList * checkboxList = [self.mainFrame.DOMDocument getElementsByClassName:@"checkbox"];
	BOOL * checkboxes = (BOOL *)malloc((int)checkboxList.length * sizeof(BOOL));
	for (int i = 0; i < checkboxList.length; i++) {
		DOMHTMLInputElement * checkbox = (DOMHTMLInputElement *)[checkboxList item:i];
		checkboxes[i] = checkbox.checked;
	}
	
	NSMutableString * string = [[NSMutableString alloc] initWithContentsOfURL:indexURL usedEncoding:nil error:NULL];
	__block NSInteger index = 0;
	[string enumerateOccurencesOfStringBeginningWith:@"- [" endingWith:@"] " option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		NSString * newString = [NSString stringWithFormat:@"- [%@] ", (checkboxes[(int)index++])? @"x" : @" "];
		[mutableOccurence replaceCharactersInRange:NSMakeRange(0, 1) withString:newString];
	}];
	
	/* Countdowns */
	DOMNodeList * countdownList = [self.mainFrame.DOMDocument getElementsByClassName:@"countdown"];
	NSMutableArray * countdowns = [NSMutableArray arrayWithCapacity:countdownList.length];
	for (int i = 0; i < countdownList.length; i++) {
		DOMNode * countdownNode = [countdownList item:i];
		DOMNode * node = [countdownNode.childNodes item:2];// Skip the first two nodes (inputs for in/decrement), get the third
		[countdowns addObject:node.textContent];
	}
	
	index = 0;
	[string enumerateOccurencesOfStringBeginningWith:@"{" endingWith:@"}" option:OptionNone usingBlock:^(NSMutableString *mutableOccurence, NSRange range) {
		NSArray * components = [mutableOccurence componentsSeparatedByString:@"/"];
		if (components.count == 2) {
			NSString * countString = components[0];
			NSString * finalCountString = components[1];
			
			NSInteger count, finalCount;
			if ([[NSScanner scannerWithString:countString] scanInteger:&count] &&
				[[NSScanner scannerWithString:finalCountString] scanInteger:&finalCount]) {
				if (index < countdowns.count) {
					NSString * string = [NSString stringWithFormat:@"{ %@ }", countdowns[index++]];
					[mutableOccurence replaceCharactersInRange:NSMakeRange(0, mutableOccurence.length)
													withString:string];
					return ;
				}
			}
		}
		
		/* In the default case, just re-add the "{" and "}" */
		NSString * newString = [NSString stringWithFormat:@"{ %@ }", mutableOccurence];
		[mutableOccurence replaceCharactersInRange:NSMakeRange(0, mutableOccurence.length)
										withString:newString];
	}];
	
	/* Save the file */
	[[string dataUsingEncoding:NSUTF8StringEncoding] writeToURL:indexURL atomically:YES];
}

@end
