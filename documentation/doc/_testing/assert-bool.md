---
layout: default
title: Boolean Assert
parent: Asserts
---

# Boolean Assertions

An assertion tool to verify boolean values.

{% tabs assert-bool %}
{% tab assert-bool GdScript %}
**GdUnitBoolAssert**<br>

| Function                                                           | Description                                                    |
| ------------------------------------------------------------------ | -------------------------------------------------------------- |
| [is_true]({{site.baseurl}}/testing/assert-bool/#is_true)           | Verifies that the current value is true.                       |
| [is_false]({{site.baseurl}}/testing/assert-bool/#is_false)         | Verifies that the current value is false.                      |
| [is_equal]({{site.baseurl}}/testing/assert-bool/#is_equal)         | Verifies that the current value is equal to the given one.     |
| [is_not_equal]({{site.baseurl}}/testing/assert-bool/#is_not_equal) | Verifies that the current value is not equal to the given one. |

{% endtab %}
{% tab assert-bool C# %}
**IBoolAssert**<br>

| Function                                                         | Description                                                    |
| ---------------------------------------------------------------- | -------------------------------------------------------------- |
| [IsTrue]({{site.baseurl}}/testing/assert-bool/#is_true)          | Verifies that the current value is true.                       |
| [IsFalse]({{site.baseurl}}/testing/assert-bool/#is_false)        | Verifies that the current value is false.                      |
| [IsEqual]({{site.baseurl}}/testing/assert-bool/#is_equal)        | Verifies that the current value is equal to the given one.     |
| [IsNotEqual]({{site.baseurl}}/testing/assert-bool/#is_not_equal) | Verifies that the current value is not equal to the given one. |

{% endtab %}
{% endtabs %}

---

## Boolean Assert Examples

### is_true

Verifies that the current value is true.

{% tabs assert-bool-is_true %}
{% tab assert-bool-is_true GdScript %}

```gd
func assert_bool(<current>).is_true() -> GdUnitBoolAssert
```
```gd
# this assertion succeeds
assert_bool(true).is_true()

# this assertion fails because the value is false and not true
assert_bool(false).is_true()
```

{% endtab %}
{% tab assert-bool-is_true C# %}

```cs
public static IBoolAssert AssertThat(<current>).IsTrue()
```
```cs
// this assertion succeeds
AssertThat(true).IsTrue();

// this assertion fails because the value is false and not true
AssertThat(false).IsTrue();
```

{% endtab %}
{% endtabs %}

### is_false

Verifies that the current value is false.
{% tabs assert-bool-is_false %}
{% tab assert-bool-is_false GdScript %}

```gd
func assert_bool(<current>).is_false() -> GdUnitBoolAssert
```
```gd
# this assertion succeeds
assert_bool(false).is_false()

# this assertion fails because the value is true and not false
assert_bool(true).is_false()
```

{% endtab %}
{% tab assert-bool-is_false C# %}

```cs
public static IBoolAssert AssertThat(<current>).IsFalse();
```
```cs
// this assertion succeeds
AssertThat(false).IsFalse();

// this assertion fails because the value is true and not false
AssertThat(true).IsFalse();
```

{% endtab %}
{% endtabs %}

### is_equal

Verifies that the current value is equal to the given one.
{% tabs assert-bool-is_equal %}
{% tab assert-bool-is_equal GdScript %}

```gd
func assert_bool(<current>).is_equal(<expected>) -> GdUnitBoolAssert
```
```gd
# this assertion succeeds
assert_bool(false).is_equal(false)

# this assertion fails because the value is false and not true
assert_bool(false).is_equal(true)
```

{% endtab %}
{% tab assert-bool-is_equal C# %}

```cs
public static IBoolAssert AssertThat(<current>).IsEqual(<expected>);
```
```cs
// this assertion succeeds
AssertThat(false).IsEqual(false);

// this assertion fails because the value is false and not true
AssertThat(false).IsEqual(true);
```

{% endtab %}
{% endtabs %}

### is_not_equal

Verifies that the current value is not equal to the given one.
{% tabs assert-bool-is_not_equal %}
{% tab assert-bool-is_not_equal GdScript %}

```gd
func assert_bool(<current>).is_not_equal(<expected>) -> GdUnitBoolAssert
```
```gd
# this assertion succeeds
assert_bool(false).is_not_equal(true)

# this assertion fails because the value is false and should not be false
assert_bool(false).is_not_equal(false)
```

{% endtab %}
{% tab assert-bool-is_not_equal C# %}

```cs
public static IBoolAssert AssertThat(<current>).IsNotEqual(<expected>);
```
```cs
// this assertion succeeds
AssertThat(false).IsNotEqual(true);

// this assertion fails because the value is false and should not be false
AssertThat(false).IsNotEqual(false);
```

{% endtab %}
{% endtabs %}
