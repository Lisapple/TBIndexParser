//
//  TBAppDelegate.m
//  TBIndexParserExample
//
//  Created by Max on 3/26/14.
//  Copyright (c) 2014 Lisacintosh. All rights reserved.
//

#import "TBAppDelegate.h"

@interface TBAppDelegate ()
{
	NSString * path;
}
@end

@implementation TBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	/* Load the example "markdown" text file from the bundle */
	path = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"txt"];
	[self.indexWebView loadIndexAtPath:path];
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
	/* Save modifications when the window resigns active */
	[self.indexWebView saveIndexAtPath:path];
}

@end
