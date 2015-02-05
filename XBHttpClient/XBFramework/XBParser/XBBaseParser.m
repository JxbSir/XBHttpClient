//
//  XBBaseParser.m
//  XBHttpClient
//
//  Created by Peter on 15/1/30.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "XBBaseParser.h"
#import "XBJsonParserEngine.h"

#import <objc/runtime.h>

static char *kPropertyArr;
static char *kModelTypeDict;

@implementation XBBaseParser
@synthesize msg;
@synthesize code;
@synthesize isSuccess;

#pragma mark -isSuccess

-(BOOL) success
{
    return [isSuccess integerValue] == 0 ? NO: YES;
}

#pragma mark -getCode
- (NSString *)getCode
{
    return code;
}

#pragma mark -mapperKey
- (NSDictionary *)mapperKey {
    return @{};
}

#pragma mark -getPropertyArr
- (NSArray *)getPropertyArr {
    return objc_getAssociatedObject(self.class, &kPropertyArr);
}

#pragma mark -getModelTypeDict
- (NSDictionary *)getModelTypeDict {
    return objc_getAssociatedObject(self.class, &kModelTypeDict);
}

#pragma mark -setXMLParser
- (void)setXMLParser:(BOOL)isXMLParser {
    if (!isXMLParser && !objc_getAssociatedObject(self.class, &kPropertyArr)) {
        [self setUpJsonMapper];
    }
}

#pragma mark -setUpJsonMapper
- (void)setUpJsonMapper {
    NSMutableArray *propertyArr = [NSMutableArray array];
    NSMutableDictionary *modelTypeDict = [NSMutableDictionary dictionary];
    
    objc_setAssociatedObject(self.class, &kPropertyArr, propertyArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self.class, &kModelTypeDict, modelTypeDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    Class cls = self.class;
    while (cls != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            const char *nameOfProperty = property_getName(property);
            
            // 属性的字符串
            NSString *strOfProperty = [NSString stringWithUTF8String:nameOfProperty];
            [propertyArr addObject:strOfProperty];
            
            // 拆解分析属性获取
            const char *attributeOfProperty = property_getAttributes(property);
            NSString *strOfAttribute = [NSString stringWithUTF8String:attributeOfProperty];
            if ([strOfAttribute rangeOfString:@"&,N"].location != NSNotFound || [strOfAttribute rangeOfString:@"Array"].location != NSNotFound) {
                NSArray *componentsOfArr = [strOfAttribute componentsSeparatedByString:@"\""];
                
                // 分拆子一级属性
                if ([strOfAttribute rangeOfString:@"Array"].location != NSNotFound) {
                    NSString *analysizeTypeStr = [componentsOfArr objectAtIndex:1];
                    
                    unsigned int startLocation,endLocation;
                    NSScanner *typeStrScanner = [NSScanner scannerWithString:analysizeTypeStr];
                    
                    // 开始位置
                    [typeStrScanner scanUpToString:@"<" intoString:NULL];
                    startLocation = typeStrScanner.scanLocation+1;
                    
                    // 结束位置
                    [typeStrScanner scanUpToString:@">" intoString:NULL];
                    endLocation = typeStrScanner.scanLocation;
                    
                    // 拿取数组子类属性
                    NSString *typeStr = [analysizeTypeStr substringWithRange:NSMakeRange(startLocation, endLocation-startLocation)];
                    [modelTypeDict setObject:typeStr forKey:strOfProperty];
                } else {
                    [modelTypeDict setObject:[componentsOfArr objectAtIndex:1] forKey:strOfProperty];
                }
            }
        }
        free(properties);
        cls = [cls superclass];
    }
}

#pragma mark -parserBodyWithXML
- (void)parserBodyWithXML:(NSString *)xmlStr {
#warning  "No Completion"
}

#pragma mark -parserBodyWithJson
- (void)parserBodyWithJson:(NSDictionary *)jsonData {
    [[XBJsonParserEngine sharedInstance] recursionParse:jsonData instance:self];
}

@end