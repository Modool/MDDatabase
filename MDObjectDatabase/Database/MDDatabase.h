//
//  MDDatabase.h
//  MDDatabase
//
//  Created by xulinfeng on 2017/12/1.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDDTableInfo, MDDObject, MDDReferenceDatabaseQueue;
@class MDDTableConfiguration, MDDViewConfiguration, MDDCompat;
@interface MDDatabase : NSObject

+ (instancetype)databaseWithDatabaseQueue:(id<MDDReferenceDatabaseQueue>)queue;
- (instancetype)initWithDatabaseQueue:(id<MDDReferenceDatabaseQueue>)queue;

- (id<MDDTableInfo>)requireInfoWithClass:(Class<MDDObject>)class error:(NSError **)error;
- (BOOL)existForClass:(Class<MDDObject>)class;

- (BOOL)prepareWithError:(NSError **)error;
- (void)close;

- (MDDCompat *)addTableConfiguration:(MDDTableConfiguration *)configuration error:(NSError **)error;
- (MDDCompat *)addViewConfiguration:(MDDViewConfiguration *)configuration error:(NSError **)error;

@end
