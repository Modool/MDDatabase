//
//  MDDTableInfo.m
//  MDDatabase
//
//  Created by xulinfeng on 2017/11/29.
//  Copyright © 2017年 modool. All rights reserved.
//

#import "MDDTableInfo.h"
#import "MDDTableInfo+Private.h"

#import "MDPropertyAttributes.h"

#import "MDDColumn+Private.h"
#import "MDDDescriptor+Private.h"
#import "MDDConfiguration+Private.h"
#import "MDDObject.h"
#import "MDDIndex.h"
#import "MDDConditionSet.h"
#import "MDDErrorCode.h"

@implementation MDDTableInfo

+ (instancetype)infoWithConfiguration:(MDDConfiguration *)configuration error:(NSError **)error;{
    Class<MDDObject> class = [configuration objectClass];
    NSString *tableName = [configuration tableName];
    
    NSSet<NSString *> *primaryProperties = [configuration primaryProperties] ?: [NSSet setWithObject:[configuration primaryProperty]];
    if (!primaryProperties || ![primaryProperties count]) {
        if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:MDDErrorCodeNonePrimaryKey userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"None of primary keys for table %@ of class %@", tableName, class]}];
        return nil;
    }
    BOOL autoincrement = [configuration autoincrement];
    NSDictionary *propertyMapping = [configuration propertyMapper];
    NSArray<MDPropertyAttributes *> *attributes = MDPropertyAttributesForClass(class, propertyMapping != nil);
    if ([propertyMapping count]) {
        attributes = [self _attributes:attributes fitlerByPropertyNames:[propertyMapping allKeys]];
    } else {
        propertyMapping = [self _propertyMappingFromPropertyAttributes:attributes];
    }
    
    NSMutableDictionary<NSString *, MDDColumn *> *columnMapping = [[NSMutableDictionary alloc] init];
    for (MDPropertyAttributes *attribute  in attributes) {
        NSString *propertyName = [attribute name];
        NSString *columnName = propertyMapping[propertyName];
        BOOL primary = [primaryProperties containsObject:propertyName];
        
        MDDColumn *column = [MDDColumn columnWithName:columnName propertyName:propertyName primary:primary autoincrement:(primary && autoincrement) attribute:attribute];
        column.configuration = configuration.columnConfigurations[propertyName];
        
        if (!column) {
            if (error) *error = [NSError errorWithDomain:MDDatabaseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to reference property %@ with column %@ for table %@ of class %@", propertyName, columnName, tableName, class]}];
            return nil;
        }
        
        columnMapping[propertyName] = column;
    }
    
    NSArray<MDDIndex *> *indexes = [configuration indexes];
    NSArray<NSString *> *indexNames = [indexes valueForKey:@"name"];
    NSDictionary *indexesMapping = [NSDictionary dictionaryWithObjects:indexes forKeys:indexNames];
    
    MDDTableInfo *info = [self new];
    
    info->_objectClass = class;
    info->_tableName = [tableName copy];
    info->_primaryProperties = [primaryProperties copy];
    
    info->_columnMapping = [columnMapping copy];
    info->_indexeMapping = [indexesMapping copy];
    info->_propertyMapping = [propertyMapping copy];
    
    return info;
}

#pragma mark - accessor

- (NSArray<NSString *> *)columnNames{
    return [[self columnMapping] allKeys];
}

- (NSArray<MDDColumn *> *)columns{
    return [[self columnMapping] allValues];
}

- (NSArray<NSString *> *)indexNames{
    return [[self indexeMapping] allKeys];
}

- (NSArray<MDDIndex *> *)indexes{
    return [[self indexeMapping] allValues];
}

#pragma mark - protected

- (MDDColumn *)columnForKey:(id)key;{
    NSSet<NSString *> *primaryProperties = [self primaryProperties];
    NSParameterAssert([primaryProperties count]);
    NSParameterAssert([primaryProperties count] == 1 || ([primaryProperties count] > 1 && (key && (id)key != [NSNull null])));
    
    if ((!key || key == [NSNull null]) && [primaryProperties count] == 1) {
        key = [primaryProperties anyObject];
    }
    NSParameterAssert(key);
    
    MDDColumn *column = self.columnMapping[key];
    NSParameterAssert(column);
    
    return column;
}

- (MDDIndex *)indexForKeys:(NSSet<NSString *> *)keys;{
    NSParameterAssert(keys && [keys count]);
    
    for (MDDIndex *index in [self indexes]) {
        if ([[index propertyNames] isEqual:keys]) return index;
    }
    return nil;
}

- (MDDIndex *)indexForConditionSet:(MDDConditionSet *)conditionSet;{
    NSParameterAssert(conditionSet);
    NSArray *allKeys = [conditionSet allKeys];
    
    NSMutableSet<NSString *> *keys = [NSMutableSet new];
    for (id key in allKeys) {
        NSString *keyString = key;
        if ((!key || key == [NSNull null]) && [[self primaryProperties] count] == 1) {
            keyString = [[self primaryProperties] anyObject];
        }
        
        [keys addObject:keyString];
    }
    return [self indexForKeys:keys];
}

#pragma mark - private

+ (NSDictionary *)_propertyMappingFromPropertyAttributes:(NSArray<MDPropertyAttributes *> *)attributes {
    NSMutableDictionary<NSString *, NSString *> *mapping = [NSMutableDictionary<NSString *, NSString *> new];
    
    for (MDPropertyAttributes *attribute in attributes) {
        NSString *propertyName = [attribute name];
        NSParameterAssert(propertyName);
        
        if ([[mapping allKeys] containsObject:[attribute name]]) continue;
        
        mapping[propertyName] = propertyName;
    }
    
    return [mapping copy];
}

+ (NSArray<MDPropertyAttributes *> *)_attributes:(NSArray<MDPropertyAttributes *> *)attributes fitlerByPropertyNames:(NSArray<NSString *> *)propertyNames{
    NSMutableDictionary<NSString *, MDPropertyAttributes *> *properties = [NSMutableDictionary<NSString *, MDPropertyAttributes *> new];
    
    for (MDPropertyAttributes *attribute in attributes) {
        NSParameterAssert([attribute name]);
        
        if (![propertyNames containsObject:[attribute name]]) continue;
        if ([[properties allKeys] containsObject:[attribute name]]) continue;
        
        properties[[attribute name]] = attribute;
    }
    return [properties allValues];
}

@end
