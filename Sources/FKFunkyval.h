//
//  FKFunkyval.h
//
//  Created by Gil Shapira on 30/12/2012.
//

#import <Foundation/Foundation.h>


@protocol FKFunkyval <NSObject>

- (NSInteger)evaluateIntegerWithVariables:(NSMutableDictionary *)variables;

- (NSString *)evaluateStringWithVariables:(NSMutableDictionary *)variables;

- (BOOL)evaluateBoolWithVariables:(NSMutableDictionary *)variables;

- (void)performWithVariables:(NSMutableDictionary *)variables;;

@end


@interface FKFunkyval : NSObject <FKFunkyval>

+ (id<FKFunkyval>)funkyvalWithExpression:(NSString *)expression;

+ (id<FKFunkyval>)null;

@end

