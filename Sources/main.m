//
//  main.m
//
//  Created by Gil Shapira on 30/12/2012.
//

#import <Foundation/Foundation.h>
#import "FKFunkyval.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        while (1) {
            printf("Expression: ");
            char string[81];
            fgets(string, 80, stdin);

            NSString *expression = [NSString stringWithUTF8String:string];
            if (expression.length == 0) {
                break;
            }

            id<FKFunkyval> funk = [FKFunkyval funkyvalWithExpression:expression];

            NSString *value = [funk evaluateStringWithVariables:[NSMutableDictionary dictionary]];

            printf("Evaluated to: %s\n", [value UTF8String]);
        };
    }
    return 0;
}

