---
layout: default
title: Argument Matchers
parent: Advanced Testing
nav_order: 8
---

# Argument Matchers

## Definition

GdUnit4 provides a set of argument matchers designed to facilitate testing of function calls with specific argument types.
Argument matchers allow you to verify the behavior of a function call without needing to specify the exact argument value(s).
This is particularly useful when you're interested in verifying the type of argument passed to a function rather than its exact value.

Using argument matchers enhances the flexibility and expressiveness of your tests by allowing you to focus on the relevant aspects of function behavior.
{% include advice.html
content="Argument Matchers are currently only supported for GdScripts."
%}

### Usage

Argument matchers can be employed in various scenarios, such as:

1. **Assert Functions:** When verifying assertions and not interested in the exact value:
   ```gd
   # Verifies that the value is a variant integer
   assert_that(100).is_equal(any_int())
   # This check will fail as the value is not a boolean
   assert_that(100).is_equal(any_bool())
   ```

2. **Assert Signal:** When you're only interested in whether a signal is emitted, regardless of its arguments:
   ```gd
   # Waits until 'test_signal_counted' is emitted with any integer argument (variadic syntax since v6.1)
   await assert_signal(signal_emitter).is_emitted("test_signal_counted", any_int())
   # Waits until 'item_added' is emitted with any String name and exactly item_id=42
   await assert_signal(signal_emitter).is_emitted("item_added", any_string(), 42)
   ```

3. **Mock Verification:** When verifying function calls with specific argument types:
   ```gd
   # Verifies that the function `set_message` is called twice with any string argument
   verify(mock, 2).set_message(any_string())
   ```

4. **Any Matcher:**
    In this example using the `any()` matcher allows you to focus on the number of function calls without concerning yourself with the specific
    value of the argument is passed.
    ```gd
    # Verifies that the function `set_message` is called twice with any argument
    verify(mock, 2).set_message(any())
    ```

---

### Argument Matcher Overview

The following matchers are available:<br>

|Argument Matcher|Description|
|---|---|
|any | Argument matcher to match any argument|
|any_aabb | Argument matcher to match any AABB value |
|any_array | Argument matcher to match any Array value |
|any_basis | Argument matcher to match any Basis value |
|any_bool | Argument matcher to match any boolean value |
|any_class | Argument matcher to match any instance of given class |
|any_color | Argument matcher to match any Color value |
|any_dictionary | Argument matcher to match any Dictionary value |
|any_float | Argument matcher to match any float value |
|any_int | Argument matcher to match any integer value |
|any_node_path | Argument matcher to match any NodePath value |
|any_object | Argument matcher to match any Object value |
|any_packed_byte_array | Argument matcher to match any PackedByteArray value |
|any_packed_color_array | Argument matcher to match any PackedColorArray value |
|any_packed_float32_array | Argument matcher to match any PackedFloat32Array value |
|any_packed_float64_array | Argument matcher to match any PackedFloat64Array value |
|any_packed_int32_array | Argument matcher to match any PackedInt32Array value |
|any_packed_int64_array | Argument matcher to match any PackedInt64Array value |
|any_packed_string_array | Argument matcher to match any PackedStringArray value |
|any_packed_vector2_array | Argument matcher to match any PackedVector2Array value |
|any_packed_vector3_array | Argument matcher to match any PackedVector3Array value |
|any_plane | Argument matcher to match any Plane value |
|any_quat | Argument matcher to match any Quaternion value |
|any_rect2 | Argument matcher to match any Rect2 value |
|any_rid | Argument matcher to match any RID value |
|any_string | Argument matcher to match any string value |
|any_transform_2d | Argument matcher to match any Transform2D value |
|any_transform_3d | Argument matcher to match any Transform3D value |
|any_vector | Argument matcher to match any Vector typed value |
|any_vector2 | Argument matcher to match any Vector2 value |
|any_vector2i | Argument matcher to match any Vector2i value |
|any_vector3 | Argument matcher to match any Vector3 value |
|any_vector3i | Argument matcher to match any Vector3i value |
|any_vector4 | Argument matcher to match any Vector4 value |
|any_vector4i | Argument matcher to match any Vector3i valu |

---

## Build your own custom Argument Matcher

You can write your own argument matcher if necessary. You can do this by extend from class **GdUnitArgumentMatcher** and implement the **is_match** function.

```gd
# base class of all argument matchers
class_name GdUnitArgumentMatcher
extends Reference

    # the fuction you have to override in your custom matcher
    func is_match(value) -> bool:
        return true
```

Here is a simple example of how to write your own argument matcher.<br>
```gd
# a simple class we want to test
class_name MyClass
extends Reference

    var _value:int

    func set_value(value :int):
        _value = value
```

The custom argument matcher:
```gd
class PeekMatcher extends GdUnitArgumentMatcher:
    var _peek :int
    
    func _init(peek :int):
        _peek = peek

    func is_match(value) -> bool:
        return value > _peek
```
Just to clarify, the `PeekMatcher` class is an implementation of the `GdUnitArgumentMatcher` abstract class, which provides the **is_match()** function.
In this example, the is_match method checks if the argument is greater than the `_peek` value passed in the constructor.

The test:
```gd
func test_custom_matcher():
    # we mock the custom class here
    var mocked_test_class :MyClass = mock(MyClass)
    
    mocked_test_class.set_value(1000)
    mocked_test_class.set_value(1001)
    mocked_test_class.set_value(1002)
    mocked_test_class.set_value(2002)
    
    # counts 1001, 1002, 2002 = 3 times
    verify(mocked_test_class, 3).set_value(PeekMatcher.new(1000))
    # counts 2002 = 1 times
    verify(mocked_test_class, 1).set_value(PeekMatcher.new(2000))
```
Then in the test, we create a mocked_test_class object and call its **set_value** method with different arguments.
Finally, we use verify to check if the method was called with arguments that meet the condition of the PeekMatcher.
