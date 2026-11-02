---
layout: default
title: Vector Assert
parent: Asserts
---

# Vector Assertions

An assertion tool to verify Vector values, supports all Godot Vector types.

{% tabs assert-vec-overview %}
{% tab assert-vec-overview GdScript %}
**GdUnitVectorAssert**<br>

| Function                                                                     | Description                                                                      |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [is_null]({{site.baseurl}}/testing/assert-vector/#is_null)                   | Verifies that the current value is null.                                         |
| [is_not_null]({{site.baseurl}}/testing/assert-vector/#is_not_null)           | Verifies that the current value is not null.                                     |
| [is_equal]({{site.baseurl}}/testing/assert-vector/#is_equal)                 | Verifies that the current value is equal to the given one.                       |
| [is_not_equal]({{site.baseurl}}/testing/assert-vector/#is_not_equal)         | Verifies that the current value is not equal to the given one.                   |
| [is_equal_approx]({{site.baseurl}}/testing/assert-vector/#is_equal_approx)   | Verifies that the current and expected value are approximately equal.            |
| [is_less]({{site.baseurl}}/testing/assert-vector/#is_less)                   | Verifies that the current value is less than the given one.                      |
| [is_less_equal]({{site.baseurl}}/testing/assert-vector/#is_less_equal)       | Verifies that the current value is less than or equal the given one.             |
| [is_greater]({{site.baseurl}}/testing/assert-vector/#is_greater)             | Verifies that the current value is greater than the given one.                   |
| [is_greater_equal]({{site.baseurl}}/testing/assert-vector/#is_greater_equal) | Verifies that the current value is greater than or equal the given one.          |
| [is_between]({{site.baseurl}}/testing/assert-vector/#is_between)             | Verifies that the current value is between the given boundaries (inclusive).     |
| [is_not_between]({{site.baseurl}}/testing/assert-vector/#is_not_between)     | Verifies that the current value is not between the given boundaries (inclusive). |

{% endtab %}
{% tab assert-vec-overview C# %}
**IVector2Assert**<br>

| Function                                                                   | Description                                                                      |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [IsNull]({{site.baseurl}}/testing/assert-vector/#is_null)                  | Verifies that the current value is null.                                         |
| [IsNotNull]({{site.baseurl}}/testing/assert-vector/#is_not_null)           | Verifies that the current value is not null.                                     |
| [IsEqual]({{site.baseurl}}/testing/assert-vector/#is_equal)                | Verifies that the current value is equal to the given one.                       |
| [IsNotEqual]({{site.baseurl}}/testing/assert-vector/#is_not_equal)         | Verifies that the current value is not equal to the given one.                   |
| [IsEqualApprox]({{site.baseurl}}/testing/assert-vector/#is_equal_approx)   | Verifies that the current and expected value are approximately equal.            |
| [IsLess]({{site.baseurl}}/testing/assert-vector/#is_less)                  | Verifies that the current value is less than the given one.                      |
| [IsLessEqual]({{site.baseurl}}/testing/assert-vector/#is_less_equal)       | Verifies that the current value is less than or equal the given one.             |
| [IsGreater]({{site.baseurl}}/testing/assert-vector/#is_greater)            | Verifies that the current value is greater than the given one.                   |
| [IsGreaterEqual]({{site.baseurl}}/testing/assert-vector/#is_greater_equal) | Verifies that the current value is greater than or equal the given one.          |
| [IsBetween]({{site.baseurl}}/testing/assert-vector/#is_between)            | Verifies that the current value is between the given boundaries (inclusive).     |
| [IsNotBetween]({{site.baseurl}}/testing/assert-vector/#is_not_between)     | Verifies that the current value is not between the given boundaries (inclusive). |

{% endtab %}
{% endtabs %}

---

## Vector Assert Examples

### is_equal

Verifies that the current value is equal to the given one.
{% tabs assert-vec-is_equal %}
{% tab assert-vec-is_equal GdScript %}
```gd
func assert_vector(<current>).is_equal(<expected>) -> GdUnitVectorAssert
```
```gd
# this assertion succeeds
assert_vector(Vector2(1.1, 1.2)).is_equal(Vector2(1.1, 1.2))

# this assertion fails because part y of the vector 1.2 are not equal to 1.3
assert_vector(Vector2(1.1, 1.2)).is_equal(Vector2(1.1, 1.3))
```
{% endtab %}
{% tab assert-vec-is_equal C# %}
```cs
public static IVector2Assert AssertThat(Godot.Vector2 current).IsEqual(<expected>);
```
```cs
// this assertion succeeds
AssertThat(Vector2.One).IsEqual(Vector2.One);

// should fail because is NOT equal
AssertThat(Vector2.One).IsEqual(new Vector2(1.2f, 1.000001f));
```
{% endtab %}
{% endtabs %}

### is_not_equal

Verifies that the current value is not equal to the given one.
{% tabs assert-vec-is_not_equal %}
{% tab assert-vec-is_not_equal GdScript %}
```gd
func assert_vector(<current>).is_not_equal(<expected>) -> GdUnitVectorAssert
```
```gd
# this assertion succeeds
assert_vector(Vector2(1.1, 1.2)).is_not_equal(Vector2(1.1, 1.3))

# this assertion fails because both vectors are equal
assert_vector(Vector2(1.1, 1.2)).is_not_equal(Vector2(1.1, 1.2))
```
{% endtab %}
{% tab assert-vec-is_not_equal C# %}
```cs
public static IVector2Assert AssertThat(Godot.Vector2 current).IsNotEqual(<expected>);
```
```cs
// this assertion succeeds
AssertThat(Vector2.One).IsNotEqual(new Vector2(1.2f, 1.000001f));

// should fail because is equal
AssertThat(Vector2.One).IsNotEqual(Vector2.One);
```
{% endtab %}
{% endtabs %}

### is_equal_approx

Verifies that the current and expected value are approximately equal.
{% tabs assert-vec-is_equal_approx %}
{% tab assert-vec-is_equal_approx GdScript %}
```gd
func assert_vector(<current>).is_equal_approx(expected, approx) -> GdUnitVectorAssert
```
```gd
# this assertion succeeds
assert_vector(Vector2(0.996, 0.996)).is_equal_approx(Vector2.ONE, Vector2(0.004, 0.004))

# this will fail because the vector is out of approximated range
assert_vector(Vector2(1.005, 1)).is_equal_approx(Vector2.ONE, Vector2(0.004, 0.004))
```
{% endtab %}
{% tab assert-vec-is_equal_approx C# %}
```cs
public static IVector2Assert AssertThat(Godot.Vector2 current).IsEqualApprox(<expected>, <approx>);
```
```cs
// this assertion succeeds
AssertVec2(Vector2.One).IsEqualApprox(Vector2.One, new Vector2(0.004f, 0.004f));

// should fail because is NOT equal approximated
AssertVec2(new Vector2(1.005f, 1f)).IsEqualApprox(Vector2.One, new Vector2(0.004f, 0.004f));
```
{% endtab %}
{% endtabs %}

### is_less

Verifies that the current value is less than the given one.
{% tabs assert-vec-is_less %}
{% tab assert-vec-is_less GdScript %}
```gd
func assert_vector(<current>).is_less(<expected>) -> GdUnitVectorAssert
```
```gd
# this assertion succeeds
assert_vector(Vector2.ZERO.is_less(Vector2.ONE)
assert_vector(Vector2(1.1, 1.2)).is_less(Vector2(1.1, 1.3))

# this assertion fails because both vectors are equal
assert_vector(Vector2(1.1, 1.2)).is_less(Vector2(1.1, 1.2))
```
{% endtab %}
{% tab assert-vec-is_less C# %}
```cs
public static IVector2Assert AssertThat(Godot.Vector2 current).IsLess(<expected>);
```
```cs
// this assertion succeeds
AssertVec2(new Vector2(1.2f, 1.000001f)).IsLess(new Vector2(1.2f, 1.000002f));

// should fail because is NOT less is equal
AssertVec2(Vector2.One).IsLess(Vector2.One);
```
{% endtab %}
{% endtabs %}

### is_less_equal

Verifies that the current value is less than or equal the given one.
{% tabs assert-vec-is_less_equal %}
{% tab assert-vec-is_less_equal GdScript %}
```gd
func assert_vector(<current>).is_less_equal(<expected>) -> GdUnitVectorAssert
```
```gd
# this assertion succeeds
assert_vector(Vector2(1.1, 1.2)).is_less_equal(Vector2(1.1, 1.3))
assert_vector(Vector2(1.1, 1.2)).is_less_equal(Vector2(1.1, 1.2))

# this assertion fails because part y 1.3 is not less or equal to 1.2 
assert_vector(Vector2(1.1, 1.3)).is_less_equal(Vector2(1.1, 1.2))
```
{% endtab %}
{% tab assert-vec-is_less_equal C# %}
```cs
public static IVector2Assert AssertThat(Godot.Vector2 current).IsLessEqual(<expected>);
```
```cs
// this assertion succeeds
AssertVec2(new Vector2(1.2f, 1.000001f)).IsLessEqual(new Vector2(1.2f, 1.000001f));
AssertVec2(new Vector2(1.2f, 1.000001f)).IsLessEqual(new Vector2(1.2f, 1.000002f));

// should fail because is NOT less or equal
AssertVec2(Vector2.One).IsLessEqual(Vector2.Zero);
```
{% endtab %}
{% endtabs %}

### is_greater

Verifies that the current value is greater than the given one.
{% tabs assert-vec-is_greater %}
{% tab assert-vec-is_greater GdScript %}
```gd
func assert_vector(<current>).is_greater(<expected>) -> GdUnitVectorAssert
```
```gd
# this assertion succeeds
assert_vector(Vector2(1.1, 1.3)).is_greater(Vector2(1.1, 1.2))

# this assertion fails because both vectors are equal
assert_vector(Vector2(1.1, 1.2)).is_greater(Vector2(1.1, 1.2))
```
{% endtab %}
{% tab assert-vec-is_greater C# %}
```cs
public static IVector2Assert AssertThat(Godot.Vector2 current).IsGreater(<expected>);
```
```cs
// this assertion succeeds
AssertVec2(new Vector2(1.2f, 1.000002f)).IsGreater(new Vector2(1.2f, 1.000001f));

// should fail because zero is NOT greater than one
AssertVec2(Vector2.Zero).IsGreater(Vector2.One);
```
{% endtab %}
{% endtabs %}

### is_greater_equal

Verifies that the current value is greater than or equal the given one.
{% tabs assert-vec-is_greater_equal %}
{% tab assert-vec-is_greater_equal GdScript %}
```gd
func assert_vector(<current>).is_greater_equal(<expected>) -> GdUnitVectorAssert
```
```gd
# this assertion succeeds
assert_vector(Vector2(1.1, 1.3)).is_greater_equal(Vector2(1.1, 1.2))
assert_vector(Vector2(1.1, 1.2)).is_greater_equal(Vector2(1.1, 1.2))

# this assertion fails because part y1.2 is less than 1.3
assert_vector(Vector2(1.1, 1.2)).is_greater_equal(Vector2(1.1, 1.3))
```
{% endtab %}
{% tab assert-vec-is_greater_equal C# %}
```cs
public static IVector2Assert AssertThat(Godot.Vector2 current).IsGreaterEqual(<expected>);
```
```cs
// this assertion succeeds
AssertVec2(new Vector2(1.2f, 1.000001f)).IsGreaterEqual(new Vector2(1.2f, 1.000001f));
AssertVec2(new Vector2(1.2f, 1.000002f)).IsGreaterEqual(new Vector2(1.2f, 1.000001f));

// should fail because it is NOT greater or equal
AssertVec2(new Vector2(1.2f, 1.000002f)).IsGreaterEqual(new Vector2(1.2f, 1.000003f);
```
{% endtab %}
{% endtabs %}

### is_between

Verifies that the current value is between the given boundaries (inclusive).
{% tabs assert-vec-is_between %}
{% tab assert-vec-is_between GdScript %}
```gd
func assert_vector(<current>).is_between(<from>, <to>) -> GdUnitVectorAssert
```
```gd
# this assertion succeeds
assert_vector(Vector2(1.1, 1.2)).is_between(Vector2(1.1, 1.2), Vector2(1.1, 1.3))
assert_vector(Vector2(1.1, 1.2)).is_between(Vector2(1.1, 1.1), Vector2(1.1, 1.3))

# this assertion fail because the part y 1.2 is not between 1.0 and 1.1
assert_vector(Vector2(1.1, 1.2)).is_between (Vector2(1.1, 1.0), Vector2(1.1, 1.1))
```
{% endtab %}
{% tab assert-vec-is_between C# %}
```cs
public static IVector2Assert AssertThat(Godot.Vector2 current).IsBetween(<from>, <to>);
```
```cs
// this assertion succeeds
AssertVec2(Vector2.Zero).IsBetween(Vector2.Zero, Vector2.One);
AssertVec2(Vector2.One).IsBetween(Vector2.Zero, Vector2.One);

// should fail because it is NOT between zero and one
AssertVec2(new Vector2(0, -.1f)).IsBetween(Vector2.Zero, Vector2.One);
```
{% endtab %}
{% endtabs %}

### is_not_between

Verifies that the current value is not between the given boundaries (inclusive).
{% tabs assert-vec-is_not_between %}
{% tab assert-vec-is_not_between GdScript %}
```gd
func assert_vector(<current>).is_not_between(<from>, <to>) -> GdUnitVectorAssert
```
```gd
# this assertion succeeds
assert_vector(Vector2(1.0, 1.0)).is_not_between(Vector2(1.1, 1.0), Vector2(2.0, 1.0))

# this assertion fail because the vector is between
assert_vector(Vector2(1.0, 1.0)).is_not_between(Vector2(1.0, 1.0), Vector2(2.0, 1.0))
```
{% endtab %}
{% tab assert-vec-is_not_between C# %}
```cs
public static IVector2Assert AssertThat(Godot.Vector2 current).IsNotBetween(<from>, <to>);
```
```cs
// this assertion succeeds
AssertVec2(new Vector2(1f, 1.0002f)).IsNotBetween(Vector2.Zero, Vector2.One);

// should fail because it is between zero and one
AssertVec2(Vector2.One).IsNotBetween(Vector2.Zero, Vector2.One);
```
{% endtab %}
{% endtabs %}
