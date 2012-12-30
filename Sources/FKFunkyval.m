//
//  FKFunkyval.h
//
//  Created by Gil Shapira on 30/12/2012.
//

#import "FKFunkyval.h"
#import "FKGroupFunkyval.h"
#import "FKOperatorFunkyval.h"
#import "FKValueFunkyval.h"


@implementation FKFunkyval

//////////////////////////
#pragma mark - Evaluations
//////////////////////////

- (NSString *)evaluateStringWithVariables:(NSMutableDictionary *)variables {
    NSAssert(0, @"Abstract method");
    return nil;
}

- (NSInteger)evaluateIntegerWithVariables:(NSMutableDictionary *)variables {
    NSString *evaluation = [self evaluateStringWithVariables:variables];
    return [evaluation integerValue];
}

- (BOOL)evaluateBoolWithVariables:(NSMutableDictionary *)variables {
    NSString *evaluation = [self evaluateStringWithVariables:variables];
    return [evaluation isEqualToString:@"1"] ||
           [evaluation caseInsensitiveCompare:@"yes"] == NSOrderedSame ||
           [evaluation caseInsensitiveCompare:@"true"] == NSOrderedSame;
}

- (void)performWithVariables:(NSMutableDictionary *)variables {
    [self evaluateStringWithVariables:variables];
}


///////////////////////
#pragma mark - Building
///////////////////////

+ (id<FKFunkyval>)funkyvalWithExpression:(NSString *)expression {
    expression = [expression stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];

    NSArray *expressions = [expression componentsSeparatedByString:@","];
    if (expressions.count > 1) {
        NSMutableArray *funkyvals = [NSMutableArray array];
        for (NSString *exp in expressions) {
            id<FKFunkyval> funkyval = [self funkyvalFromString:exp];
            [funkyvals addObject:funkyval];
        }
        return [[FKGroupFunkyval alloc] initWithFunkyvals:funkyvals];
    } else if (expressions.count == 1) {
        return [self funkyvalFromString:expression];
    } else {
        return [self null];
    }
}

+ (id<FKFunkyval>)funkyvalFromString:(NSString *)string {
    return [self funkyvalFromString:string start:0 end:string.length];
}

+ (id<FKFunkyval>)funkyvalFromString:(NSString *)string start:(NSUInteger)start end:(NSUInteger)end {
    NSMutableArray *funks = [NSMutableArray array];

    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet *alphanumeric = [NSCharacterSet alphanumericCharacterSet];

    // scan the range of the string looking for at most 3 funkyvals, e.g.,
    // "a + b", "a ++", "a == b", "!a"
    for (NSUInteger i = start; i < end && funks.count < 3; i++) {
        unichar c = [string characterAtIndex:i];

        if ([whitespace characterIsMember:c]) {
            // skip whitespace
            continue;
        }

        if ([alphanumeric characterIsMember:c] || c == '_' || (funks.count != 1 && c == '-')) {
            // values, such as 'foo', '15', '-8', 'bar19', etc
            NSUInteger len = 1;
            while (i + len < end) {
                unichar k = [string characterAtIndex:(i + len)];
                if (![alphanumeric characterIsMember:k] && k != '_') {
                    break;
                }
                len++;
            }

            NSString *value = [string substringWithRange:NSMakeRange(i, len)];

            id<FKFunkyval> funk = [[FKValueFunkyval alloc] initWithValue:value];
            [funks addObject:funk];

            i += len - 1;
        } else if (c == '(') {
            // parenthesis, we simply build recursively on what's inside them.
            // we might pass other parenthesis on the way though so we track the depth
            NSUInteger depth = 0;
            // subexpression starts 1 char after the '(' and ends 1 char before the ')'
            NSUInteger substart = i + 1;
            while (i < end) {
                unichar k = [string characterAtIndex:i];

                if (k == ')') {
                    depth--;
                } else if (k == '(') {
                    depth++;
                }

                if (depth == 0) {
                    id<FKFunkyval> funk = [self funkyvalFromString:string start:substart end:i];
                    [funks addObject:funk];
                    break;
                } else {
                    // only increment if we're not at the end yet
                    i++;
                }
            }
        } else {
            // operator, such as '=', '++', '!=', '&', etc 
            NSUInteger len = 1;
            if (i + 1 < end) {
                unichar k = [string characterAtIndex:(i + 1)];
                if (k == '=' || (k == '+' && c == '+') || (k == '-' && c == '-') || (k == '|' && c == '|') || (k == '&' && c == '&')) {
                    len = 2;
                }
            }

            NSString *value = [string substringWithRange:NSMakeRange(i, len)];
            FKOperator op = [FKOperatorFunkyval operatorForString:value];

            id<FKFunkyval> funk = [[FKOperatorFunkyval alloc] initWithOperator:op];
            [funks addObject:funk];

            i += len - 1;
        }
    }

    if (funks.count == 1) {
        // 1 funkyval, can be anything really
        return funks[0];
    } else if (funks.count == 2) {
        // 2 funkyvals, one of them should be an operator
        id<FKFunkyval> first = funks[0];
        id<FKFunkyval> second = funks[1];
        if ([first isKindOfClass:FKOperatorFunkyval.class]) {
            FKOperatorFunkyval *op = (FKOperatorFunkyval *)first;
            op.right = second;
            return op;
        } else if ([second isKindOfClass:FKOperatorFunkyval.class]) {
            FKOperatorFunkyval *op = (FKOperatorFunkyval *)second;
            op.left = first;
            return op;
        }
    } else if (funks.count == 3) {
        // 3 funkyvals, middle one must be an operator
        id<FKFunkyval> middle = funks[1];
        if ([middle isKindOfClass:FKOperatorFunkyval.class]) {
            FKOperatorFunkyval *op = (FKOperatorFunkyval *)middle;
            op.left = funks[0];
            op.right = funks[2];
            return op;
        }
    }

    // empty or malformed expression
    return [self null];
}


////////////////////////////////
#pragma mark - Null placerholder
////////////////////////////////

+ (id<FKFunkyval>)null {
    static id instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [self funkyvalWithExpression:@"0"];
    });
    return instance;
}


@end
