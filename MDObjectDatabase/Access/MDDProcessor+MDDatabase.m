//
//  MDDProcessor+MDDatabase.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import <FMDB/FMDB.h>

#import "MDDProcessor+MDDatabase.h"
#import "MDDatabase+Executing.h"

#import "MDDDescriptor.h"
#import "MDDTokenDescription.h"

@implementation MDDProcessor (MDDatabase)

- (BOOL)executeInsertDescriptions:(NSArray<MDDTokenDescription *> *)descriptions block:(void (^)(NSUInteger index, NSUInteger rowID))block;{
    NSParameterAssert(descriptions && [descriptions count]);
    return [self executeInsert:^MDDTokenDescription *(NSUInteger index, BOOL *stop) {
        *stop = index >= (descriptions.count - 1);
        
        return descriptions[index];;
    } result:^(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop) {
        if (block) block(index, rowID);
    }];
}

- (BOOL)executeInsert:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, UInt64 rowID, NSUInteger index, BOOL *stop))resultBlock;{
    return [self _executeUpdate:block result:^(BOOL state, FMDatabase *database, NSUInteger index, BOOL *stop) {
        if (resultBlock) resultBlock(state, database.lastInsertRowId, index, stop);
    }];
}

- (BOOL)executeInsertDescription:(MDDTokenDescription *)description completion:(void (^)(NSUInteger rowID))completion;{
    return [self executeUpdateDescription:description completion:^(FMDatabase *database) {
        if (completion) completion([database lastInsertRowId]);
    }];
}

- (BOOL)executeUpdateDescription:(MDDTokenDescription *)description;{
    return [self executeUpdateDescription:description completion:nil];
}

- (BOOL)executeUpdateDescription:(MDDTokenDescription *)description completion:(void (^)(FMDatabase *database))completion;{
    NSParameterAssert(description);
    return [[self database] executeUpdateSQL:[description tokenString] withArgumentsInArray:[description values] completion:completion];
}

- (BOOL)executeUpdateDescriptions:(NSArray<MDDTokenDescription *> *)descriptions;{
    NSParameterAssert(descriptions && [descriptions count]);
    return [self _executeUpdate:^MDDTokenDescription *(NSUInteger index, BOOL *stop) {
        *stop = index >= (descriptions.count - 1);
        
        return descriptions[index];
    } result:nil];
}

- (BOOL)executeUpdate:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, NSUInteger index, BOOL *stop))resultBlock;{
    return [self _executeUpdate:block result:^(BOOL state, FMDatabase *database, NSUInteger index, BOOL *stop) {
        if (resultBlock) resultBlock(state, index, stop);
    }];
}

- (BOOL)_executeUpdate:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(BOOL state, FMDatabase *database, NSUInteger index, BOOL *stop))resultBlock;{
    NSParameterAssert(block);
    __block BOOL success = YES;
    [[self database] executeInTransaction:^(FMDatabase *database, BOOL *rollback) {
        @try {
            NSUInteger index = 0;
            BOOL stop = NO;
            BOOL result = YES;
            while (!stop && result) {
                MDDTokenDescription *description = block(index, &stop);
                index++;
        
                if (!description) continue;
                
                NSArray *values = [description values];
                if (!values || ![values count]) {
                    result = [database executeUpdate:[description tokenString]];
                } else {
                    result = [database executeUpdate:[description tokenString] withArgumentsInArray:values];
                }
                
                if (resultBlock) resultBlock(result, database, index - 1, &stop);
            }
        } @catch (NSException *exception) {
            *rollback = YES;
            success = NO;
        }
    }];
    return success;
}

- (void)executeQueryDescription:(MDDTokenDescription *)description block:(void (^)(NSDictionary *dictionary))block;{
    NSParameterAssert(description);
    [[self database] executeQuerySQL:[description tokenString] withArgumentsInArray:[description values] block:block];
}

- (BOOL)executeQueryDescription:(MDDTokenDescription *(^)(NSUInteger index, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;{
    return [self executeQuery:^NSString *(NSUInteger index, NSArray **values, BOOL *stop) {
        MDDTokenDescription *description = block(index, stop);
        
        *values = description.values;
        return [description tokenString];
    } result:^(NSUInteger index, NSDictionary *dictionary, BOOL *stop) {
        if (resultBlock) resultBlock(index, dictionary, stop);
    }];
}

- (void)executeQuery:(NSString *)query values:(NSArray *)values block:(void (^)(NSDictionary *dictionary))block;{
    [[self database] executeQuerySQL:query withArgumentsInArray:values block:block];
}

- (BOOL)executeQuery:(NSString *(^)(NSUInteger index, NSArray **values, BOOL *stop))block result:(void (^)(NSUInteger index, NSDictionary *dictionary, BOOL *stop))resultBlock;{
    NSParameterAssert(block && resultBlock);
    __block BOOL success = YES;
    [[self database] executeInTransaction:^(FMDatabase *database, BOOL *rollback) {
        @try {
            NSUInteger index = 0;
            BOOL stop = NO;
            while (!stop) {
                NSArray *values = nil;
                NSString *SQL = block(index, &values, &stop);
                
                index++;
                if (![SQL length]) continue;
                
                FMResultSet *resultSet = nil;
                if (!values || ![values count]) {
                    resultSet = [database executeQuery:SQL];
                } else {
                    resultSet = [database executeQuery:SQL withArgumentsInArray:values];
                }
                while ([resultSet next]) {
                    if (resultBlock) resultBlock(index - 1, [resultSet resultDictionary], &stop);
                }
                [resultSet close];
            }
        } @catch (NSException *exception) {
            *rollback = YES;
            success = NO;
        }
    }];
    
    return success;
}

@end
