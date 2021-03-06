//
//  MDDColumnConfiguration.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/30.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDColumnConfiguration.h"
#import "MDDColumn.h"

@implementation MDDColumnConfiguration

+ (instancetype)defaultConfigurationWithColumn:(MDDColumn *)column;{
    MDDColumnConfiguration *configuration = [[self alloc] init];
    
    configuration->_primary = [column isPrimary];
    configuration.nullabled = (![column isPrimary] && [column type] == MDDColumnTypeText);
    configuration.defaultValue = (![column isPrimary] && [column type] != MDDColumnTypeText) ? @0 : nil;
    
    return configuration;
}

- (NSString *)description{
    return [[self dictionaryWithValuesForKeys:@[@"primary", @"nullabled", @"unique", @"checkValue", @"defaultValue", @"length", @"compositePropertyName"]] description];
}

@end
