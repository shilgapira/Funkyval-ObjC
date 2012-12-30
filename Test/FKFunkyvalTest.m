//
//  FKFunkyvalTest.m
//
//  Created by Gil Shapira on 30/12/2012.
//

#import "FKFunkyvalTest.h"

#define assertTrue(x)       STAssertTrue(x, nil)
#define assertFalse(x)      STAssertFalse(x, nil)
#define assertEquals(a, b)  STAssertTrue((a) == (b), nil)
#define assertEqStr(a, b)   STAssertTrue([(a) caseInsensitiveCompare:(b)] == NSOrderedSame, nil)
#define assertNeStr(a, b)   STAssertTrue([(a) caseInsensitiveCompare:(b)] != NSOrderedSame, nil)


@implementation FKFunkyvalTest

static NSMutableDictionary *v = nil;

static BOOL fb(NSString *s) {
    return [[FKFunkyval funkyvalWithExpression:s] evaluateBoolWithVariables:v];
}

static NSUInteger fi(NSString *s) {
    return [[FKFunkyval funkyvalWithExpression:s] evaluateIntegerWithVariables:v];
}

static NSString *fs(NSString *s) {
    return [[FKFunkyval funkyvalWithExpression:s] evaluateStringWithVariables:v];
}

- (void)setUp {
    v = [NSMutableDictionary dictionaryWithDictionary:@{
        @"door" : @"shut",
        @"number" : @"8",
        @"sleeping" : @"yes",
    }];
}

- (void)testBool {
    assertFalse(        fb(nil));
    assertFalse(        fb(@""));
    assertFalse(        fb(@"0"));
    assertFalse(        fb(@"foo"));
    assertFalse(        fb(@"1 + 2"));
    assertTrue(         fb(@"1"));
    assertTrue(         fb(@"true"));
    assertTrue(         fb(@"yes"));
    assertFalse(        fb(@"!true"));
    assertTrue(         fb(@"!no"));
    assertTrue(         fb(@"!foo"));
    assertTrue(         fb(@"2 - 1"));
    assertTrue(         fb(@"yes == true"));
}

- (void)testInt {
    assertEquals(       fi(@"1 + 2")             , 3     );
    assertEquals(       fi(@"4 * 4")             , 16    );
    assertEquals(       fi(@"20 - 200")          , -180  );
    assertEquals(       fi(@"80 % 30")           , 20    );
    assertEquals(       fi(@"80 / 20")           , 4     );
    assertEquals(       fi(@"20 - 200")          , -180  );
    assertEquals(       fi(@"(80 % 30) + 1")     , 21    );
}

- (void)testString {
    assertEqStr(         fs(@"hello")     ,     @"hello" );
    assertNeStr(         fs(@"hello")     ,     @"world" );
    assertEqStr(         fs(@"sleeping")  ,     @"yes"   );
    assertEqStr(         fs(@"door")      ,     @"shut"  );
}

- (void)testVariables {
    assertTrue(         fb(@"sleeping")                              );
    assertTrue(         fb(@"sleeping == 1")                         );
    assertTrue(         fb(@"sleeping != false")                     );
    assertTrue(         fi(@"number") == 8                           );
    assertFalse(        fi(@"number") == 80                          );
    assertTrue(         fb(@"door == shut")                          );
    assertFalse(        fb(@"door == open")                          );

    assertTrue(         fb(@"(door == shut)")                        );
    assertTrue(         fb(@"(door == shut) && sleeping")            );
    assertFalse(        fb(@"(door != shut) && sleeping")            );
    assertTrue(         fb(@"(door != shut) || sleeping")            );

    assertTrue(         fb(@"yes")                                   );
    v[@"yes"] = @"false";
    assertFalse(        fb(@"yes")                                   );

    assertTrue(         fb(@"yes = true")                            );
    assertTrue(         fb(@"yes")                                   );
    assertTrue(         fi(@"number++") == 9                         );
    assertTrue(         fi(@"number *= 2") == 18                     );

    assertTrue(         fb(@"number == 18")                          );
    assertTrue(         fi(@"number") == 18                          );
    assertEqStr(        fs(@"number")   ,   @"18"                    );

    for (NSUInteger i = fi(@"number"); i < 100; i++) {
        assertEqStr(    fs(@"number++") ,   [@(i + 1) stringValue]   );
    }
}

- (void)testOperators {
    assertTrue(         fb(@"number < 10")                           );
    assertTrue(         fb(@"number >= 8")                           );
    assertTrue(         fi(@"number * 2") == 16                      );
    assertFalse(        fi(@"number")    == 80                       );
    assertTrue(         fb(@"door == shut")                          );
    assertFalse(        fb(@"door == open")                          );

    assertTrue(         fb(@"(door == shut)")                        );
    assertTrue(         fb(@"(door == shut) && sleeping")            );
    assertFalse(        fb(@"(door != shut) && sleeping")            );
    assertTrue(         fb(@"(door != shut) || sleeping")            );

    assertFalse(        fb(@"door = open")                           );
    assertFalse(        fb(@"door > 8")                              );
    assertTrue(         fb(@"door < 8")                              );
    v[@"door"] = @"8";
    assertTrue(         fb(@"(door + 10) == 18")                     );
    assertTrue(         fb(@"door = 1")                              );
    assertTrue(         fb(@"(door * 1000) > 100")                   );
    assertTrue(         fb(@"(door * 1000) >= 1000")                 );
    assertFalse(        fb(@"(door * 1000) > 1000")                  );
    assertFalse(        fb(@"(door * 1000) <= 100")                  );
}

- (void)testGroup {
    assertTrue(         fb(@"number == 8, number++, number == 11")   );
    assertTrue(         fb(@"number == 9, 3 == 4, number = 800")     );
    assertTrue(         fb(@"number == 800")                         );
}

@end
