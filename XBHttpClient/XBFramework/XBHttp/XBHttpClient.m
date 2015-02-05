//
//  XBHttpClient.m
//  XBHttpClient
//
//  Created by Peter on 15/1/30.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "XBHttpClient.h"
#import "XBParserFactory.h"

@interface XBHttpClient()
{
    id<XBParserFactoryProtocol> pFactory;
}
@end

@implementation XBHttpClient

#pragma mark - setParserFactory
- (void)setParserFactory: (id<XBParserFactoryProtocol>)parserFactory
{
    pFactory = parserFactory;
}

#pragma mark - request
- (void)requestWithURL:(NSString *)url
                 paras:(NSDictionary *)parasDict
                  type:(XBHttpResponseType)type
               success:(void(^)(NSObject *resultObject))success
               failure:(void(^)(NSError *requestErr))failure
{
    /*
    // 加入允许读缓存则
    if ([[parasDict objectForKey:kHttpAllowFetchCache] boolValue]) {
        // check cache
        id cacheObj = [[OTHttpCache sharedInstance]fetchResponseForUrl:url byParam:parasDict];
        if (cacheObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(nil,cacheObj);
            });
            return;
        }
    }
    int allowSaveCache = [[parasDict objectForKey:kHttpAllowSaveCache] intValue];
     */
    // 检查是否是xml解析
    // 已指定何种格式解析，无需重复相同实例化，否则http多线程会引起内存问题
    if (type == XBHttpResponseType_XML) {
        if (![self.responseSerializer isMemberOfClass:[AFXMLParserResponseSerializer class]])
        {
            AFXMLParserResponseSerializer *xmlParserSerializer = [[AFXMLParserResponseSerializer alloc] init];
            self.responseSerializer = xmlParserSerializer;
        }
    }
    else if (type == XBHttpResponseType_Json) {
        if(![self.responseSerializer isMemberOfClass:[AFJSONResponseSerializer class]])
        {
            AFJSONResponseSerializer *jsonParserSerializer = [[AFJSONResponseSerializer alloc] init];
            self.responseSerializer = jsonParserSerializer;
        }
    }
    else {
        if (![self.responseSerializer isMemberOfClass:[AFHTTPResponseSerializer class]])
        {
            AFHTTPResponseSerializer *httpParserSerializer = [[AFHTTPResponseSerializer alloc] init];
            self.responseSerializer = httpParserSerializer;
        }
    }
    NSMutableDictionary *transferParas = [NSMutableDictionary dictionaryWithDictionary:parasDict];
    // 检查BaseURL
    NSString *requestURL = url;
    NSDictionary *baseParas = nil;
    // 添加共同的请求参数
    if (baseParas && baseParas.allKeys.count > 0) {
        [transferParas setValuesForKeysWithDictionary:baseParas];
    }
    // 开始请求
    __weak typeof(self) wSelf = self;
   [self POST:requestURL parameters:transferParas success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (!wSelf) {
            return ;
        }
        __strong typeof(wSelf) sSelf = wSelf;
#ifdef DEBUG
       if(type == XBHttpResponseType_Common)
       {
           responseObject = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
       }
        NSLog(@"url:%@\r\nbody:%@", url, responseObject);
#endif
        /*if (allowSaveCache == OTHttpCacheMemory || allowSaveCache == OTHttpCacheDisk) {
            [[OTHttpCache sharedInstance] storeResponse:responseObject forUrl:requestURL byParam:transferParas toDisk:allowSaveCache == OTHttpCacheMemory? NO:YES];
        }*/
        if ([operation.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
            // json解析
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                id<XBParser> parserObject = [sSelf->pFactory parserWithURL:url];
                [(XBBaseParser *)parserObject setXMLParser:NO];
                [parserObject parserBodyWithJson:responseObject];
                success(parserObject);
            }
        } else if ([operation.responseSerializer isKindOfClass:[AFXMLParserResponseSerializer class]]) {
            // xml解析
            id<XBParser> parserObject = [sSelf->pFactory parserWithURL:url];
            [(XBBaseParser *)parserObject setXMLParser:YES];
            [parserObject parserBodyWithXML:responseObject];
            success(parserObject);
        }
        else
        {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}


@end
