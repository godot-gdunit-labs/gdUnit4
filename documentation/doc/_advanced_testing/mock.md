---
layout: default
title: Mocking
parent: Advanced Testing
nav_order: 6
---

# Mocking / Mocks

{% include advice.html
content="This Mocking implementation is only available for GDScripts, for C# you can use already existing mocking frameworks
like <a href='https://github.com/devlooped/moq' target='_blank'><b>Moq</b></a>"
%}

## Definition

A mocked object is a dummy implementation of a class, in which you define the expected output of certain function calls.
Mocked objects are configured to perform a specific behavior during testing, and they track all function calls and their parameters to the mocked object.

This type of testing is sometimes referred to as behavior testing. Behavior testing does not check the result of a function call,
but instead checks that a function is called with the correct parameters.

For more detailed information about mocks, [read this](https://en.wikipedia.org/wiki/Mock_object){:target="_blank"}

---

Here an small example to mock the class `TestClass`:
{% tabs mock-example %}
{% tab mock-example Example Class %}

```gd
class_name TestClass
extends Node

    func message() -> String:
        return "a message"
```

{% endtab %}
{% tab mock-example Mock (RETURN_DEFAULTS) %}

```gd
func test_mock():
    # create a mock for class 'TestClass' by mock mode `RETURN_DEFAULTS` (default)
    var mock := mock(TestClass) as TestClass

    # inital the mock will return a default value, for string means an empty string
    assert_str(mock.message()).is_empty()

    # new we override the return value for `message()` to return 'custom message'
    do_return("custom message").on(mock).message()

    # the next call of `message()` will now return 'custom message'
    assert_str(mock.message()).is_equal("custom message")
```

{% endtab %}
{% tab mock-example Mock (CALL_REAL_FUNC) %}

```gd
func test_mock():
    # create a mock for class 'TestClass' using mode `CALL_REAL_FUNC`
    var mock := mock(TestClass, CALL_REAL_FUNC) as TestClass

    # inital the mock will return a original value (calles the real implementation)
    assert_str(mock.message()).is_equal("a message")

    # new we override the return value for `message()` to return 'custom message'
    do_return("custom message").on(mock).message()

    # the next call of `message()` will now return 'custom message'
    assert_str(mock.message()).is_equal("custom message")
```

{% endtab %}
{% endtabs %}

---

## How to use a Mock

{% include advice.html
content="Mocking core functions are not possible since Godot has improved the GDScript performance.<br> According to the Godot core developers,
overwriting core functions is no longer supported, so there is no way to mock or spy on core functions anymore."
%}

To mock a class, you only need to use **mock(\<class_name\>)** or **mock(\<resource_path\>)** to create a mocked object instance using
the given class name or path. A mocked instance is marked for auto-free, so you don't need to free it manually.

If you want to create a mock by class name, you have to define the class_name in your class. Otherwise, the class must be mocked by resource path.

```gd
# Example class
class_name TestClass
extends Node
    ...
```

```gd
# Create a mocked instance of the class 'TestClass'
var mock := mock(TestClass)
# Or create it by using the full resource path if no `class_name` is defined
var mock := mock("res://project_name/src/TestClass.gd")
```

You can also mock inner classes by using **mock(\<class_name\>)** with some preconditions.

## How and Why to Overwrite Functions

With a mock, you can override a specific function to return custom values.
This allows you to simulate a function and return an expected value without calling the actual implementation.

To override a function on your mocked class, use **do_return(\<value\>)** to specify the return value.

<b>Syntax</b>
`do_return(<value>)` `.on(<mock>)` `.<function([args])>)`

1. Mock your class.
2. Define the return value.
3. Override the function you want to mock using .on(<mock>) and .function_name([args]).

```gd
# Create the mock
var node := mock(Node) as Node
# Define the return value on the mock `node` for function `get_name` 
do_return("NodeX").on(node).get_name()
```

Here is an example:

```gd
# Create a mock from class `Node`
var mocked_node := mock(Node) as Node

# It returns 0 by default
mocked_node.get_child_count()
# Override function `get_child_count` to return 10
do_return(10).on(mocked_node).get_child_count()
# The next call of `get_child_count` will now return 10
mocked_node.get_child_count()

# It returns 'null' by default
var node = mocked_node.get_child(0)
assert_object(node).is_null()

# Override function `get_child` to return a mocked 'Camera' for child index 0
do_return(mock(Camera)).on(mocked_node).get_child(0)
# And a mocked 'Area' for child index 1
do_return(mock(Area)).on(mocked_node).get_child(1)

# It now returns the Camera node at index 0
var node0 = mocked_node.get_child(0)
assert_object(node0).is_instanceof(Camera)
# And the Area node at index 1
var node1 = mocked_node.get_child(1)
assert_object(node1).is_instanceof(Area)
```

---

## Verification of Function Calls

A mock keeps track of all the function calls and their arguments. Use **verify()** on the mock to check if a certain function
is called and how often it was called.

| Function                                                                                           | Description                                                                        |
| -------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| [verify]({{site.baseurl}}/advanced_testing/mock/#verify)                                           | Verifies that certain behavior happened at least once or an exact number of times. |
| [verify_no_interactions]({{site.baseurl}}/advanced_testing/mock/#verify_no_interactions)           | Verifies that no interactions happened on the mock.                                |
| [verify_no_more_interactions]({{site.baseurl}}/advanced_testing/mock/#verify_no_more_interactions) | Verifies that the given mock has no unverified interactions.                       |
| [reset]({{site.baseurl}}/advanced_testing/mock/#reset)                                             | Resets the saved function call counters on a mock.                                 |

### verify

The verify() method is used to verify that a function was called a certain number of times.
It takes two arguments: the mock instance and the expected number of times the function should have been called.
You can also use argument matchers to verify that specific arguments were passed to the function.

```gd
verify(<mock>, <times>).function(<args>)
```

Here's an example:

```gd
var mocked_node :Node = mock(Node)

# Verify we have no interactions currently on this instance
verify_no_interactions(mocked_node)

# Call with different arguments
mocked_node.set_process(false) # 1 times
mocked_node.set_process(true) # 1 times
mocked_node.set_process(true) # 2 times

# Verify how often we called the function with different argument 
verify(mocked_node, 1).set_process(false)# in sum one time with false
verify(mocked_node, 2).set_process(true) # in sum two times with true

# Verify will fail because we expect the function `set_process(true)` to be called 3 times but it was only called 2 times
verify(mocked_node, 3).set_process(true)
```

### verify_no_interactions

Verifies that no interactions happened on the mock.

```gd
verify_no_interactions(<mock>)
```

Here's an example:

```gd
var mocked_node := mock(Node) as Node

# Test that we have no initial interactions on this mock
verify_no_interactions(mocked_node)

# Interact by calling `get_name()`
mocked_node.get_name()

# Now this verification will fail because we have interacted on this mock by calling `get_name`
verify_no_interactions(mocked_node)
```

### verify_no_more_interactions

This method checks if the specified mock has any unverified interactions.
If the mock has recorded more interactions than you verified with **verify()**, an error is reported.

```gd
verify_no_more_interactions(<mock>)
```

Here's an example:

```gd
var mocked_node := mock(Node) as Node

# Interact on two functions 
mocked_node.is_a_parent_of(null)
mocked_node.set_process(false)

# Verify that the mock interacts as expected
verify(mocked_node).is_a_parent_of(null)
verify(mocked_node).set_process(false)

# Check that there are no further interactions with the mock
verify_no_more_interactions(mocked_node)

# Simulate an unexpected interaction with `set_process`
mocked_node.set_process(false)

# Verify that there are no further interactions with the mock
# and that the previous unexpected interaction is detected (the test will fail here)
verify_no_more_interactions(mocked_node)
```

In this example, the **verify_no_more_interactions()** method is used to check that no more interactions occur after the initial two interactions.
The second call to **set_process(false)** is not expected and thus will result in a failure of the test.

### reset

Resets the recorded function interactions of the given mock.<br>
Sometimes we want to reuse an already created mock for different test scenarios and have to reset the recorded interactions.

```gd
reset(<mock>)
```

Here's an example:

```gd
var mocked_node :Node = mock(Node)

# First, we test by interacting with two functions 
mocked_node.is_a_parent_of(null)
mocked_node.set_process(false)

# Verify if the interactions were recorded; at this point, two interactions are recorded
verify(mocked_node).is_a_parent_of(null)
verify(mocked_node).set_process(false)

# Now, we want to test a different scenario and we need to reset the current recorded interactions
reset(mocked_node)
# Verify that the previously recorded interactions have been removed
verify_no_more_interactions(mocked_node)

# Continue testing
mocked_node.set_process(true)
verify(mocked_node).set_process(true)
verify_no_more_interactions(mocked_node)
```

---

## Mock Working Modes

When creating a mock, you can specify the working mode that defines the return value handling of function calls for a mock.<br>
The available working modes are:

* **RETURN_DEFAULTS** (default)<br>
    This working mode returns default values for functions that have not been stubbed.
    For example, it returns null for functions that return objects and 0 for functions that return integers.
    You can use this mode if you only want to test specific interactions with the mock and do not care about the return values of other functions.

    The default return values for various types are:

    | Type               | Default value        |
    | ------------------ | -------------------- |
    | TYPE_NIL           | null                 |
    | TYPE_BOOL          | false                |
    | TYPE_INT           | 0                    |
    | TYPE_REAL          | 0.0                  |
    | TYPE_STRING        | ""                   |
    | TYPE_VECTOR2       | Vector2.ZERO         |
    | TYPE_RECT2         | Rect2()              |
    | TYPE_VECTOR3       | Vector3.ZERO         |
    | TYPE_TRANSFORM2D   | Transform2D()        |
    | TYPE_PLANE         | Plane()              |
    | TYPE_QUAT          | Quat()               |
    | TYPE_AABB          | AABB()               |
    | TYPE_BASIS         | Basis()              |
    | TYPE_TRANSFORM     | Transform()          |
    | TYPE_COLOR         | Color()              |
    | TYPE_NODE_PATH     | NodePath()           |
    | TYPE_RID           | RID()                |
    | TYPE_OBJECT        | null                 |
    | TYPE_DICTIONARY    | Dictionary()         |
    | TYPE_ARRAY         | Array()              |
    | TYPE_RAW_ARRAY     | PackedByteArray()    |
    | TYPE_INT_ARRAY     | PackedIntArray()     |
    | TYPE_REAL_ARRAY    | PackedRealArray()    |
    | TYPE_STRING_ARRAY  | PackedStringArray()  |
    | TYPE_VECTOR2_ARRAY | PackedVector2Array() |
    | TYPE_VECTOR3_ARRAY | PackedVector3Array() |
    | TYPE_COLOR_ARRAY   | PackedColorArray()   |

    You can customize these default values by configuring the mock object to return a different value for unconfigured function calls using the<br>
    `when(<mock>).<function>().thenReturn(<value>)` method.

* **CALL_REAL_FUNC**<br>
    This working mode calls the real function implementation instead of returning a default value.
    You can use this mode if you want to test the interaction between the mock and the real function implementation.

* **RETURN_DEEP_STUB** (not yet implemented!)<br>
    This working mode creates a deep stub for the mock object. It returns another mock object for every function call,
    allowing you to chain function calls on the mock object. You can use this mode if you want to test complex function interactions with the mock.

It's important to choose the right working mode for your test scenario to ensure that you are testing the intended behavior of the system under test.

Here's an example:
{% tabs mock-modes %}
{% tab mock-modes RETURN_DEFAULTS %}

If *RETURN_DEFAULTS* is used, all functions will return [default values]({{site.baseurl}}/advanced_testing/mock/#default-values) for a mocked class.

```gd
var mock := mock(TestClass) as TestClass

# Returns a default value (for String an empty value)
assert_str(mock.message()).is_equal("")
```

{% endtab %}
{% tab mock-modes CALL_REAL_FUNC %}

If *CALL_REAL_FUNC* is used, all functions will return the value provided by the real implementation for a mocked class.
Helpful when you only want to mock partial functions of a class.

```gd
# build a mock with mode CALL_REAL_FUNC
var mock := mock(TestClass, CALL_REAL_FUNC) as TestClass

# returns the real implementation value
assert_str(mock.message()).is_equal("a message")

# set a the return value to 'custom message' for the function message()
do_return("custom message").on(mock).message()

# now the function message will return 'custom message'
assert_str(mock.message()).is_equal("custom message")
```

{% endtab %}
{% tab mock-modes RETURN_DEEP_STUB %}
***WORK IN PROGRESS -- NOT SUPPORTED YET!!!***

If *RETURN_DEEP_STUB* is used, all unoverridden function calls return the value provided by the real implementation for a mocked class.
Use to return a default value for build-in types or a fully mocked value for Object types.

```gd
# build a mock with mode RETURN_DEEP_STUB
var mock := mock(TestClass, RETURN_DEEP_STUB) as TestClass

# returns a default value 
assert_str(mock.message()).is_equal("")

# returns a mocked Path value
assert_object(mock.path()).is_not_null()
```

{% endtab %}
{% endtabs %}

---

## Argument Matchers and mocks

Argument matchers allow you to simplify the verification of function calls by verifying function arguments based on their type or class.
This is particularly useful when working with mocks because you can use argument matchers to verify function calls without specifying the exact argument values.

For example, instead of verifying that a function was called with a specific boolean argument value, you can use the **any_bool()** argument matcher
to verify that the function was called with any boolean value. Here's an example:

```gd
    var mocked_node :Node = mock(Node)
    
    # Call the function with different arguments
    mocked_node.set_process(false) # Called 1 time
    mocked_node.set_process(true) # Called 1 time
    mocked_node.set_process(true) # Called 2 times
    
    # Verify that the function was called with any boolean value 3 times
    verify(mocked_node, 3).set_process(any_bool())
```

For more details on how to use argument matchers, please see the [Argument Matchers]({{site.baseurl}}/advanced_testing/argument_matchers) section.
