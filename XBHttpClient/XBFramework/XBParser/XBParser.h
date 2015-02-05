//
//  XBParser.h
//  XBHttpClient
//
//  Created by Peter on 15/1/30.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XBParser <NSObject>
- (void)parserBodyWithXML:(NSString *)xmlStr;
- (void)parserBodyWithJson:(NSDictionary *)jsonData;
@end