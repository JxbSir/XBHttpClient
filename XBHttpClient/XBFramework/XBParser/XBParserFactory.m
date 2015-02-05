//
//  XBParserFactory.m
//  XBHttpClient
//
//  Created by Peter on 15/1/30.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "XBParserFactory.h"

static XBParserFactory *xbParserFactory = nil;
@implementation XBParserFactory

#pragma mark -sharedInstance
+ (id <XBParserFactoryProtocol>)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xbParserFactory = [[XBParserFactory alloc] init];
    });
    return xbParserFactory;
}

#pragma mark -parserWithURL
- (id<XBParser>)parserWithURL:(NSString *)url {
    if ([url isEqualToString:@""]) {
        return nil;
    }
    XBBaseParser *xbParser = [[XBBaseParser alloc] init];
    return (id<XBParser>)xbParser;
}

@end
