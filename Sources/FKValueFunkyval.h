//
//  FKValueFunkyval.h
//
//  Created by Gil Shapira on 30/12/2012.
//

#import "FKFunkyval.h"


@interface FKValueFunkyval : FKFunkyval

@property (nonatomic,copy,readonly) NSString *value;

- (id)initWithValue:(NSString *)value;

@end
