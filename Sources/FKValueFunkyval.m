//
//  FKValueFunkyval.m
//
//  Created by Gil Shapira on 30/12/2012.
//

#import "FKValueFunkyval.h"


@implementation FKValueFunkyval

- (id)initWithValue:(NSString *)value {
    if (self = [super init]) {
        _value = [value copy];
    }
    return self;
}

- (NSString *)evaluateStringWithVariables:(NSMutableDictionary *)variables {
    NSString *variableName = [_value lowercaseString];
    id variableValue = variables[variableName];

    if ([variableValue isKindOfClass:NSString.class]) {
        NSLog(@"VL, Result (R): %@ (value of %@)", variableValue, variableName);
        return variableValue;
    }

    NSLog(@"VL, Result (V): %@", _value);
    return _value;
}

@end
