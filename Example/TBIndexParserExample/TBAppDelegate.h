//
//  TBAppDelegate.h
//  TBIndexParserExample
//
//  Created by Max on 3/26/14.
//  Copyright (c) 2014 Lisacintosh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IndexWebView.h"

@interface TBAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet IndexWebView * indexWebView;

@end
