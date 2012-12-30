//
//  FKGroupFunkyval.m
//
//  Created by Gil Shapira on 30/12/2012.
//

#import "FKGroupFunkyval.h"


@implementation FKGroupFunkyval

- (id)initWithFunkyvals:(NSArray *)funkyvals {
    if (self = [super init]) {
        _funkyvals = [funkyvals copy];
    }
    return self;
}

- (NSString *)evaluateStringWithVariables:(NSMutableDictionary *)variables {
    NSString *result = nil;
    for (id<FKFunkyval> funkyval in _funkyvals) {
        NSString *value = [funkyval evaluateStringWithVariables:variables];
        if (!result) {
            result = value;
        }
    }

    result = result ?: @"0";

    NSLog(@"GROUP, Result (S): %@", result);
    return result;
}

@end
