//
//  NSPasteboardItem+additions.h
//  Tea Box
//
//  Created by Max on 01/11/12.
//  Copyright (c) 2012 Lis@cintosh. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSPasteboardItem (additions)

- (NSURL *)fileURL;
- (NSString *)filePath;

@end
