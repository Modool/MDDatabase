//
//  MDDProcessor+Private.h
//  MDObjectDatabase
//
//  Created by xulinfeng on 2018/3/24.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "MDDProcessor.h"
#import "MDDAccessor.h"

@interface MDDProcessor : NSObject<MDDProcessor>

@property (nonatomic, strong, readonly) MDDatabase *database;
@property (nonatomic, strong, readonly) MDDTableInfo *tableInfo;
@property (nonatomic, strong, readonly) Class<MDDObject> modelClass;

- (instancetype)initWithClass:(Class<MDDObject>)class database:(MDDatabase *)database tableInfo:(MDDTableInfo *)tableInfo;

@end

