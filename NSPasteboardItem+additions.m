//
//  NSPasteboardItem+additions.m
//  Tea Box
//
//  Created by Max on 01/11/12.
//  Copyright (c) 2012 Lis@cintosh. All rights reserved.
//

#import "NSPasteboardItem+additions.h"

@implementation NSPasteboardItem (additions)

- (NSURL *)fileURL
{
	NSString * fileURLString = [[NSString alloc] initWithData:[self dataForType:@"public.file-url"]
													 encoding:NSUTF8StringEncoding];
	return [NSURL URLWithString:fileURLString];
}

- (NSString *)filePath
{
	return [self fileURL].path;
}

@end
