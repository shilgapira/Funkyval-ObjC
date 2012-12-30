//
//  FKGroupFunkyval.h
//
//  Created by Gil Shapira on 30/12/2012.
//

#import "FKFunkyval.h"


@interface FKGroupFunkyval : FKFunkyval

@property (nonatomic,copy,readonly) NSArray *funkyvals;

- (id)initWithFunkyvals:(NSArray *)funkyvals;

@end
