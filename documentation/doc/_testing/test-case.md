---
layout: default
title: Test Case
nav_order: 3
---

# GdUnit Test Case

## TestCase Definition

Test cases are essential in software testing because they provide a way to ensure that the software is working as intended and meets the requirements
and specifications of the project. By executing a set of test cases, testers can identify and report any defects or issues in the software,
which can then be addressed by the development team.<br>
A test is defined as a function that follows the pattern **test_*****name***(*[arguments]*) -> *void*.
The function name must start with the prefix **test_** to be identified as a test. You can choose any name for the ***name*** part,
but it should correspond to the function being tested. Test *[arguments]* are optional and will be explained later in the advanced testing section.<br>
When naming your tests, use a descriptive name that accurately represents what the test does.

In addition to containing multiple test cases, a TestSuite can also contain test setup and teardown [(**hooks**)]({{site.baseurl}}/testing/hooks/#gdunit-hooks)
that are executed before and after each test case, as well as before and after the entire TestSuite.
This allows you to control the test environment and ensure that tests are executed in a consistent and repeatable manner.

- [TestCase Hooks]({{site.baseurl}}/testing/hooks/#testcase-hooks)

---

## Single TestCase

{% tabs faq-test-case-name %}
{% tab faq-test-case-name GdScript %}
To define a TestCase you have to use the prefix `test_` e.g. `test_verify_is_string`<br>

```gd
extends GdUnitTestSuite

func before_test():
    # Setup test data here

func after_test():
    # Cleanup test data here

func test_string_to_lower() -> void:
   assert_str("AbcD".to_lower()).is_equal("abcd")
```

We named it **test_*string_to_lower()*** because we test the `to_lower` function on a string.<br>

{% endtab %}
{% tab faq-test-case-name C# %}
Use the **[TestCase]** attribute to define a method as a TestCase.

```cs
namespace Examples;

using GdUnit4;
using static GdUnit4.Assertions;

[TestSuite]
public class GdUnitExampleTest
{
   [TestCase]
   public void StringToLower() {
      AssertString("AbcD".ToLower()).IsEqual("abcd");
   }
}
```

We named it **StringToLower()** because we test the `ToLower` function on a string.<br>
{% endtab %}
{% endtabs %}

## Using Parameterized TestCases

See [Testing with Parameterized TestCases]({{site.baseurl}}/advanced_testing/paramerized_tests/#testing-with-parameterized-testcases)<br>

## Using Fuzzers on Tests

See [Testing with Fuzzers]({{site.baseurl}}/advanced_testing/fuzzing/#testing-with-fuzzers)<br>

## TestCase Parameters

GdUnit allows you to define additional test parameters to have more control over the test execution.
{% tabs faq-test-case-attr %}
{% tab faq-test-case-attr GdScript %}

| Parameter                                                                                       | Description                                                                                                                         |
|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| [timeout]({{site.baseurl}}/testing/test-case/#timeout)                                          | Defines a custom timeout in milliseconds. By default, a TestCase will be interrupted after 5 minutes if the tests are not finished. |
| [do_skip]({{site.baseurl}}/advanced_testing/skip-tests/#skipping-individual-test-cases)         | Set to 'true' to skip the test. Conditional expressions are supported.                                                              |
| [skip_reason]({{site.baseurl}}/advanced_testing/skip-tests/#customizing-skip-reasons)           | Adds a comment why you want to skip this test.                                                                                      |
| [fuzzer]({{site.baseurl}}/advanced_testing/fuzzing/#testing-with-fuzzers)                       | Defines a fuzzer to provide test data.                                                                                              |
| [fuzzer_iterations]({{site.baseurl}}/advanced_testing/fuzzing/#using-fuzzers)                   | Defines the number of times a TestCase will be run using the fuzzer.                                                                |
| [fuzzer_seed]({{site.baseurl}}/advanced_testing/fuzzing/#using-fuzzers)                         | Defines a seed used by the fuzzer.                                                                                                  |
| [test_parameters]({{site.baseurl}}/advanced_testing/paramerized_tests/#parameterized-testcases) | Defines the TestCase dataset for parameterized tests.                                                                               |

{% include advice.html
content="To avoid warnings about unused arguments, use the underscore prefix `_` or use `@warning_ignore(“unused_parameter”)`.."
%}

{% endtab %}
{% tab faq-test-case-attr C# %}

| Parameter | Description                                                                                                                         |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Timeout   | Defines a custom timeout in milliseconds. By default, a TestCase will be interrupted after 5 minutes if the tests are not finished. |
| TestName  | Defines a custom TestCase name.                                                                                                     |
| Seed      | Defines a seed to provide test data.                                                                                                |

{% endtab %}
{% endtabs %}

### timeout

The **timeout** paramater sets the duration in milliseconds before a test case is interrupted. By default, a test case will be interrupted after 5 minutes
if it has not finished executing.
You can customize the default timeout value in the [GdUnit Settings]({{site.baseurl}}/first_steps/settings/#test-timeout-seconds).
A test case that is interrupted by a timeout is marked and reported as a failure.

{% tabs faq-test-case-attr-timeout %}
{% tab faq-test-case-attr-timeout GdScript %}
Sets the test execution timeout to 2s.

```gd
func test_with_timeout(_timeout := 2000):
   ...
```

💡 To avoid warnings about unused arguments, use the underscore prefix `_` or use `@warning_ignore(“unused_parameter”)`.

{% endtab %}
{% tab faq-test-case-attr-timeout C# %}
Sets the test execution timeout to 2s.

```cs
[TestCase(Timeout = 2000)]
public async Task ATestWithTimeout()
{
   ...
```

{% endtab %}
{% endtabs %}

### fuzzer parameters

To learn how to use the fuzzer parameter, please refer to the [Using Fuzzers]({{site.baseurl}}/advanced_testing/fuzzing/#using-fuzzers) section

### test_parameters

To learn how to use parameterized tests, please refer to the
[Parameterized TestCases]({{site.baseurl}}/advanced_testing/paramerized_tests/#testing-with-parameterized-testcases) section

---

## When to Use Fail Fast with Multiple Assertions {#multiple-assertions-fail-fast}

{% include advice.html
content="Since GdScript does not have exceptions, we need to manually define an exit strategy to fail fast and avoid unnecessary test execution."
%}
When you have multiple assertions in a single test case, it's important to consider using fail fast techniques to avoid unnecessary test execution
and get clearer failure reports.

### Why Use Fail Fast?

By default, GdUnit4 will continue executing all assertions in a test case even after one fails.
While this can provide comprehensive feedback about all failing conditions, it can also lead to:

- **Cascading failures**: Later assertions may fail because earlier ones didn't establish the expected state
- **Misleading error messages**: Subsequent failures might not represent real issues but rather consequences of the first failure
- **Debugger interruptions**: In debug mode, accessing properties on null objects will cause the debugger to break with runtime errors,
    stopping test execution unexpectedly
- **Longer execution time**: Unnecessary processing when the test has already failed
- **Cluttered output**: Multiple failure messages when only the first one is relevant

### Example Without Fail Fast

```gd
func test_player_setup():
    var player = create_player()
    
    # If this fails, the following assertions may not make sense
    assert_object(player).is_not_null()
    
    # In debug mode: debugger will break here with null reference error if player is null
    # In release mode: will continue and show confusing assertion failure messages
    assert_str(player.name)\
        .is_equal("Hero")\
        .starts_with("H")
    assert_int(player.health).is_equal(100)
    assert_bool(player.is_alive()).is_true()
```

### Example With Fail Fast

```gd
func test_player_setup():
    var player = create_player()
    
    # Check critical precondition first
    assert_object(player).is_not_null()
    if is_failure():
        return
    
    # Now we can safely test player properties using fluent syntax
    assert_str(player.name)\
        .is_equal("Hero")\
        .starts_with("H")
    if is_failure():
        return
        
    assert_int(player.health)\
        .is_equal(100)\
        .is_greater(0)
    if is_failure():
        return
        
    assert_bool(player.is_alive()).is_true()
```

### Using fail() for Complex Conditions

Sometimes you need to fail based on complex logic that can't be expressed with standard assertions:

```gd
func test_game_state_validation():
    var game_state = get_current_game_state()
    
    # Complex validation that requires custom logic
    if game_state.level > 10 and game_state.player_health <= 0 and not game_state.has_revival_item:
        fail("Invalid game state: Player cannot survive level 10+ with 0 health and no revival items")
        return
    
    # Continue with standard assertions using fluent syntax
    assert_that(game_state.is_valid()).is_true()
    if is_failure():
        return
        
    assert_int(game_state.score)\
        .is_greater_equal(0)\
        .is_less(1000000)
```

### Best Practices

1. **Use fail fast for dependent assertions**: When later assertions depend on earlier ones being true
2. **Check critical preconditions first**: Validate that objects exist and are in the expected state before testing their properties
3. **Use fail() for complex conditions**: When standard assertions can't express the validation logic you need
4. **Keep tests focused**: Consider splitting complex test cases with many assertions into smaller, more focused tests
