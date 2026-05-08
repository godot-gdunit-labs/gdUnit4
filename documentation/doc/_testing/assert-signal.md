---
layout: default
title: Signal Assert
parent: Asserts
---

# Signal Assertions

`assert_signal()` verifies that a signal is emitted — or is **not** emitted — within a time window.
If the condition is not met before the timeout expires, the assertion fails with a timeout error.
The default timeout is 2000 ms and can be adjusted with
[wait_until]({{site.baseurl}}/testing/assert-signal/#wait_until).

To capture signals emitted during test execution, pair `assert_signal()` with
[monitor_signals]({{site.baseurl}}/advanced_testing/signals/#monitor-signals)
before the action under test runs.

{% include signal_await_advice.html %}

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
[Signal]
public delegate void SignalAEventHandler(int value);
[Signal]
public delegate void SignalBEventHandler(string name, int count);

// Wait for signal emission without checking arguments
await AssertSignal(instance).IsEmitted(SignalName.SignalA);
// Using string name (dynamic)
await AssertSignal(instance).IsEmitted("signal_a");

// Wait for signal emission with specific argument
await AssertSignal(instance).IsEmitted(SignalName.SignalA, 10);

// Wait for signal with multiple arguments
await AssertSignal(instance).IsEmitted(SignalName.SignalB, "test", 42);

// Wait max 500ms for signal with argument 10
await AssertSignal(instance).IsEmitted(SignalName.SignalA, 10).WithTimeout(500);
```
{% endtab %}
{% endtabs %}

{% include advice.html
content="Omitting signal_args requires the signal to be emitted with no arguments. If the signal carries arguments, provide them or use argument matchers."
%}

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
[Signal]
public delegate void SignalAEventHandler(int value);
[Signal]
public delegate void SignalBEventHandler(string name, int count);

// Verify signal is not emitted at all (without checking arguments)
await AssertSignal(instance).IsNotEmitted(SignalName.SignalA).WithTimeout(500);
await AssertSignal(instance).IsNotEmitted("signal_a").WithTimeout(500);

// Verify signal is not emitted with specific argument
await AssertSignal(instance).IsNotEmitted(SignalName.SignalA, 10).WithTimeout(500);

// Verify signal is not emitted with multiple arguments
await AssertSignal(instance).IsNotEmitted(SignalName.SignalB, "test", 42).WithTimeout(500);

// Can be emitted with different arguments (this passes)
instance.EmitSignal(SignalName.SignalA, 20);  // Emits with 20, not 10
await AssertSignal(instance).IsNotEmitted(SignalName.SignalA, 10).WithTimeout(500);
```
{% endtab %}
{% endtabs %}

{% include advice.html
content="Omitting signal_args requires the signal to be emitted with no arguments. If the signal carries arguments, provide them or use argument matchers."
%}

## Matching Signal Arguments

Signal arguments can be verified using **exact values** or **argument matchers** for flexible matching.

### Exact argument matching

When arguments are passed to `is_emitted()` or `is_not_emitted()`, the assertion performs an
exact equality check against every emitted argument in order.

{% tabs assert-signal-exact-args %}
{% tab assert-signal-exact-args GdScript %}
```gd
signal item_added(item_name: String, item_id: int)

# Passes only when the signal is emitted with exactly ("sword", 1)
await assert_signal(inventory).is_emitted(item_added, "sword", 1)

# Fails — "shield" does not equal "sword"
await assert_signal(inventory).is_emitted(item_added, "shield", 1)
```
{% endtab %}
{% tab assert-signal-exact-args C# %}
```cs
[Signal]
public delegate void ItemAddedEventHandler(string itemName, int itemId);

// Passes only when the signal is emitted with exactly ("sword", 1)
await AssertSignal(inventory).IsEmitted(SignalName.ItemAdded, "sword", 1).WithTimeout(200);

// Fails — "shield" does not equal "sword"
await AssertSignal(inventory).IsEmitted(SignalName.ItemAdded, "shield", 1).WithTimeout(200);
```
{% endtab %}
{% endtabs %}

### Matching with argument matchers

When you care only about the *type* of argument, or want to verify a signal fired without
constraining every value, use [argument matchers]({{site.baseurl}}/advanced_testing/argument_matchers/).

{% include advice.html
content="Argument matchers are currently supported for GDScript signal assertions only."
%}

```gd
signal health_changed(new_health: int)
signal player_moved(position: Vector2, speed: float)
signal item_added(item_name: String, item_id: int)

# any() matches a single argument of any type/value
await assert_signal(player).is_emitted(health_changed, any())

# Type-specific matcher — passes for any integer value
await assert_signal(player).is_emitted(health_changed, any_int())

# Mix exact values and matchers:
# Passes when item_added fires with any String name and exactly item_id=42
await assert_signal(inventory).is_emitted(item_added, any_string(), 42)

# Match a multi-argument signal regardless of its values
await assert_signal(player).is_emitted(player_moved, any(), any())

# Use matchers with is_not_emitted as well
await assert_signal(player).wait_until(200).is_not_emitted(health_changed, any())
```

See [Argument Matchers]({{site.baseurl}}/advanced_testing/argument_matchers/) for a full list
of available matchers such as `any()`, `any_int()`, `any_string()`, `any_object()`, and more.

---

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
await assert_signal(instance) \
    .is_signal_exists(my_signal) \
    .is_emitted(my_signal, 42)
```
{% endtab %}
{% tab assert-signal-is_signal_exists C# %}
```cs
public ISignalAssert IsSignalExists(string signal);
```
```cs
[Signal]
public delegate void MySignalEventHandler(int value);
[Signal]
public delegate void AnotherSignalEventHandler();

// Verify signal exists using SignalName
AssertSignal(instance).IsSignalExists(SignalName.MySignal);

// Verify signal exists using string name
AssertSignal(instance).IsSignalExists("my_signal");

// Chain with other assertions
await AssertSignal(instance)
    .IsSignalExists(SignalName.MySignal)
    .IsEmitted(SignalName.MySignal, 42);
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
await assert_signal(instance).wait_until(5000).is_emitted(signal_a)
```
{% endtab %}
{% tab assert-signal-wait_until C# %}
```cs
public static async Task<ISignalAssert> WithTimeout(this Task<ISignalAssert> task, int timeoutMillis);
```
```cs
[Signal]
public delegate void SignalAEventHandler();

// Do wait until 5s the instance has emitted the signal `signal_a`
await AssertSignal(instance).IsEmitted(SignalName.SignalA).WithTimeout(5000);
```
{% endtab %}
{% endtabs %}

---

For more advanced examples show [Testing Signals]({{site.baseurl}}/advanced_testing/signals/#testing-for-signals).
