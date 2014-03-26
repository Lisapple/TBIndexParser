//
//  NSMutableString+additions.h
//  test
//
//  Created by Max on 24/10/12.
//  Copyright (c) 2012 Lis@cintosh. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef kEndingString
#define kEndingString
#define kEndingStringWhiteSpace @" "
#define kEndingStringLineBreak @"\n"
#define kEndingStringLikeStartingString @""
#define kEndingStringWhiteSpaceOrLineBreak @"WSOLB"
#endif

enum _Option {
	OptionNone = 0,
	OptionStartAtLineBeginning
};
typedef enum _Option Option;

@interface NSMutableString (additions)

- (void)enumerateOccurencesOfStringBeginningWith:(NSString *)startString
									  endingWith:(NSString *)endingStringOrOption
										  option:(Option)option
									  usingBlock:(void (^)(NSMutableString * mutableOccurence, NSRange range))block;

@end
