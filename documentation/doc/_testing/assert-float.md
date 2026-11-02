---
layout: default
title: Float/Double Assert
parent: Asserts
---

# Float/Double Assertions

An assertion tool to verify float values.

{% tabs assert-float-overview %}
{% tab assert-float-overview GdScript %}
**GdUnitFloatAssert**<br>

| Function                                                                    | Description                                                                  |
| --------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [is_null]({{site.baseurl}}/testing/assert-float/#is_null)                   | Verifies that the current value is null.                                     |
| [is_not_null]({{site.baseurl}}/testing/assert-float/#is_not_null)           | Verifies that the current value is not null.                                 |
| [is_equal]({{site.baseurl}}/testing/assert-float/#is_equal)                 | Verifies that the current value is equal to the given one.                   |
| [is_not_equal]({{site.baseurl}}/testing/assert-float/#is_not_equal)         | Verifies that the current value is not equal to the given one.               |
| [is_equal_approx]({{site.baseurl}}/testing/assert-float/#is_equal_approx)   | Verifies that the current and expected value are approximately equal.        |
| [is_less]({{site.baseurl}}/testing/assert-float/#is_less)                   | Verifies that the current value is less than the given one.                  |
| [is_less_equal]({{site.baseurl}}/testing/assert-float/#is_less_equal)       | Verifies that the current value is less than or equal the given one.         |
| [is_greater]({{site.baseurl}}/testing/assert-float/#is_greater)             | Verifies that the current value is greater than the given one.               |
| [is_greater_equal]({{site.baseurl}}/testing/assert-float/#is_greater_equal) | Verifies that the current value is greater than or equal the given one.      |
| [is_negative]({{site.baseurl}}/testing/assert-float/#is_negative)           | Verifies that the current value is negative.                                 |
| [is_not_negative]({{site.baseurl}}/testing/assert-float/#is_not_negative)   | Verifies that the current value is not negative.                             |
| [is_zero]({{site.baseurl}}/testing/assert-float/#is_zero)                   | Verifies that the current value is equal to zero.                            |
| [is_not_zero]({{site.baseurl}}/testing/assert-float/#is_not_zero)           | Verifies that the current value is not equal to zero.                        |
| [is_in]({{site.baseurl}}/testing/assert-float/#is_in)                       | Verifies that the current value is in the given set of values.               |
| [is_not_in]({{site.baseurl}}/testing/assert-float/#is_not_in)               | Verifies that the current value is not in the given set of values.           |
| [is_between]({{site.baseurl}}/testing/assert-float/#is_between)             | Verifies that the current value is between the given boundaries (inclusive). |

{% endtab %}
{% tab assert-float-overview C# %}
**INumberAssert\<float\>**<br>

| Function                                                                  | Description                                                                  |
| ------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [IsNull]({{site.baseurl}}/testing/assert-float/#is_null)                  | Verifies that the current value is null.                                     |
| [IsNotNull]({{site.baseurl}}/testing/assert-float/#is_not_null)           | Verifies that the current value is not null.                                 |
| [IsEqual]({{site.baseurl}}/testing/assert-float/#is_equal)                | Verifies that the current value is equal to the given one.                   |
| [IsNotEqual]({{site.baseurl}}/testing/assert-float/#is_not_equal)         | Verifies that the current value is not equal to the given one.               |
| [IsEqualApprox]({{site.baseurl}}/testing/assert-float/#is_equal_approx)   | Verifies that the current and expected value are approximately equal.        |
| [IsLess]({{site.baseurl}}/testing/assert-float/#is_less)                  | Verifies that the current value is less than the given one.                  |
| [IsLessEqual]({{site.baseurl}}/testing/assert-float/#is_less_equal)       | Verifies that the current value is less than or equal the given one.         |
| [IsGreater]({{site.baseurl}}/testing/assert-float/#is_greater)            | Verifies that the current value is greater than the given one.               |
| [IsGreaterEqual]({{site.baseurl}}/testing/assert-float/#is_greater_equal) | Verifies that the current value is greater than or equal the given one.      |
| [IsNegative]({{site.baseurl}}/testing/assert-float/#is_negative)          | Verifies that the current value is negative.                                 |
| [IsNotNegative]({{site.baseurl}}/testing/assert-float/#is_not_negative)   | Verifies that the current value is not negative.                             |
| [IsZero]({{site.baseurl}}/testing/assert-float/#is_zero)                  | Verifies that the current value is equal to zero.                            |
| [IsNotZero]({{site.baseurl}}/testing/assert-float/#is_not_zero)           | Verifies that the current value is not equal to zero.                        |
| [IsIn]({{site.baseurl}}/testing/assert-float/#is_in)                      | Verifies that the current value is in the given set of values.               |
| [IsNotIn]({{site.baseurl}}/testing/assert-float/#is_not_in)               | Verifies that the current value is not in the given set of values.           |
| [IsNetween]({{site.baseurl}}/testing/assert-float/#is_between)            | Verifies that the current value is between the given boundaries (inclusive). |

{% endtab %}
{% endtabs %}

---

## Float Assert Examples

### is_equal

Verifies that the current value is equal to the given one.
{% tabs assert-float-is_equal %}
{% tab assert-float-is_equal GdScript %}
```gd
func assert_float(<current>).is_equal(<expected>) -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(23.2).is_equal(23.2)

# this assertion fails because 23.2 are not equal to 23.4
assert_float(23.2).is_equal(23.4)
```
{% endtab %}
{% tab assert-float-is_equal C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsEqual(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23.2).IsEqual(23.2);

// this assertion fails because 23.2 are not equal to 23.4
AssertThat(23.2).IsEqual(23.4);
```
{% endtab %}
{% endtabs %}

### is_not_equal

Verifies that the current value is not equal to the given one.
{% tabs assert-float-is_not_equal %}
{% tab assert-float-is_not_equal GdScript %}
```gd
func assert_float(<current>).is_not_equal(<expected>) -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(23.2).is_not_equal(23.4)

# this assertion fails because 23.2 are equal to 23.2
assert_float(23.2).is_not_equal(23.2)
```
{% endtab %}
{% tab assert-float-is_not_equal C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsNotEqual(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23.2).IsNotEqual(23.4);

// this assertion fails because 23.2 are equal to 23.2
AssertThat(23.2).IsNotEqual(23.2);
```
{% endtab %}
{% endtabs %}

### is_equal_approx

Verifies that the current and expected value are approximately equal.
{% tabs assert-float-is_equal_approx %}
{% tab assert-float-is_equal_approx GdScript %}
```gd
func is_equal_approx(<expected>, <approx>) -> GdUnitFloatAssert:
```
```gd
# this assertion succeeds
assert_float(23.19).is_equal_approx(23.2, 0.01)
assert_float(23.20).is_equal_approx(23.2, 0.01)
assert_float(23.21).is_equal_approx(23.2, 0.01)

# this assertion fails because 23.18 and 23.22 are not equal approximately to 23.2 +/- 0.01
assert_float(23.18).is_equal_approx(23.2, 0.01)
assert_float(23.22).is_equal_approx(23.2, 0.01)
```
{% endtab %}
{% tab assert-float-is_equal_approx C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsEqualApprox(<expected>, <approx>)
```
```cs
// this assertion succeeds
AssertThat(23.19).IsEqualApprox(23.2, 0.01);
AssertThat(23.20).IsEqualApprox(23.2, 0.01);
AssertThat(23.21).IsEqualApprox(23.2, 0.01);

// this assertion fails because 23.18 and 23.22 are not equal approximately to 23.2 +/- 0.01
AssertThat(23.18).IsEqualApprox(23.2, 0.01);
AssertThat(23.22).IsEqualApprox(23.2, 0.01);
```
{% endtab %}
{% endtabs %}

### is_less

Verifies that the current value is less than the given one.
{% tabs assert-float-is_less %}
{% tab assert-float-is_less GdScript %}
```gd
func assert_float(<current>).is_less(<expected>) -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(23.2).is_less(23.4)
assert_float(23.2).is_less(26.0)

# this assertion fails because 23.2 is not less than 23.2
assert_float(23.2).is_less(23.2)
```
{% endtab %}
{% tab assert-float-is_less C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsLess(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23.2).IsLess(23.4);
AssertThat(23.2).IsLess(26.0);

// this assertion fails because 23.2 is not less than 23.2
AssertThat(23.2).IsLess(23.2);
```
{% endtab %}
{% endtabs %}

### is_less_equal

Verifies that the current value is less than or equal the given one.
{% tabs assert-float-is_less_equal %}
{% tab assert-float-is_less_equal GdScript %}
```gd
func assert_float(<current>).is_less_equal(<expected>) -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(23.2).is_less_equal(23.4)
assert_float(23.2).is_less_equal(23.2)

# this assertion fails because 23.2 is not less than or equal to 23.1
assert_float(23.2).is_less_equal(23.1)
```
{% endtab %}
{% tab assert-float-is_less_equal C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsLessEqual(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23.2).IsLessEqual(23.4);
AssertThat(23.2).IsLessEqual(23.2);

// this assertion fails because 23.2 is not less than or equal to 23.1
AssertThat(23.2).IsLessEqual(23.1);
```
{% endtab %}
{% endtabs %}

### is_greater

Verifies that the current value is greater than the given one.
{% tabs assert-float-is_greater %}
{% tab assert-float-is_greater GdScript %}
```gd
func assert_float(<current>).is_greater(<expected>) -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(23.2).is_greater(23.0)
assert_float(23.4).is_greater(22.1)

# this assertion fails because 23.2 is not greater than 23.2
assert_float(23.2).is_greater(23.2)
```
{% endtab %}
{% tab assert-float-is_greater C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsGreater(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23.2).IsGreater(23.0)
AssertThat(23.4).IsGreater(22.1)

// this assertion fails because 23.2 is not greater than 23.2
AssertThat(23.2).IsGreater(23.2)
```
{% endtab %}
{% endtabs %}

### is_greater_equal

Verifies that the current value is greater than or equal the given one.
{% tabs assert-float-is_greater_equal %}
{% tab assert-float-is_greater_equal GdScript %}
```gd
func assert_float(<current>).is_greater_equal(<expected>) -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(23.2).is_greater_equal(20.2)
assert_float(23.2).is_greater_equal(23.2)

# this assertion fails because 23.2 is not greater than 23.3
assert_float(23.2).is_greater_equal(23.3)
```
{% endtab %}
{% tab assert-float-is_greater_equal C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsGreaterEqual(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23.2).IsGreaterEqual(20.2);
AssertThat(23.2).IsGreaterEqual(23.2);

// this assertion fails because 23.2 is not greater than 23.3
AssertThat(23.2).IsGreaterEqual(23.3);
```
{% endtab %}
{% endtabs %}

### is_negative

Verifies that the current value is negative.
{% tabs assert-float-is_negative %}
{% tab assert-float-is_negative GdScript %}
```gd
func assert_float(<current>).is_negative() -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(-13.2).is_negative()

# this assertion fails because is not negative
assert_float(13.2).is_negative()
```
{% endtab %}
{% tab assert-float-is_negative C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsNegative()
```
```cs
// this assertion succeeds
AssertThat(-13.2).IsNegative();

// this assertion fails because is not negative
AssertThat(13.2).IsNegative();
```
{% endtab %}
{% endtabs %}

### is_not_negative

Verifies that the current value is not negative.
{% tabs assert-float-is_not_negative %}
{% tab assert-float-is_not_negative GdScript %}
```gd
func assert_float(<current>).is_not_negative() -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(13.2).is_not_negative()

# this assertion fails because is negative
assert_float(-13.2).is_not_negative()
```
{% endtab %}
{% tab assert-float-is_not_negative C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsNotNegative()
```
```cs
// this assertion succeeds
AssertThat(13.2).IsNotNegative();

// this assertion fails because is negative
AssertThat(-13.2).IsNotNegative();
```
{% endtab %}
{% endtabs %}

### is_zero

Verifies that the current value is equal to zero.
{% tabs assert-float-is_zero %}
{% tab assert-float-is_zero GdScript %}
```gd
func assert_float(<current>).is_zero() -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(0.0).is_zero()

# this assertion fail because the value is not zero
assert_float(0.00001).is_zero()
```
{% endtab %}
{% tab assert-float-is_zero C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsZero()
```
```cs
// this assertion succeeds
AssertThat(0.0).IsZero();

// this assertion fail because the value is not zero
AssertThat(0.00001).IsZero();
```
{% endtab %}
{% endtabs %}

### is_not_zero

Verifies that the current value is not equal to zero.
{% tabs assert-float-is_not_zero %}
{% tab assert-float-is_not_zero GdScript %}
```gd
func assert_float(<current>).is_not_zero() -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(0.00001).is_not_zero()

# this assertion fail because the value is not zero
assert_float(0.000001).is_not_zero()
```
{% endtab %}
{% tab assert-float-is_not_zero C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsNotZero()
```
```cs
// this assertion succeeds
AssertThat(0.00001).IsNotZero();

// this assertion fail because the value is not zero
AssertThat(0.000001).IsNotZero();
```
{% endtab %}
{% endtabs %}

### is_in

Verifies that the current value is in the given set of values.
{% tabs assert-float-is_in %}
{% tab assert-float-is_in GdScript %}
```gd
func assert_float(<current>).is_in(<expected> :Array) -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(5.2).is_in([5.1, 5.2, 5.3, 5.4])

# this assertion fail because 5.5 is not in [5.1, 5.2, 5.3, 5.4]
assert_float(5.5).is_in([5.1, 5.2, 5.3, 5.4])
```
{% endtab %}
{% tab assert-float-is_in C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsIn([]<expected>)
```
```cs
// this assertion succeeds
AssertThat(5.2).IsIn(5.1, 5.2, 5.3, 5.4);

// this assertion fail because 5.5 is not in [5.1, 5.2, 5.3, 5.4]
AssertThat(5.5).IsIn(5.1, 5.2, 5.3, 5.4);
```
{% endtab %}
{% endtabs %}

### is_not_in

Verifies that the current value is not in the given set of values.
{% tabs assert-float-is_not_in %}
{% tab assert-float-is_not_in GdScript %}
```gd
func assert_float(<current>).is_not_in(<expected> :Array) -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(5.2).is_not_in([5.1, 5.3, 5.4])

# this assertion fail because 5.2 is not in [5.1, 5.2, 5.3, 5.4]
assert_float(5.2).is_not_in([5.1, 5.2, 5.3, 5.4])
```
{% endtab %}
{% tab assert-float-is_not_in C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsNotIn([]<expected>)
```
```cs
// this assertion succeeds
AssertThat(5.2).IsNotIn(5.1, 5.3, 5.4);

// this assertion fail because 5.2 is not in [5.1, 5.2, 5.3, 5.4]
AssertThat(5.2).IsNotIn(5.1, 5.2, 5.3, 5.4);
```
{% endtab %}
{% endtabs %}

### is_between

Verifies that the current value is between the given boundaries (inclusive).
{% tabs assert-float-is_between %}
{% tab assert-float-is_between GdScript %}
```gd
func assert_float(<current>).is_between(<from>, <to>) -> GdUnitFloatAssert
```
```gd
# this assertion succeeds
assert_float(-20.0).is_between(-20.0, 20.9)
assert_float(10.0).is_between(-20.0, 20.9)
assert_float(20.9).is_between(-20.0, 20.9)

# this assertion fail because the value is -10.0 and not between -9 and 0
assert_float(-10.0).is_between(-9.0, 0.0)
```
{% endtab %}
{% tab assert-float-is_between C# %}
```cs
public static INumberAssert<double> AssertThat(<current>).IsBetween(<from>, <to>)
```
```cs
// this assertion succeeds
AssertThat(-20.0).IsBetween(-20.0, 20.9);
AssertThat(10.0).IsBetween(-20.0, 20.9);
AssertThat(20.9).IsBetween(-20.0, 20.9);

// this assertion fail because the value is -10.0 and not between -9 and 0
AssertThat(-10.0).IsBetween(-9.0, 0.0);
```
{% endtab %}
{% endtabs %}
