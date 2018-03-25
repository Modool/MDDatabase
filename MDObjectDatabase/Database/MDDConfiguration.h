//
//  MDDConfiguration.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/25.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDDObject;
@class MDDIndex, MDDColumnConfiguration;
@interface MDDConfiguration : NSObject

@property (nonatomic, strong, readonly) Class<MDDObject> objectClass;

@property (nonatomic, copy, readonly) NSString *tableName;

// It's invalid if multiple primary properties.
@property (nonatomic, assign, readonly) BOOL autoincrement;

@property (nonatomic, copy, readonly) NSString *primaryProperty;

@property (nonatomic, copy, readonly) NSDictionary *propertyMapper;

@property (nonatomic, copy, readonly) NSSet<NSString *> *primaryProperties;

// indexes
@property (nonatomic, copy, readonly) NSArray<MDDIndex *> *indexes;

+ (instancetype)configurationWithClass:(Class<MDDObject>)class primaryProperty:(NSString *)primaryProperty;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class propertyMapper:(NSDictionary *)propertyMapper primaryProperty:(NSString *)primaryProperty;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class tableName:(NSString *)tableName propertyMapper:(NSDictionary *)propertyMapper primaryProperty:(NSString *)primaryProperty;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class tableName:(NSString *)tableName propertyMapper:(NSDictionary *)propertyMapper autoincrement:(BOOL)autoincrement primaryProperty:(NSString *)primaryProperty;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class tableName:(NSString *)tableName propertyMapper:(NSDictionary *)propertyMapper autoincrement:(BOOL)autoincrement primaryProperty:(NSString *)primaryProperty indexes:(NSArray<MDDIndex *> *)indexes;

+ (instancetype)configurationWithClass:(Class<MDDObject>)class primaryProperties:(NSSet<NSString *> *)primaryProperties;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class propertyMapper:(NSDictionary *)propertyMapper primaryProperties:(NSSet<NSString *> *)primaryProperties;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class tableName:(NSString *)tableName propertyMapper:(NSDictionary *)propertyMapper primaryProperties:(NSSet<NSString *> *)primaryProperties;
+ (instancetype)configurationWithClass:(Class<MDDObject>)class tableName:(NSString *)tableName propertyMapper:(NSDictionary *)propertyMapper primaryProperties:(NSSet<NSString *> *)primaryProperties indexes:(NSArray<MDDIndex *> *)indexes;

- (BOOL)addColumnConfiguration:(MDDColumnConfiguration *)columnConfiguration forProperty:(NSString *)property error:(NSError **)error;

@end