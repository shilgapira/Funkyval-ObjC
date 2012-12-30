//
//  FKOperatorFunkyval.m
//
//  Created by Gil Shapira on 30/12/2012.
//

#import "FKOperatorFunkyval.h"
#import "FKValueFunkyval.h"


@interface FKOperatorFunkyval ()

@property (nonatomic,copy,readonly) NSString *opName;

@end


@implementation FKOperatorFunkyval

- (id)initWithOperator:(FKOperator)op {
    if (self = [super init]) {
        _op = op;
        _opName = [FKOperatorFunkyval stringForOperator:_op];
    }
    return self;
}

- (NSString *)evaluateStringWithVariables:(NSMutableDictionary *)variables {
    if (_left == [FKFunkyval null] && _right == [FKFunkyval null]) {
        return [[FKFunkyval null] evaluateStringWithVariables:variables];
    }

    switch (_op) {
        case FKOperatorPlusPlus:
        case FKOperatorMinusMinus:
        case FKOperatorPlusAssign:
        case FKOperatorMinusAssign:
        case FKOperatorMultAssign:
        case FKOperatorDivAssign:
        case FKOperatorModAssign:
            [self convertComplexOperator];
            // fall down to evaluate assign after conversion
        case FKOperatorAssign: {
            NSString *result = [self evalAssign:variables];
            NSLog(@"%@, Result (S): %@", _opName, result);
            return result;
        }

        case FKOperatorPlus:
        case FKOperatorMinus:
        case FKOperatorMult:
        case FKOperatorDiv:
        case FKOperatorMod: {
            NSInteger result = [self evalArithmetic:variables];
            NSLog(@"%@, Result (I): %ld", _opName, (unsigned long)result);
            return [@(result) stringValue];
        }

        case FKOperatorEquals:
        case FKOperatorNotEquals: {
            BOOL result = [self evalEqual:variables];
            NSLog(@"%@, Result (B): %d", _opName, result);
            return result ? @"1" : @"0";
        }

        case FKOperatorGreater:
        case FKOperatorGreaterEquals:
        case FKOperatorLess:
        case FKOperatorLessEquals: {
            BOOL result = [self evalCompare:variables];
            NSLog(@"%@, Result (B): %d", _opName, result);
            return result ? @"1" : @"0";
        }

        case FKOperatorAnd:
        case FKOperatorOr:
        case FKOperatorNot: {
            BOOL result = [self evalBoolean:variables];
            NSLog(@"%@, Result (B): %d", _opName, result);
            return result ? @"1" : @"0";
        }

        default:
            return [[FKFunkyval null] evaluateStringWithVariables:variables];
    }
}

- (NSString *)evalAssign:(NSMutableDictionary *)variables {
    NSString *right = [_right evaluateStringWithVariables:variables];
    NSLog(@"%@, Right (S): %@", _opName, right);

    // use left side of the assignment as an lvalue
    if ([_left isKindOfClass:FKValueFunkyval.class]) {
        FKValueFunkyval *left = (FKValueFunkyval *)_left;
        NSString *variable = [left.value lowercaseString];
        // the value itself (not the result of its evaluation) is the name of the variable
        NSLog(@"%@, Left (A): %@", _opName, variable);
        variables[variable] = right;
    }
    
    return right;
}

- (NSInteger)evalArithmetic:(NSMutableDictionary *)variables {
    NSInteger left = [_left evaluateIntegerWithVariables:variables];
    NSInteger right = [_right evaluateIntegerWithVariables:variables];
    NSLog(@"%@, Left (I): %ld", _opName, (unsigned long)left);
    NSLog(@"%@, Right (I): %ld", _opName, (unsigned long)right);

    switch (_op) {
        case FKOperatorPlus: return left + right;
        case FKOperatorMinus: return left - right;
        case FKOperatorMult: return left * right;
        case FKOperatorDiv: return left / right;
        case FKOperatorMod: return left % right;
        default: return 0;
    }
}

- (BOOL)evalEqual:(NSMutableDictionary *)variables {
    NSString *left = [_left evaluateStringWithVariables:variables];
    NSString *right = [_right evaluateStringWithVariables:variables];
    NSLog(@"%@, Left (S): %@", _opName, left);
    NSLog(@"%@, Right (S): %@", _opName, right);

    if ([left caseInsensitiveCompare:@"yes"] == NSOrderedSame || [left caseInsensitiveCompare:@"true"] == NSOrderedSame) {
        left = @"1";
    }
    if ([right caseInsensitiveCompare:@"yes"] == NSOrderedSame || [right caseInsensitiveCompare:@"true"] == NSOrderedSame) {
        right = @"1";
    }

    BOOL comparison = ([left caseInsensitiveCompare:right] == NSOrderedSame);
    if (_op == FKOperatorNotEquals) {
        comparison = !comparison;
    }
    
    return comparison;
}

