---
layout: default
title: Signal Assert
parent: Asserts
---

# Signal Assertions

An Assertion Tool to verify for emitted signals until a certain time. When the timeout is reached, the assertion fails with a timeout error.
The default timeout of 2s can be overridden by wait_until(\<time in ms\>)<br>
To watch for signals emitted during the test execution you have to use in addition the [monitor_signal]({{site.baseurl}}/advanced_testing/signals/#monitor-signals) tool.

{% tabs assert-signal-overview %}
{% tab assert-signal-overview GdScript %}
**GdUnitSignalAssert**<br>

|Function|Description|
|--- | --- |
|[is_emitted]({{site.baseurl}}/testing/assert-signal/#is_emitted) | Verifies that given signal is emitted until waiting time.|
|[is_not_emitted]({{site.baseurl}}/testing/assert-signal/#is_not_emitted) | Verifies that given signal is NOT emitted until waiting time.|
|[is_signal_exists]({{site.baseurl}}/testing/assert-signal/#is_signal_exists) | Verifies if the signal exists on the emitter.|
|[wait_until]({{site.baseurl}}/testing/assert-signal/#wait_until) | Sets the assert signal timeout in ms.|

{% endtab %}
{% tab assert-signal-overview C# %}
**ISignalAssert**<br>

|Function|Description|
|--- | --- |
|[IsEmitted]({{site.baseurl}}/testing/assert-signal/#is_emitted) | Verifies that given signal is emitted until waiting time.|
|[IsNotEmitted]({{site.baseurl}}/testing/assert-signal/#is_not_emitted) | Verifies that given signal is NOT emitted until waiting time.|
|[IsSignalExists]({{site.baseurl}}/testing/assert-signal/#is_signal_exists) | Verifies if the signal exists on the emitter.|

{% endtab %}
{% endtabs %}

---

## Signal Assert Examples

## is_emitted

Verifies that the specified signal is emitted with the expected arguments.

This assertion waits for a signal to be emitted from the object under test and
validates that it was emitted with the correct arguments. The function supports
both typed signals (Signal type) and string-based signal names for flexibility
in different testing scenarios.

{% tabs assert-signal-is_emitted %}
{% tab assert-signal-is_emitted GdScript %}

```gd
## [b]Parameters:[/b]
## [param signal_name]: The signal to monitor. Can be either:
##   • A [Signal] reference (recommended for type safety)
##   • A [String] with the signal name
## [param signal_args]: Optional expected signal arguments.
##   When provided, verifies the signal was emitted with exactly these values.
func assert_signal(instance: Object).is_emitted(signal_name: Variant, ...signal_args: Array) -> GdUnitSignalAssert
```
```gd
signal signal_a(value: int)
signal signal_b(name: String, count: int)

# Wait for signal emission without checking arguments
# Using Signal reference (type-safe)
await assert_signal(instance).is_emitted(signal_a)
# Using string name (dynamic)
await assert_signal(instance).is_emitted("signal_a")

# Wait for signal emission with specific argument
await assert_signal(instance).is_emitted(signal_a, 10)

# Wait for signal with multiple arguments
await assert_signal(instance).is_emitted(signal_b, "test", 42)

# Wait max 500ms for signal with argument 10
await assert_signal(instance).wait_until(500).is_emitted(signal_a, 10)
```
{% endtab %}
{% tab assert-signal-is_emitted C# %}
```cs
public Task<ISignalAssert> IsEmitted(string signal, params object[] args);
```
```cs
// waits until the signal "door_opened" is emitted by the instance or fails after default timeout of 2s
await AssertSignal(instance).IsEmitted("door_opened");
// waits until the signal "door_opened" is emitted by the instance or fails after given timeout of 200ms
await AssertSignal(instance).IsEmitted("door_opened").WithTimeout(200);
```
{% endtab %}
{% endtabs %}

## is_not_emitted

Verifies that the specified signal is NOT emitted with the expected arguments.

This assertion waits for a specified time period and validates that a signal
was not emitted with the given arguments. Useful for ensuring certain conditions
don't trigger unwanted signals or for verifying signal filtering logic.

{% tabs assert-signal-is_not_emitted %}
{% tab assert-signal-is_not_emitted GdScript %}
```gd
## [b]Parameters:[/b]
## [param signal_name]: The signal to monitor. Can be either:
##   • A [Signal] reference (recommended for type safety)
##   • A [String] with the signal name
## [param signal_args]: Optional expected signal arguments.
##   When provided, verifies the signal was not emitted with these specific values.
##   If omitted, verifies the signal was not emitted at all.
func assert_signal(instance: Object).is_not_emitted(signal_name: Variant, ...signal_args: Array) -> GdUnitSignalAssert
```

```gd
signal signal_a(value: int)
signal signal_b(name: String, count: int)

# Verify signal is not emitted at all (without checking arguments)
await assert_signal(instance).wait_until(500).is_not_emitted(signal_a)
await assert_signal(instance).wait_until(500).is_not_emitted("signal_a")

# Verify signal is not emitted with specific argument
await assert_signal(instance).wait_until(500).is_not_emitted(signal_a, 10)

# Verify signal is not emitted with multiple arguments
await assert_signal(instance).wait_until(500).is_not_emitted(signal_b, "test", 42)

# Can be emitted with different arguments (this passes)
instance.emit_signal("signal_a", 20)  # Emits with 20, not 10
await assert_signal(instance).wait_until(500).is_not_emitted(signal_a, 10)
```
{% endtab %}
{% tab assert-signal-is_not_emitted C# %}
```cs
public Task<ISignalAssert> IsNotEmitted(string signal, params object[] args);
```
```cs
// waits until 2s and verifies the signal "door_locked" is not emitted
await AssertSignal(instance).IsNotEmitted("door_locked");
// waits until 200ms and verifies the signal "door_locked" is not emitted
await AssertSignal(instance).IsNotEmitted("door_locked").WithTimeout(200);
```
{% endtab %}
{% endtabs %}

## is_signal_exists

Verifies that the specified signal exists on the emitter object.

This assertion checks if a signal is defined on the object under test,
regardless of whether it has been emitted. Useful for validating that
objects have the expected signals before testing their emission.

{% tabs assert-signal-is_signal_exists %}
{% tab assert-signal-is_signal_exists GdScript %}
```gd
## [b]Parameters:[/b]
## [param signal_name]: The signal to check. Can be either:
##   • A [Signal] reference (recommended for type safety)
##   • A [String] with the signal name
func assert_signal(instance: Object).is_signal_exists(signal_name: Variant) -> GdUnitSignalAssert
```

```gd
signal my_signal(value: int)
signal another_signal()

# Verify signal exists using Signal reference
assert_signal(instance).is_signal_exists(my_signal)

# Verify signal exists using string name
assert_signal(instance).is_signal_exists("my_signal")

# Chain with other assertions
assert_signal(instance) \
    .is_signal_exists(my_signal) \
    .is_emitted(my_signal, 42)
```
{% endtab %}
{% tab assert-signal-is_signal_exists C# %}
```cs
public ISignalAssert IsSignalExists(string signal);
```
```cs
// verify the signal 'visibility_changed' exists in the node
AssertSignal(node).IsSignalExists("visibility_changed");
```
{% endtab %}
{% endtabs %}

## wait_until

Sets the assert signal timeout in ms, if the time over a failure is reported.
{% tabs assert-signal-wait_until %}
{% tab assert-signal-wait_until GdScript %}
```gd
func assert_signal(instance: Object>).wait_until(timeout: int) -> GdUnitSignalAssert
```
```gd
signal signal_a()

# Do wait until 5s the instance has emitted the signal `signal_a`[br]
assert_signal(instance).wait_until(5000).is_emitted(signal_a)
```
{% endtab %}
{% tab assert-signal-wait_until C# %}
```cs
public static async Task<ISignalAssert> WithTimeout(this Task<ISignalAssert> task, int timeoutMillis);
```
```cs
// waits until 5s and verifies the signal "door_locked" is not emitted or fail
await AssertSignal(instance).IsEmitted("door_closed").WithTimeout(5000);
```
{% endtab %}
{% endtabs %}

---

For more advanced examples show [Testing Signals]({{site.baseurl}}/advanced_testing/signals/#testing-for-signals).
