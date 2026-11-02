---
layout: default
title: Functions
parent: Scene Runner
grand_parent: Advanced Testing
nav_order: 7
---

## Functions

In asynchronous programming, it's often necessary to wait for a function to complete and obtain its result before continuing with your program.
The Scene Runner provides functions that allow you to wait for specific methods to return a value, with a specified timeout.
This is particularly useful in scenarios where you want to test or ensure the result of a method call within a certain timeframe.

## Function Overview

{% tabs scene-runner-await-functions %}
{% tab scene-runner-await-functions GdScript %}

| Function                        | Description                                                                                                                                                      |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [await_func](#await_func)       | Waits for a function in the scene to return a value. Returns a GdUnitFuncAssert object, which allows you to verify the result of the function call.              |
| [await_func_on](#await_func_on) | Waits for a function of a specific source node to return a value. Returns a GdUnitFuncAssert object, which allows you to verify the result of the function call. |

{% endtab %}
{% tab scene-runner-await-functions C# %}

| Function                        | Description                                                                                                                                                      |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [AwaitMethod](#await_func)      | Waits for a function in the scene to return a value. Returns a GdUnitFuncAssert object, which allows you to verify the result of the function call.              |
| [AwaitMethodOn](#await_func_on) | Waits for a function of a specific source node to return a value. Returns a GdUnitFuncAssert object, which allows you to verify the result of the function call. |

{% endtab %}
{% endtabs %}

### await_func

The **await_func** function pauses execution until a specified function in the scene returns a value.
It returns a [GdUnitFuncAssert]({{site.baseurl}}/testing/assert-function/#functionmethod-assertions) object, which provides a suite of
assertion methods to verify the returned value.

{% tabs scene-runner-await_func %}
{% tab scene-runner-await_func GdScript %}

It takes the following arguments:

```gd
## The await_func function pauses execution until a specified function in the scene returns a value.
## It returns a [GdUnitFuncAssert], which provides a suite of assertion methods to verify the returned value.
## [member func_name] : The name of the function to wait for.
## [member args] : Optional function arguments
func await_func(func_name: String, args := []) -> GdUnitFuncAssert:
```

Here is an example of how to use await_func:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Waits until the function `color_cycle()` returns black or fails after an timeout of 5s
await runner.await_func("color_cycle").wait_until(5000).is_equal("black")
```

{% endtab %}
{% tab scene-runner-await_func C# %}

It takes the following arguments:

```cs
/// <summary>
/// Returns a method awaiter to wait for a specific method result.
/// </summary>
/// <typeparam name="V">The expected result type</typeparam>
/// <param name="methodName">The name of the method to wait</param>
/// <returns>GodotMethodAwaiter</returns>
GdUnitAwaiter.GodotMethodAwaiter<V> AwaitMethod<V>(string methodName);
```

Here is an example of how to use AwaitMethod:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Waits until the function `color_cycle()` returns black or fails after an timeout of 5s
await runner.AwaitMethod<bool>("color_cycle").IsEqual("black").WithTimeout(5000);
```

{% endtab %}
{% endtabs %}

### await_func_on

The **await_func_on** function extends the functionality of await_func by allowing you to specify a source node within the scene.
It waits for a specified function on that node to return a value and returns
a [GdUnitFuncAssert]({{site.baseurl}}/testing/assert-function/#functionmethod-assertions) object for assertions.

{% tabs scene-runner-await_func_on %}
{% tab scene-runner-await_func_on GdScript %}

It takes the following arguments:

```gd
## The await_func_on function extends the functionality of await_func by allowing you to specify a source node within the scene.
## It waits for a specified function on that node to return a value and returns a [GdUnitFuncAssert] object for assertions.
## [member source] : The object where implements the function.
## [member func_name] : The name of the function to wait for.
## [member args] : optional function arguments
func await_func_on(source: Object, func_name: String, args := []) -> GdUnitFuncAssert:
```

Here is an example of how to use await_func_on:

```gd
var runner := scene_runner("res://test_scene.tscn")
# grab the colorRect instance from the scene
var box1: ColorRect = runner.get_property("_box1")

# call function `start_color_cycle` how is emit the signal 
box1.start_color_cycle()

# Waits until the function `has_parent()` on source `door` returns false or fails after an timeout of 100ms
await runner.await_func_on(box1, "panel_color_change", [box1, Color.RED]).wait_until(100).is_false()
```

{% endtab %}
{% tab scene-runner-await_func_on C# %}

It takes the following arguments:

```cs
This function is not yet supported in C#.
```

```cs
```

{% endtab %}
{% endtabs %}