- (BOOL)evalCompare:(NSMutableDictionary *)variables {
    NSInteger left = [_left evaluateIntegerWithVariables:variables];
    NSInteger right = [_right evaluateIntegerWithVariables:variables];
    NSLog(@"%@, Left (I): %ld", _opName, (unsigned long)left);
    NSLog(@"%@, Right (I): %ld", _opName, (unsigned long)right);

    switch (_op) {
        case FKOperatorGreater: return left > right;
        case FKOperatorGreaterEquals: return left >= right;
        case FKOperatorLess: return left < right;
        case FKOperatorLessEquals: return left <= right;
        default: return NO;
    }
}

- (BOOL)evalBoolean:(NSMutableDictionary *)variables {
    BOOL right = [_right evaluateBoolWithVariables:variables];
    NSLog(@"%@, Right (B): %d", _opName, right);

    if (_op == FKOperatorNot) {
        return !right;
    } else {
        BOOL left = [_left evaluateBoolWithVariables:variables];
        NSLog(@"%@, Left (B): %d", _opName, left);
        
        if (_op == FKOperatorAnd) {
            return left && right;
        } else {
            return left || right;
        }
    }
}

- (void)convertComplexOperator {
    FKOperator subop;
    id<FKFunkyval> subright;

    switch (_op) {
        case FKOperatorPlusPlus:
            subop = FKOperatorPlus;
            subright = [[FKValueFunkyval alloc] initWithValue:@"1"];
            break;

        case FKOperatorMinusMinus:
            subop = FKOperatorMinus;
            subright = [[FKValueFunkyval alloc] initWithValue:@"1"];
            break;

        case FKOperatorPlusAssign:
            subop = FKOperatorPlus;
            subright = _right;
            break;

        case FKOperatorMinusAssign:
            subop = FKOperatorMinus;
            subright = _right;
            break;

        case FKOperatorMultAssign:
            subop = FKOperatorMult;
            subright = _right;
            break;

        case FKOperatorDivAssign:
            subop = FKOperatorDiv;
            subright = _right;
            break;

        case FKOperatorModAssign:
            subop = FKOperatorMod;
            subright = _right;
            break;

        default:
            _op = FKOperatorNOOP;
            return;
    }

    _op = FKOperatorAssign;
    FKOperatorFunkyval *right = [[FKOperatorFunkyval alloc] initWithOperator:subop];
    right.left = _left;
    right.right = subright;
    _right = right;
}


///////////////////////////////
#pragma mark - FKOperator strings
///////////////////////////////

+ (NSString *)stringForOperator:(FKOperator)op {
    NSArray *strings = [[FKOperatorFunkyval operatorStrings] allKeysForObject:@(op)];
    if (strings.count) {
        return strings[0];
    }
    return nil;
}

+ (FKOperator)operatorForString:(NSString *)string {
    NSNumber *number = [[FKOperatorFunkyval operatorStrings] objectForKey:string];
    FKOperator op = [number integerValue];
    return op;
}

+ (NSDictionary *)operatorStrings {
    static NSDictionary * instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [self createOperatorStrings];
    });
    return instance;
}

+ (NSDictionary *)createOperatorStrings {
    NSMutableDictionary *ops = [NSMutableDictionary dictionary];
    ops[@"="] = @(FKOperatorAssign);
    ops[@"+"] = @(FKOperatorPlus);
    ops[@"++"] = @(FKOperatorPlusPlus);
    ops[@"+="] = @(FKOperatorPlusAssign);
    ops[@"-"] = @(FKOperatorMinus);
    ops[@"--"] = @(FKOperatorMinusMinus);
    ops[@"-="] = @(FKOperatorMinusAssign);
    ops[@"*"] = @(FKOperatorMult);
    ops[@"*="] = @(FKOperatorMultAssign);
    ops[@"/"] = @(FKOperatorDiv);
    ops[@"/="] = @(FKOperatorDivAssign);
    ops[@"%"] = @(FKOperatorMod);
    ops[@"%="] = @(FKOperatorModAssign);
    ops[@"=="] = @(FKOperatorEquals);
    ops[@"!="] = @(FKOperatorNotEquals);
    ops[@">"] = @(FKOperatorGreater);
    ops[@">="] = @(FKOperatorGreaterEquals);
    ops[@"<"] = @(FKOperatorLess);
    ops[@"<="] = @(FKOperatorLessEquals);
    ops[@"&&"] = @(FKOperatorAnd);
    ops[@"||"] = @(FKOperatorOr);
    ops[@"!"] = @(FKOperatorNot);
    return ops;
}

@end
