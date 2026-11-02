---
layout: default
title: Function/Method Assert
parent: Asserts
---

# Function/Method Assertions

## ***!Deprecated!***

An assertion tool that waits until a certain time for an expected function return value. When the timeout is reached, the assertion fails with a timeout error.
The default timeout of 2s can be overridden by wait_until(<time in ms>)

{% tabs assert-function-overview %}
{% tab assert-function-overview GdScript %}
**GdUnitFuncAssert**<br>

| Function                                                               | Description                                                             |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| [is_null]({{site.baseurl}}/testing/assert-function/#is_null)           | Verifies that the current value is null.                                |
| [is_not_null]({{site.baseurl}}/testing/assert-function/#is_not_null)   | Verifies that the current value is not null.                            |
| [is_equal]({{site.baseurl}}/testing/assert-function/#is_equal)         | Verifies that the current value is equal to expected one.               |
| [is_not_equal]({{site.baseurl}}/testing/assert-function/#is_not_equal) | Verifies that the current value is not equal to expected one.           |
| [is_true]({{site.baseurl}}/testing/assert-function/#is_true)           | Verifies that the current value is true.                                |
| [is_false]({{site.baseurl}}/testing/assert-function/#is_false)         | Verifies that the current value is false.                               |
| [wait_until]({{site.baseurl}}/testing/assert-function/#wait_until)     | Sets the timeout in ms to wait the function returnd the expected value. |

{% endtab %}

{% tab assert-function-overview C# %}

Not supported!

{% endtab %}
{% endtabs %}

---

## Function/Method Assert Examples

## is_equal

Waits until the return value of the function is equal to the expected value until the wait time has expired.
```gd
func assert_func(<instance :Object>, <func_name :String>, [args :Array]).is_equal(<expected>) -> GdUnitAssert
```
```gd
# waits until get_count() returns 9 or fails after default timeout of 2s
await assert_func(self, "get_count").is_equal(9.0)
```

## is_not_equal

Waits until the return value of the function is NOT equal to the expected value until the wait time has expired.
```gd
func assert_func(<instance :Object>, <func_name :String>, [args :Array]).is_not_equal(<expected>) -> GdUnitAssert
```
```gd
# waits until get_state() returns different value than "idle" or fails after default timeout of 2s
await assert_func(self, "get_state").is_not_equal("idle")
```

## is_null

Waits until the return value of the function is NULL until the wait time has expired.
```gd
func assert_func(<instance :Object>, <func_name :String>, [args :Array]).is_null() -> GdUnitAssert
```
```gd
# waits until get_parent() returns NULL or fails after default timeout of 2s
await assert_func(self, "get_parent").is_null()
```

## is_not_null

Waits until the return value of the function is NOT NULL until the wait time has expired.
```gd
func assert_func(<instance :Object>, <func_name :String>, [args :Array]).is_not_null() -> GdUnitAssert
```
```gd
# waits until get_parent() returns not NULL or fails after default timeout of 2s
await assert_func(self, "get_parent").is_not_null()
```

## is_true

Waits until the return value of the function is true until the wait time has expired.
```gd
func assert_func(<instance :Object>, <func_name :String>, [args :Array]).is_true() -> GdUnitAssert
```
```gd
# waits until has_parent() returns true or fails after default timeout of 2s
await assert_func(self, "has_parent").is_true()
```

## is_false

Waits until the return value of the function is false until the wait time has expired.
```gd
func assert_func(<instance :Object>, <func_name :String>, [args :Array]).is_false() -> GdUnitAssert
```
```gd
# waits until has_parent() returns false or fails after default timeout of 2s
await assert_func(self, "has_parent").is_false()
```

## wait_until

Sets the timeout in ms to wait the function returnd the expected value, if the time over a failure is emitted
```gd
func assert_func(<instance :Object>, <func_name :String>, [args :Array]).wait_until(<timeout>) -> GdUnitFuncAssert
```
```gd
# waits until has_parent() returns false or fails after custom timeout of 5s
await assert_func(self, "has_parent").wait_until(5000).is_false()
```
