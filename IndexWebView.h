//
//  IndexWebView.h
//  test
//
//  Created by Max on 24/10/12.
//  Copyright (c) 2012 Lis@cintosh. All rights reserved.
//

#import <WebKit/WebKit.h>

@class IndexWebView;
@protocol IndexWebViewDelegate <NSObject>

@optional
- (void)indexWebView:(IndexWebView *)indexWebView didSelectLinkedStepWithName:(NSString *)stepName;
- (void)indexWebView:(IndexWebView *)indexWebView didClickOnLink:(NSURL *)webURL;

- (void)indexWebViewDidDoubleClickOnBackground:(IndexWebView *)indexWebView;

- (BOOL)indexWebView:(IndexWebView *)indexWebView shouldDragFile:(NSString *)path dragOperation:(NSDragOperation)operation;
- (void)indexWebView:(IndexWebView *)indexWebView didDragFile:(NSString *)path dragOperation:(NSDragOperation)operation;

@end

@interface IndexWebView : WebView
{
	NSString * indexPath;
	NSArray * linkedSteps;
	
	NSDate * lastModificationDate;
}

@property (nonatomic, strong) NSObject <IndexWebViewDelegate> * delegate;
@property (nonatomic, readonly) int contentHeight;

- (void)loadIndexAtPath:(NSString *)path;
- (BOOL)loadIndexAtURL:(NSURL *)indexURL;

- (void)saveIndexAtPath:(NSString *)path;
- (void)saveIndexAtURL:(NSURL *)indexURL;

@end
