---
layout: default
title: Getting Started
nav_order: 5
---

# Getting Started with GDScript Tests

## Before You Start

Create a new folder called **first_steps** in your project's root directory and copy the following class into it.
It should be located at `res://first_steps/test_person.gd`.
{% tabs first-step-test_class %}
{% tab first-step-test_class test_person.gd %}
```gd
class_name TestPerson
extends Node

var _first_name :String
var _last_name :String

func _init(first_name :String, last_name :String):
    _first_name = first_name
    _last_name = last_name

func full_name() -> String:
    return _first_name + " " + _last_name
```
{% endtab %}
{% endtabs %}

## Creating a Test

To create a test in GdUnit4, you can use the built-in "Create Test" function. Follow these steps:

1. Open the script that you want to test.
2. Right-click on the function that you want to create a test for.
3. Click on "Create Test" from the context menu.

![context-menu]({{site.baseurl}}/assets/images/first-steps/context-menu.png){:.centered}

We have selected the full_name function to generate a test for it. The test has been automatically created using the built-in **Create Test** function.
Congratulations, you have now created your first test!<br>
More detailed information about naming conventions and the definition of test cases [can be found here]({{site.baseurl}}/testing/test-case/#testcase-definition)

The generated test case should look like this:
![generated-test-suite]({{site.baseurl}}/assets/images/first-steps/generated-test-suite.png){:.centered}

## Execute Your Test

After creating your first test, you can execute it by selecting it in the editor with the right mouse click and then opening the context menu
to click on **Run Tests** or **Debug Tests**.
![run-selected-test-case]({{site.baseurl}}/assets/images/first-steps/run-selected-test-case.png){:.centered}

The test run is visualized in the GdUnit4 inspector, allowing you to inspect the test results.
![first-test-run-result]({{site.baseurl}}/assets/images/first-steps/first-test-run-result.png){:.centered}

As you can see, your first test has resulted in a failure: "Test not implemented!" This is because a generated test first fails with this message since
the assertion `assert_not_yet_implemented()` is used in the test by default.

The failure report message are:
```gd
line 13: Test not implemented!
```

You can double-click on the failed test to jump directly to the test failure.
![jump-to-failure]({{site.baseurl}}/assets/images/first-steps/jump-to-failure.png){:.centered}

## Complete Your First Test

To complete your test, you must specify what you want to test by using assertions. GdUnit provides a large number of assert functions to compare
an actual value with an expected value.

In this case, we did a test for the function `full_name()` which has a return type of String. To verify the return value of the function,
we can use the `assert_str()` function and replace the `assert_not_yet_implemented()` in our test with it:

{% tabs first-step-test_case %}
{% tab first-step-test_case Using resource path %}
```gd
func test_full_name() -> void:
   var person = load("res://first_steps/test_person.gd").new("King", "Arthur")
   assert_str(person.full_name()).is_equal("King Arthur")
```
{% endtab %}
{% tab first-step-test_case Using class name %}
```gd
func test_full_name() -> void:
   var person := TestPerson.new("King", "Arthur")
   assert_str(person.full_name()).is_equal("King Arthur")
```
{% endtab %}
{% endtabs %}

Now, run the test again by pressing the **ReRun Debug** button in the inspector.<br>
![rerun-test]({{site.baseurl}}/assets/images/first-steps/rerun-test.png){:.centered}
For more details about the inspector buttons, see [Button Bar]({{site.baseurl}}/first_steps/inspector/#button-bar)

The test failure is fixed but now we get a warning!

![rerun-test-result]({{site.baseurl}}/assets/images/first-steps/rerun-test-result.png){:.centered}

The warning message "Detected <1> orphan nodes during test execution" indicates that we have forgotten to release an object.
It means that we still have to release the used object (in this case, TestPerson) after the test to avoid memory leaks.

To release objects manually, we can use the `free()` function of the object. Another way is to use the included `auto_free` tool,
which automatically releases all allocated objects at the end of a test.

{% tabs first-step-orphan %}
{% tab first-step-orphan free() %}
```gd
func test_full_name() -> void:
    var person := TestPerson.new("King", "Arthur")
    assert_str(person.full_name()).is_equal("King Arthur")
    person.free()
```
{% endtab %}
{% tab first-step-orphan auto_free() %}
```gd
func test_full_name() -> void:
    var person :TestPerson = auto_free(TestPerson.new("King", "Arthur"))
    assert_str(person.full_name()).is_equal("King Arthur")
```
{% endtab %}
{% endtabs %}

GdUnit offers a wide range of [Asserts]({{site.baseurl}}/testing/assert/) for all basic built-in types and much more.
A collection of tests is called a Test Suite in GdUnit.<br>
You can find more details about creating [Test Setup/Teardown]({{site.baseurl}}/testing/hooks).

Now, run your test again and it should complete successfully.<br>
![fixed-rerun-test-result]({{site.baseurl}}/assets/images/first-steps/fixed-rerun-test-result.png){:.centered}

<h2>Congratulations on successfully writing your first test!</h2>
