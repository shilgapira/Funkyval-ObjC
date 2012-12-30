# Funkyval

Quick and dirty expression evaluator I hacked together. It's pretty handy for application state logic that's determined in runtime, most likely as input from a web service.

Funkyval evaluates arithmetic, boolean and string expressions with support for getting and setting values from variables.

Should work on any version of iOS or OS X.


## Usage

``` objective-c
// Container for variables and their values
NSDictionary *variables = ...;

...

// Simple evaluation of a math expression
id<FKFunkyval> mult = [FKFunkyval funkyvalWithExpression:@"2 * 4"];
NSUInteger result = [mult evaluateIntegerWithVariables:variables]; // 8

...

// Using variables for state logic
variables[@"door"] = @"open";

id<FKFunkyval> foo = [FKFunkyval funkyvalWithExpression:@"door == open"];
if ([foo evaluateBooleanWithVariables:variables]) {
	// close the door
	[[FKFunkyval funkyvalWithExpression:@"door = closed"] performWithVariables:variables];
}

...

// Get expression from web service
NSString *validatorExpression = json[@"validator"];

id<FKFunkyval> validator = [FKFunkyval funkyvalWithExpression:validatorExpression];

NSDictionary *userData = ...;
if ([validator evaluateBooleanWithVariables:userData]) {
	// success
} else {
	// error
}

```


## Expressions

- ```open == true```
- ```open = false```
- ```!open```
- ```state = (8 * 4)```
- ```state++```
- ```state >= 1```
- ```(state >= 1) && (open == true)```
- ```state = 0, open = false```
- ```(number % 2) == 1```
- ```(2 + 2) == 4```
- ```...```

Check the unit test out for more examples.


## Why?

Nothing groundbreaking here as there are many libraries that do all of this. However, as is often the case they do much more than what I needed and since this code ships as part of a mobile SDK we prioritise small binary size.


## Limitations

- Doesn't support operator precedence so use parentheses liberally.
- Values are treated as numbers, booleans or strings depending on context and what makes more sense (subjectively).

Then again if these actually turn out to be issues for your use case then you'll probably be better served by a more complete solution.
