//
//  NSMutableString+additions.m
//  test
//
//  Created by Max on 24/10/12.
//  Copyright (c) 2012 Lis@cintosh. All rights reserved.
//

#import "NSMutableString+additions.h"

@implementation NSMutableString (additions)

- (void)enumerateOccurencesOfStringBeginningWith:(NSString *)startString
									  endingWith:(NSString *)endingStringOrOption
										  option:(Option)option
									  usingBlock:(void (^)(NSMutableString * mutableOccurence, NSRange range))block
{
	NSString * endString = endingStringOrOption;
	if ([endingStringOrOption isEqualToString:kEndingStringLikeStartingString])
		endString = startString;
	
	NSInteger currentIndex = 0;
	NSInteger length = self.length;
	
	do {
		NSRange remainingRange = NSMakeRange(currentIndex, length - currentIndex);
		NSRange startRange = [self rangeOfString:startString
										 options:0
										   range:remainingRange];
		if (startRange.location == NSNotFound)// If (no strings found, we reach the end of the string, break the loop
			break;
		
		if (option == OptionStartAtLineBeginning) {
			/* The string begins at the start of a line only if it's on the first character of the string OR if the character before the occurence is a line break */
			BOOL startAtLineBeggining = (startRange.location == 0 || [[self substringWithRange:NSMakeRange(startRange.location - 1, 1)] isEqualToString:@"\n"]);
			if (!startAtLineBeggining) {
				break;
			}
		}
		
		NSRange endRange;
		if ([endingStringOrOption isEqualToString:kEndingStringWhiteSpaceOrLineBreak]) {
			NSRange endRangeForWhiteSpace = [self rangeOfString:kEndingStringWhiteSpace
														options:0
														  range:NSMakeRange(startRange.location + endString.length,
																			length - startRange.location - endString.length)];
			NSRange endRangeForLineBreak = [self rangeOfString:kEndingStringLineBreak
													   options:0
														 range:NSMakeRange(startRange.location + endString.length,
																		   length - startRange.location - endString.length)];
			
			endRange.location = MIN(endRangeForWhiteSpace.location, endRangeForLineBreak.location);
			endRange.length = 1;
			
			if (endRange.location == NSNotFound)// If no strings found, we have reached the end of the string but, in this case (looking for " " and "\n"), the end of the string is also a valid ending option
				endRange.location = length;
			
		} else if ([endingStringOrOption isEqualToString:kEndingStringLineBreak]) {
			endRange = [self rangeOfString:endString
								   options:0
									 range:NSMakeRange(startRange.location + endString.length,
													   length - startRange.location - endString.length)];
			
			if (endRange.location == NSNotFound)// As below, the end of the string is like a line break
				endRange.location = length;
			
		} else {
			endRange = [self rangeOfString:endString
								   options:0
									 range:NSMakeRange(startRange.location + endString.length,
													   length - startRange.location - endString.length)];
			if (endRange.location == NSNotFound)// If no strings found, we have reached the end of the string, there no more to find, quit the method
				return;
		}
		
		NSInteger substringLength = (endRange.location - startRange.location - startString.length);
		if (substringLength > 0) {// If we don't have an empty string, make modification and call the block
			
			NSRange range = NSMakeRange(startRange.location + startString.length, substringLength);
			
			if ([endingStringOrOption isEqualToString:kEndingStringLikeStartingString]) {
				[self deleteCharactersInRange:NSMakeRange(range.location + substringLength, startString.length)];
			} else if (![endingStringOrOption isEqualToString:kEndingStringLineBreak] &&
					   ![endingStringOrOption isEqualToString:kEndingStringWhiteSpace] && 
					   ![endingStringOrOption isEqualToString:kEndingStringWhiteSpaceOrLineBreak]) {
				[self deleteCharactersInRange:NSMakeRange(range.location + substringLength, endingStringOrOption.length)];
			}
			
			[self deleteCharactersInRange:NSMakeRange(range.location - startString.length, startString.length)];
			
			NSRange newRange = NSMakeRange(startRange.location, substringLength);
			NSMutableString * mutableOccurence = [[self substringWithRange:newRange] mutableCopy];
			
			/* Use synchrone block call but it's not possible to call synchrone block with no arguments so call the block as asynchrone block than call an empty synchrone block into the same queue. */
			dispatch_queue_t queue = dispatch_queue_create("com.lisacintosh.test.queue", NULL);
			dispatch_async(queue, ^{
				block(mutableOccurence, newRange);
			});
			dispatch_sync(queue, ^{ });
			dispatch_release(queue);
			
			[self replaceCharactersInRange:newRange withString:mutableOccurence];
			
			length = self.length;
		}
		
		currentIndex = endRange.location + endRange.length - startString.length;
	} while (currentIndex <= length);
}

@end
