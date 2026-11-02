---
layout: default
title: Error/Exception Assert
parent: Asserts
---

# Error Assertion

The error assertion functionality in GdUnit4 is designed to test for runtime errors and exceptions. Due to the fundamental differences between GdScript
and C# as programming languages and their integration with the Godot engine, GdUnit4 provides different approaches for error testing in each language.

## Why Different Approaches?

**GdScript Integration**: GdScript is Godot's native scripting language with built-in error handling mechanisms. GdUnit4 leverages Godot's internal error
reporting system to capture `push_error()`, `push_warning()`, and assertion failures through the `assert_error()` function approach.

**C# Integration**: C# operates as a managed language within Godot's runtime, where exceptions can occur at multiple levels - both in managed C# code and
during Godot engine callbacks. GdUnit4Net provides attribute-based testing that integrates with the .NET exception system and includes specialized
monitoring for exceptions that occur within Godot's main thread execution.

**Runtime Differences**: While GdScript errors are typically reported through Godot's logging system, C# exceptions follow the .NET exception model.
Additionally, many C# exceptions that occur during Godot callbacks (like `_Ready()`, `_Process()`) are caught and silently handled by
Godot's `CSharpInstanceBridge`, making them invisible to normal exception handling - hence the need for specialized monitoring.

## How the Approaches Differ

In **GdScript**, `assert_error` tests for Godot runtime errors such as failing asserts, script runtime errors, `push_error`, and `push_warning` messages.
In **C#**, GdUnit4Net provides advanced exception handling capabilities that can capture exceptions normally hidden by the Godot runtime.

{% tabs assert-error-overview %}
{% tab assert-error-overview GdScript %}
**GdUnitGodotErrorAssert**<br>

