//
//  XBBaseParser.h
//  XBHttpClient
//
//  Created by Peter on 15/1/30.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "XBParser.h"

/**
 *  属于解析实体的基类，内部自实现了json映射解析，
 XML解析，会抛给子类自实现解析，基类不关心，子
 类如果想自定制解析，请覆盖协议族TZSParser中
 对应的解析接口，申明属性请绕开code和isSuccess
 两个属性
 */
@interface XBBaseParser : NSObject<XBParser>
{
    NSString *msg;
    NSNumber *isSuccess;
    NSString *code;
}
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSNumber * isSuccess;
/**
 *  请求是否成功
 *
 *  @return YES:成功
 */
- (BOOL)success;

/**
 *  获取请求的标识码
 *
 *  @return 请求回来的业务标识码
 */
- (NSString *)getCode;

/**
 *  返回mapperKey（json和实体属性之间的映射）
 *
 *  @return 属性映射mapper
 */
- (NSDictionary *)mapperKey;

/**
 *  获取实体映射的属性数组
 *
 *  @return 实体映射的属性数组
 */
- (NSArray *)getPropertyArr;

/**
 *  获取实体的子属性或者数组元素（类别）的类别
 *
 *  @return 子属性或者数组元素（类别）的类别字典
 */
- (NSDictionary *)getModelTypeDict;

/**
 *  设定用XML解析
 *
 *  @param isXMLParser YES:XML解析 NO:Json解析
 */
- (void)setXMLParser:(BOOL)isXMLParser;
@end
