//
//  XBParserFactory.h
//  XBHttpClient
//
//  Created by Peter on 15/1/30.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBBaseParser.h"

@class XBParserFactory;

@protocol XBParserFactoryProtocol

@required

+ (id<XBParserFactoryProtocol> )sharedInstance;
- (id<XBParser>)parserWithURL:(NSString *)url;

@end

@interface XBParserFactory : NSObject <XBParserFactoryProtocol>
/**
 *  singleton
 *
 *  @return 解析类工厂方法
 */
+ (id <XBParserFactoryProtocol>)sharedInstance;

/**
 *  解析实体工厂方法,具体的实现可以由第三方开发者实现,override请
 覆盖父类实现[super parserWithURL:url]
 *
 *  @param url 请求的URL
 *
 *  @return 返回解析的实体
 */
- (id<XBParser>)parserWithURL:(NSString *)url;

@end