| Function                                                                                            | Description                                                    |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| [is_success]({{site.baseurl}}/testing/assert-error/#testing-for-success)                            | Verifies if the executed code runs without any runtime errors. |
| [is_runtime_error]({{site.baseurl}}/testing/assert-error/#testing-for-assert-failed)                | Verifies if the executed code runs into a runtime error.       |
| [is_push_warning]({{site.baseurl}}/testing/assert-error/#testing-for-push-warnings-and-push-errors) | Verifies if the executed code has a push_warning() used.       |
| [is_push_error]({{site.baseurl}}/testing/assert-error/#testing-for-push-warnings-and-push-errors)   | Verifies if the executed code has a push_error() used.         |

{% endtab %}
{% tab assert-error-overview C# %}
**Exception Testing Attributes**<br>

| Attribute                                                                                          | Description                                                                                                                   |
| -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [ThrowsException]({{site.baseurl}}/testing/assert-error/#c-exception-testing-with-throwsexception) | Verifies that a test method throws a specific exception type with optional message and location verification.                 |
| [GodotExceptionMonitor]({{site.baseurl}}/testing/assert-error/#godot-exception-monitoring)         | Monitors exceptions that occur during Godot's main thread execution, capturing exceptions normally hidden by Godot's runtime. |

{% endtab %}
{% endtabs %}

---

## GdScript Error Testing

### Testing for Success

To test whether a specific code snippet runs successfully without any errors, you can use the `is_success()` function with `assert_error`. Here's an example:

{% tabs assert-error-is_success %}
{% tab assert-error-is_success GdScript %}
```gd
func assert_error(<Callable>).is_success() -> GdUnitGodotErrorAssert:
```
```gd
func test_is_success() -> void:
    await assert_error(func(): <code to execute>).is_success()
```
{% endtab %}
{% tab assert-error-is_success C# %}
For C# exception testing, use the `[ThrowsException]` attribute. See the [C# Exception Testing](#c-exception-testing-with-throwsexception) section below.
{% endtab %}
{% endtabs %}

Replace `<code to execute>` with the actual code snippet you want to test. If the code executes without any runtime errors,
the test will pass; otherwise, it will fail.

### Testing for Assert Failed

You can use `assert_error` to verify that an assertion failure occurs during the execution of your code. This can help you ensure that your asserts
are working correctly. Here's an example:

{% tabs assert-error-is_failed %}
{% tab assert-error-is_failed GdScript %}
```gd
func assert_error(<Callable>).is_runtime_error(<message>) -> GdUnitGodotErrorAssert:
```

```gd
func test_is_assert_failed() -> void:
    await assert_error(func(): <code to execute>)\
        .is_runtime_error('Assertion failed: this is an assert error')
```
{% endtab %}
{% tab assert-error-is_failed C# %}
For C# exception testing, use the `[ThrowsException]` attribute. See the [C# Exception Testing](#c-exception-testing-with-throwsexception) section below.
{% endtab %}
{% endtabs %}

Replace `<code to execute>` with the code snippet that contains the assertion you want to test. The `is_runtime_error` function checks whether the
expected assertion error message is generated. If the assertion fails as expected, the test will pass; otherwise, it will fail.

### Testing for Push Warnings and Push Errors

You can also use `assert_error` to test for specific push warnings and push errors that may occur during the execution of your code.
Here are examples for both cases:

{% tabs assert-error-is_push %}
{% tab assert-error-is_push GdScript %}
```gd
func assert_error(<Callable>).is_push_warning(<message>) -> GdUnitGodotErrorAssert:
func assert_error(<Callable>).is_push_error(<message>) -> GdUnitGodotErrorAssert:
```
```gd
func test_is_push_warning() -> void:
    await assert_error(func(): <code to execute>)\
        .is_push_warning('this is a push_warning')

func test_is_push_error() -> void:
    await assert_error(func(): <code to execute>)\
        .is_push_error('this is a push_error')
```
{% endtab %}
{% tab assert-error-is_push C# %}
For C# exception testing, use the `[ThrowsException]` attribute. See the [C# Exception Testing](#c-exception-testing-with-throwsexception) section below.
{% endtab %}
{% endtabs %}

Replace `<code to execute>` with the relevant code snippet that may generate a push warning or a push error. The `is_push_warning` and `is_push_error`
functions check whether the expected warning or error message is generated during code execution. If the message is generated as expected,
the test will pass; otherwise, it will fail.

---

## C# Exception Testing with ThrowsException

GdUnit4Net provides the `[ThrowsException]` attribute for comprehensive exception testing in C#. This attribute allows you to verify that specific
exceptions are thrown with optional message and source location verification.

### Basic Exception Type Testing

Test that a specific exception type is thrown:

```cs
[TestCase]
[ThrowsException(typeof(ArgumentNullException))]
public void TestNullArgumentException()
{
    string? text = null;
    text!.Length; // Will throw ArgumentNullException
}
```

### Exception Message Testing

Verify both the exception type and message:

```cs
[TestCase]
[ThrowsException(typeof(ArgumentException), "The argument 'message' is invalid")]
public void TestSpecificExceptionMessage()
{
    throw new ArgumentException("The argument 'message' is invalid");
}
```

### Exception Location Testing

Verify exception type, message, and source location:

```cs
[TestCase]
[ThrowsException(typeof(TestFailedException), "Expecting: 'False' but is 'True'", 31)]
public void TestExceptionWithLineNumber()
{
    AssertBool(true).IsFalse(); // This will fail at the specified line
}
```

### Full Location Testing

Test with file and line number verification:

```cs
[TestCase]
[ThrowsException(typeof(InvalidOperationException), "Operation failed", "TestClass.cs", 42)]
public void TestExceptionWithFullLocation()
{
    throw new InvalidOperationException("Operation failed");
}
```

### Multiple Exception Types

You can specify multiple possible exception types for a single test:

```cs
[TestCase]
[ThrowsException(typeof(ArgumentNullException))]
[ThrowsException(typeof(InvalidOperationException))]
public void TestMultiplePossibleExceptions()
{
    // Test logic that might throw either exception type
}
```

### Timeout Exception Testing

Test for execution timeout exceptions:

```cs
[TestCase(Timeout = 100)]
[ThrowsException(typeof(ExecutionTimeoutException), "The execution has timed out after 100ms.")]
public async Task TestTimeoutException()
{
    await Task.Delay(500); // This will exceed the 100ms timeout
}
```

---

## Godot Exception Monitoring

GdUnit4Net provides the `[GodotExceptionMonitor]` attribute to capture exceptions that occur during Godot's main thread execution.
These exceptions are normally caught and hidden by Godot's `CSharpInstanceBridge.Call` method.

### Method-Level Monitoring

Monitor exceptions for a specific test method:

```cs
[TestCase]
[GodotExceptionMonitor]
[ThrowsException(typeof(InvalidOperationException), "TestNode '_Ready' failed.")]
public void TestNodeExceptionInReady()
{
    var sceneTree = (SceneTree)Engine.GetMainLoop();
    sceneTree.Root.AddChild(new TestNode()); // TestNode throws in _Ready()
}
```

### Class-Level Monitoring

Monitor exceptions for all test methods in a class:

```cs
[TestSuite]
[GodotExceptionMonitor]
public class MyGodotTests
{
    [TestCase]
    public void TestSceneProcessing()
    {
        // All test methods automatically monitor Godot exceptions
        var scene = SceneLoader.Load("res://my_scene.tscn");
    }
}
```

### Scene Processing Exception Testing

Test exceptions during scene tree processing:

```cs
[TestCase]
[ThrowsException(typeof(InvalidProgramException), "Exception during scene processing")]
public async Task TestSceneException()
{
    var sceneRunner = ISceneRunner.Load("res://scenes/problematic_scene.tscn", true);
    await sceneRunner.SimulateFrames(10); // Exception occurs during frame processing
}
```

### Common Use Cases for Godot Exception Monitoring

💡 **Node Lifecycle Exceptions**: Capture exceptions in `_Ready`, `_Process`, `_Input`, and other Godot callback methods.

💡 **Scene Tree Operations**: Monitor exceptions during scene loading, node addition/removal, and tree traversal.

💡 **Signal Processing**: Detect exceptions in signal handlers and callback functions.

💡 **Resource Loading**: Catch exceptions during asset loading and resource management.

### Push Error Testing in CSharp

Test Godot push_error calls as test failures:

```cs
[TestCase]
[ThrowsException(typeof(TestFailedException), "Testing Godot PushError")]
public void TestPushErrorHandling()
{
    GD.PushError("Testing Godot PushError"); // Captured as TestFailedException
}
```

---

## Key Differences Between GdScript and CSharp

| Feature                     | GdScript                  | C#                                      |
| --------------------------- | ------------------------- | --------------------------------------- |
| Basic Error Testing         | `assert_error()` function | `[ThrowsException]` attribute           |
| Exception Type Verification | ✅                        | ✅                                      |
| Message Verification        | ✅                        | ✅                                      |
| Location Verification       | ❌                        | ✅                                      |
| Godot Exception Monitoring  | Limited                   | Advanced with `[GodotExceptionMonitor]` |
| Multiple Exception Types    | ❌                        | ✅                                      |
| Timeout Exception Testing   | ❌                        | ✅                                      |

⚠️ **Important**: Godot Exception Monitoring with `[GodotExceptionMonitor]` is only available in the C# API and provides capabilities
not available in GdScript testing.

## Conclusion

Error assertion capabilities in GdUnit4 provide comprehensive testing for both expected and unexpected error conditions.
While GdScript offers fundamental error testing through `assert_error`, the C# API provides advanced exception handling with precise control over
exception verification and Godot runtime exception monitoring.
