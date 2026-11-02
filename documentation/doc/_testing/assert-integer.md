---
layout: default
title: Integer Assert
parent: Asserts
---

# Integer Assertions

An assertion tool to verify integer values.

{% tabs assert-int-overview %}
{% tab assert-int-overview GdScript %}
**GdUnitIntAssert**<br>

| Function                                                                      | Description                                                                  |
| ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [is_null]({{site.baseurl}}/testing/assert-integer/#is_null)                   | Verifies that the current value is null.                                     |
| [is_not_null]({{site.baseurl}}/testing/assert-integer/#is_not_null)           | Verifies that the current value is not null.                                 |
| [is_equal]({{site.baseurl}}/testing/assert-integer/#is_equal)                 | Verifies that the current value is equal to the given one.                   |
| [is_not_equal]({{site.baseurl}}/testing/assert-integer/#is_not_equal)         | Verifies that the current value is not equal to the given one.               |
| [is_less]({{site.baseurl}}/testing/assert-integer/#is_less)                   | Verifies that the current value is less than the given one.                  |
| [is_less_equal]({{site.baseurl}}/testing/assert-integer/#is_less_equal)       | Verifies that the current value is less than or equal the given one.         |
| [is_greater]({{site.baseurl}}/testing/assert-integer/#is_greater)             | Verifies that the current value is greater than the given one.               |
| [is_greater_equal]({{site.baseurl}}/testing/assert-integer/#is_greater_equal) | Verifies that the current value is greater than or equal the given one.      |
| [is_even]({{site.baseurl}}/testing/assert-integer/#is_even)                   | Verifies that the current value is even.                                     |
| [is_odd]({{site.baseurl}}/testing/assert-integer/#is_odd)                     | Verifies that the current value is odd.                                      |
| [is_negative]({{site.baseurl}}/testing/assert-integer/#is_negative)           | Verifies that the current value is negative.                                 |
| [is_not_negative]({{site.baseurl}}/testing/assert-integer/#is_not_negative)   | Verifies that the current value is not negative.                             |
| [is_zero]({{site.baseurl}}/testing/assert-integer/#is_zero)                   | Verifies that the current value is equal to zero.                            |
| [is_not_zero]({{site.baseurl}}/testing/assert-integer/#is_not_zero)           | Verifies that the current value is not equal to zero.                        |
| [is_in]({{site.baseurl}}/testing/assert-integer/#is_in)                       | Verifies that the current value is in the given set of values.               |
| [is_not_in]({{site.baseurl}}/testing/assert-integer/#is_not_in)               | Verifies that the current value is not in the given set of values.           |
| [is_between]({{site.baseurl}}/testing/assert-integer/#is_between)             | Verifies that the current value is between the given boundaries (inclusive). |

{% endtab %}
{% tab assert-int-overview C# %}
**INumberAssert\<int\>**<br>

| Function                                                                    | Description                                                                  |
| --------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [IsNull]({{site.baseurl}}/testing/assert-integer/#is_null)                  | Verifies that the current value is null.                                     |
| [IsNotNull]({{site.baseurl}}/testing/assert-integer/#is_not_null)           | Verifies that the current value is not null.                                 |
| [IsEqual]({{site.baseurl}}/testing/assert-integer/#is_equal)                | Verifies that the current value is equal to the given one.                   |
| [IsNotEqual]({{site.baseurl}}/testing/assert-integer/#is_not_equal)         | Verifies that the current value is not equal to the given one.               |
| [IsLess]({{site.baseurl}}/testing/assert-integer/#is_less)                  | Verifies that the current value is less than the given one.                  |
| [IsLessEqual]({{site.baseurl}}/testing/assert-integer/#is_less_equal)       | Verifies that the current value is less than or equal the given one.         |
| [IsGreater]({{site.baseurl}}/testing/assert-integer/#is_greater)            | Verifies that the current value is greater than the given one.               |
| [IsGreaterEqual]({{site.baseurl}}/testing/assert-integer/#is_greater_equal) | Verifies that the current value is greater than or equal the given one.      |
| [IsEven]({{site.baseurl}}/testing/assert-integer/#is_even)                  | Verifies that the current value is even.                                     |
| [IsOdd]({{site.baseurl}}/testing/assert-integer/#is_odd)                    | Verifies that the current value is odd.                                      |
| [IsNegative]({{site.baseurl}}/testing/assert-integer/#is_negative)          | Verifies that the current value is negative.                                 |
| [IsNotNegative]({{site.baseurl}}/testing/assert-integer/#is_not_negative)   | Verifies that the current value is not negative.                             |
| [IsZero]({{site.baseurl}}/testing/assert-integer/#is_zero)                  | Verifies that the current value is equal to zero.                            |
| [IsNotZero]({{site.baseurl}}/testing/assert-integer/#is_not_zero)           | Verifies that the current value is not equal to zero.                        |
| [IsIn]({{site.baseurl}}/testing/assert-integer/#is_in)                      | Verifies that the current value is in the given set of values.               |
| [IsNotIn]({{site.baseurl}}/testing/assert-integer/#is_not_in)               | Verifies that the current value is not in the given set of values.           |
| [IsBetween]({{site.baseurl}}/testing/assert-integer/#is_between)            | Verifies that the current value is between the given boundaries (inclusive). |

{% endtab %}
{% endtabs %}

---

## Integer Assert Examples

### is_equal

Verifies that the current value is equal to the given one.
{% tabs assert-int-is_equal %}
{% tab assert-int-is_equal GdScript %}
```gd
func assert_int(<current>).is_equal(<expected>) -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(23).is_equal(23)

# this assertion fails because 23 are not equal to 42
assert_int(23).is_equal(42)
```
{% endtab %}
{% tab assert-int-is_equal C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsEqual(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23).IsEqual(23);

// this assertion fails because 23 are not equal to 42
AssertThat(23).IsEqual(42);
```
{% endtab %}
{% endtabs %}

### is_not_equal

Verifies that the current value is not equal to the given one.
{% tabs assert-int-is_not_equal %}
{% tab assert-int-is_not_equal GdScript %}
```gd
func assert_int(<current>).is_not_equal(<expected>) -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(23).is_not_equal(42)

# this assertion fails because 23 are equal to 23 
assert_int(23).is_not_equal(23)
```
{% endtab %}
{% tab assert-int-is_not_equal C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsNotEqual(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23).IsNotEqual(42);

// this assertion fails because 23 are equal to 23 
AssertThat(23).IsNotEqual(23);
```
{% endtab %}
{% endtabs %}

### is_less

Verifies that the current value is less than the given one.
{% tabs assert-int-is_less %}
{% tab assert-int-is_less GdScript %}
```gd
func assert_int(<current>).is_less(<expected>) -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(23).is_less(42)
assert_int(23).is_less(24)

# this assertion fails because 23 is not less than 23
assert_int(23).is_less(23)
```
{% endtab %}
{% tab assert-int-is_less C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsLess(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23).IsLess(42);
AssertThat(23).IsLess(24);

// this assertion fails because 23 is not less than 23
AssertThat(23).IsLess(23);
```
{% endtab %}
{% endtabs %}

### is_less_equal

Verifies that the current value is less than or equal the given one.
{% tabs assert-int-is_less_equal %}
{% tab assert-int-is_less_equal GdScript %}
```gd
func assert_int(<current>).is_less_equal(<expected>) -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(23).is_less_equal(42)
assert_int(23).is_less_equal(23)

# this assertion fails because 23 is not less than or equal to 22
assert_int(23).is_less_equal(22)
```
{% endtab %}
{% tab assert-int-is_less_equal C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsLessEqual(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23).IsLessEqual(42);
AssertThat(23).IsLessEqual(23);

// this assertion fails because 23 is not less than or equal to 22
AssertThat(23).IsLessEqual(22);
```
{% endtab %}
{% endtabs %}

### is_greater

Verifies that the current value is greater than the given one.
{% tabs assert-int-is_greater %}
{% tab assert-int-is_greater GdScript %}
```gd
func assert_int(<current>).is_greater(<expected>) -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(23).is_greater(20)
assert_int(23).is_greater(22)

# this assertion fails because 23 is not greater than 23
assert_int(23).is_greater(23)
```
{% endtab %}
{% tab assert-int-is_greater C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsGreater(<expected>)
```
```cs
// this assertion succeeds
AssertThat(23).IsGreater(20);
AssertThat(23).IsGreater(22);

// this assertion fails because 23 is not greater than 23
AssertThat(23).IsGreater(23);
```
{% endtab %}
{% endtabs %}

### is_greater_equal

Verifies that the current value is greater than or equal the given one.
{% tabs assert-int-is_greater_equal %}
{% tab assert-int-is_greater_equal GdScript %}
```gd
func assert_int(<current>).is_greater_equal(<expected>) -> GdUnitIntAssert
```
```gd
assert_int(23).is_greater_equal(20)
assert_int(23).is_greater_equal(23)

# this assertion fails because 23 is not greater than 23
assert_int(23).is_greater_equal(24)
```
{% endtab %}
{% tab assert-int-is_greater_equal C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsGreaterEqual(<expected>)
```
```cs
AssertThat(23).IsGreaterEqual(20)
AssertThat(23).IsGreaterEqual(23)

// this assertion fails because 23 is not greater than 23
AssertThat(23).IsGreaterEqual(24)
```
{% endtab %}
{% endtabs %}

### is_even

Verifies that the current value is even.
{% tabs assert-int-is_even %}
{% tab assert-int-is_even GdScript %}
```gd
func assert_int(<current>).is_even() -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(12).is_even()

# this assertion fail because the value '13' is not even
assert_int(13).is_even()
```
{% endtab %}
{% tab assert-int-is_even C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsEven()
```
```cs
// this assertion succeeds
AssertThat(12).IsEven();

// this assertion fail because the value '13' is not even
AssertThat(13).IsEven();
```
{% endtab %}
{% endtabs %}

### is_odd

Verifies that the current value is odd.
{% tabs assert-int-is_odd %}
{% tab assert-int-is_odd GdScript %}
```gd
func assert_int(<current>).is_odd() -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(13).is_odd()

# this assertion fail because the value '12' is even
assert_int(12).is_odd()
```
{% endtab %}
{% tab assert-int-is_odd C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsOdd()
```
```cs
// this assertion succeeds
AssertThat(13).IsOdd();

// this assertion fail because the value '12' is even
AssertThat(12).IsOdd();
```
{% endtab %}
{% endtabs %}

### is_negative

Verifies that the current value is negative.
{% tabs assert-int-is_negative %}
{% tab assert-int-is_negative GdScript %}
```gd
func assert_int(<current>).is_negative() -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(-13).is_negative()

# this assertion fail because the value '13' is positive
assert_int(13).is_negative()
```
{% endtab %}
{% tab assert-int-is_negative C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsNegative()
```
```cs
// this assertion succeeds
AssertThat(-13).IsNegative();

// this assertion fail because the value '13' is positive
AssertThat(13).IsNegative();
```
{% endtab %}
{% endtabs %}

### is_not_negative

Verifies that the current value is not negative.
{% tabs assert-int-is_not_negative %}
{% tab assert-int-is_not_negative GdScript %}
```gd
func assert_int(<current>).is_not_negative() -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(13).is_not_negative()

# this assertion fail because the value '-13' is negative
assert_int(-13).is_not_negative()
```
{% endtab %}
{% tab assert-int-is_not_negative C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsNotNegative()
```
```cs
// this assertion succeeds
AssertThat(13).IsNotNegative();

// this assertion fail because the value '-13' is negative
AssertThat(-13).IsNotNegative();
```
{% endtab %}
{% endtabs %}

### is_zero

Verifies that the current value is equal to zero.
{% tabs assert-int-is_zero %}
{% tab assert-int-is_zero GdScript %}
```gd
func assert_int(<current>).is_zero() -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(0).is_zero()

# this assertion fail because the value is not zero
assert_int(1).is_zero()
```
{% endtab %}
{% tab assert-int-is_zero C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsZero()
```
```cs
// this assertion succeeds
AssertThat(0).IsZero();

// this assertion fail because the value is not zero
AssertThat(1).IsZero();
```
{% endtab %}
{% endtabs %}

### is_not_zero

Verifies that the current value is not equal to zero.
{% tabs assert-int-is_not_zero %}
{% tab assert-int-is_not_zero GdScript %}
```gd
func assert_int(<current>).is_not_zero() -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(1).is_not_zero()

# this assertion fail because the value is zero
assert_int(0).is_not_zero()
```
{% endtab %}
{% tab assert-int-is_not_zero C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsNotZero()
```
```cs
// this assertion succeeds
AssertThat(1).IsNotZero();

// this assertion fail because the value is zero
AssertThat(0).IsNotZero();
```
{% endtab %}
{% endtabs %}

### is_in

Verifies that the current value is in the given set of values.
{% tabs assert-int-is_in %}
{% tab assert-int-is_in GdScript %}
```gd
func assert_int(<current>).is_in(<expected> :Array) -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(5).is_in([3, 4, 5, 6])

# this assertion fail because 7 is not in [3, 4, 5, 6]
assert_int(7).is_in([3, 4, 5, 6])
```
{% endtab %}
{% tab assert-int-is_in C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsIn([] <expected>)
```
```cs
// this assertion succeeds
AssertThat(5).IsIn(3, 4, 5, 6);

// this assertion fail because 7 is not in [3, 4, 5, 6]
AssertThat(7).IsIn(3, 4, 5, 6);
```
{% endtab %}
{% endtabs %}

### is_not_in

Verifies that the current value is not in the given set of values.
{% tabs assert-int-is_not_in %}
{% tab assert-int-is_not_in GdScript %}
```gd
func assert_int(<current>).is_not_in(<expected> :Array) -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(5).is_not_in([3, 4, 6, 7])

# this assertion fail because 5 is in [3, 4, 5, 6]
assert_int(5).is_not_in([3, 4, 5, 6])
```
{% endtab %}
{% tab assert-int-is_not_in C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsNotIn([] <expected>)
```
```cs
// this assertion succeeds
AssertThat(5).IsNotIn(3, 4, 6, 7);

// this assertion fail because 5 is in [3, 4, 5, 6]
AssertThat(5).IsNotIn(3, 4, 5, 6);
```
{% endtab %}
{% endtabs %}

### is_between

Verifies that the current value is between the given boundaries (inclusive).
{% tabs assert-int-is_between %}
{% tab assert-int-is_between GdScript %}
```gd
func assert_int(<current>).is_between(<from>, <to>) -> GdUnitIntAssert
```
```gd
# this assertion succeeds
assert_int(23).is_between(20, 30)
assert_int(23).is_between(23, 24)

# this assertion fail because the value is zero and not between 1 and 9
assert_int(0).is_between(1, 9)
```
{% endtab %}
{% tab assert-int-is_between C# %}
```cs
INumberAssert<int> AssertThat(<current>).IsBetween(<from>, <to>)
```
```cs
// this assertion succeeds
AssertThat(23).IsBetween(20, 30);
AssertThat(23).IsBetween(23, 24);

// this assertion fail because the value is zero and not between 1 and 9
AssertThat(0).IsBetween(1, 9);
```
{% endtab %}
{% endtabs %}
