//
//  FKOperatorFunkyval.h
//
//  Created by Gil Shapira on 30/12/2012.
//

#import "FKFunkyval.h"


typedef NS_ENUM(NSUInteger, FKOperator) {
    FKOperatorNOOP = 0,
    
    FKOperatorAssign,
    FKOperatorPlus,
    FKOperatorPlusPlus,
    FKOperatorPlusAssign,
    FKOperatorMinus,
    FKOperatorMinusMinus,
    FKOperatorMinusAssign,
    FKOperatorMult,
    FKOperatorMultAssign,
    FKOperatorDiv,
    FKOperatorDivAssign,
    FKOperatorMod,
    FKOperatorModAssign,
    FKOperatorEquals,
    FKOperatorNotEquals,
    FKOperatorGreater,
    FKOperatorGreaterEquals,
    FKOperatorLess,
    FKOperatorLessEquals,
    FKOperatorAnd,
    FKOperatorOr,
    FKOperatorNot,
};


@interface FKOperatorFunkyval : FKFunkyval

@property (nonatomic,assign) FKOperator op;

@property (nonatomic,strong) id<FKFunkyval> left;

@property (nonatomic,strong) id<FKFunkyval> right;

+ (FKOperator)operatorForString:(NSString *)string;

- (id)initWithOperator:(FKOperator)op;

@end
