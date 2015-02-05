//
//  XBJsonParserEngine.m
//  XBHttpClient
//
//  Created by Peter on 15/1/30.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "XBJsonParserEngine.h"
#import <QuartzCore/QuartzCore.h>

static XBJsonParserEngine *xbJsonParserEngine = nil;

@implementation XBJsonParserEngine

#pragma mark -sharedInstance
+(XBJsonParserEngine *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xbJsonParserEngine = [[XBJsonParserEngine alloc] init];
    });
    return xbJsonParserEngine;
}


#pragma mark -buildSetSelectorWithProperty
+ (SEL)buildSelectorWithProperty:(NSString *)property {
    NSString *propertySEL = [NSString stringWithFormat:@"set%@%@:",[property substringToIndex:1].uppercaseString,[property substringFromIndex:1]];
    SEL setSelector = NSSelectorFromString(propertySEL);
    return setSelector;
}

#pragma mark -recursionParse
- (void)recursionParse:(NSDictionary *)parseDict instance:(XBBaseParser *)xbInstance {
    NSArray *propertyArr = [xbInstance getPropertyArr];
    for (NSString *property in propertyArr) {
        NSObject *parserObject;
        NSString *mapperKey = [[xbInstance mapperKey] objectForKey:property];
        if (mapperKey.length > 0) {
            parserObject = [parseDict objectForKey:mapperKey];
        } else {
            parserObject = [parseDict objectForKey:property];
        }
        [self setValue:parserObject forProperty:property withInstance:xbInstance];
    }
}

#pragma mark -setValue
- (void)setValue:(NSObject *)value forProperty:(NSString *)property withInstance:(XBBaseParser *)xbInstance {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL setSEL = [[self class] buildSelectorWithProperty:property];
    if ([value isKindOfClass:[NSString class]]) {
        [xbInstance performSelector:setSEL withObject:value.description];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        [xbInstance performSelector:setSEL withObject:value];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        NSString *clsStr = [[xbInstance getModelTypeDict] objectForKey:property];
        Class cls = NSClassFromString(clsStr);
        
        XBBaseParser *subInstance = [[cls alloc] init];
        [subInstance setXMLParser:NO];
        [xbInstance performSelector:setSEL withObject:subInstance];
        
        // 递归到上一级
        [self recursionParse:(NSDictionary *)value instance:subInstance];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *dataArr = [NSMutableArray array];
        [xbInstance performSelector:setSEL withObject:dataArr];
        
        Class cls = NSClassFromString([[xbInstance getModelTypeDict] objectForKey:property]);
        if (cls) {
            // 元素是对象
            for (NSDictionary *parseDict in (NSArray *)value) {
                XBBaseParser *subInstance = [[cls alloc] init];
                [subInstance setXMLParser:NO];
                [dataArr addObject:subInstance];
                [self recursionParse:parseDict instance:subInstance];
            }
        } else {
            // 元素是基本类型
            for (NSObject *object in (NSArray *)value) {
                if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                    [dataArr addObject:object.description];
                }
            }
        }
    }
#pragma clang diagnostic pop
}
@end
