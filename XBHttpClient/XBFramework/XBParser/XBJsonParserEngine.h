//
//  XBJsonParserEngine.h
//  XBHttpClient
//
//  Created by Peter on 15/1/30.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "XBBaseParser.h"

@class XBBaseParser;
@interface XBJsonParserEngine : NSObject
/**
 *  获取解析引擎
 *
 *  @return 拿到解析引擎单例实体
 */
+(XBJsonParserEngine *)sharedInstance;

/**
 *  递归解析
 *
 *  @param parseDict json返回的数据,类型必须为字典
 *  @param instance  解析反射的实例
 */
- (void)recursionParse:(NSDictionary *)parseDict instance:(XBBaseParser *)instance;

@end