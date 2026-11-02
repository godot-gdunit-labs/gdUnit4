---
layout: default
title: Signals
parent: Scene Runner
grand_parent: Advanced Testing
nav_order: 6
---

# Signals

In asynchronous programming, you often need to wait for signals to be emitted before proceeding with your program's execution.
The Scene Runner provides several functions to help you wait for these signals efficiently.
These functions allow you to synchronize your tests or operations with events occurring in the scene, ensuring that your program flows as expected.

## Function Overview

{% tabs scene-runner-signals %}
{% tab scene-runner-signals GdScript %}

| Function                            | Description                                                                                                                                           |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [await_signal](#await_signal)       | Waits for the specified signal to be emitted by the scene. If the signal is not emitted within the given timeout, the operation fails.                |
| [await_signal_on](#await_signal_on) | Waits for the specified signal to be emitted by a particular source node. If the signal is not emitted within the given timeout, the operation fails. |

{% endtab %}
{% tab scene-runner-signals C# %}

| Function                          | Description                                                                                                                                           |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [AwaitSignal](#await_signal)      | Waits for the specified signal to be emitted by the scene. If the signal is not emitted within the given timeout, the operation fails.                |
| [AwaitSignalOn](#await_signal_on) | Waits for the specified signal to be emitted by a particular source node. If the signal is not emitted within the given timeout, the operation fails. |

{% endtab %}
{% endtabs %}

### await_signal

The **await_signal** function is used to pause execution until a specific signal is emitted by the scene.
This is particularly useful for testing or ensuring that certain conditions are met before continuing.
If the signal is not emitted within the specified timeout, the function will throw an error, indicating a failure in the expected signal emission.

{% tabs scene-runner-await_signal %}
{% tab scene-runner-await_signal GdScript %}

It takes the following arguments:

```gd
## Waits for the specified signal to be emitted by the scene. If the signal is not emitted within the given timeout, the operation fails.
## [member signal_name] : The name of the signal to wait for
## [member args] : The signal arguments as an array
## [member timeout] : The maximum duration (in milliseconds) to wait for the signal to be emitted before failing
func await_signal(signal_name: String, args := [], timeout := 2000 ) -> void:
```

Here is an example of how to use await_signal:

```gd
var runner := scene_runner("res://test_scene.tscn")

# grab the colorRect instance from the scene
var box1: ColorRect = runner.get_property("_box1")
var box2: ColorRect = runner.get_property("_box2")
var box3: ColorRect = runner.get_property("_box3")

# call function `start_color_cycle` to start the color cycle
runner.invoke("start_color_cycle")

# Wait for the signals `panel_color_change` emitted by the scene by a maximum of 100ms or fails
await runner.await_signal("panel_color_change", [box1, Color.RED], 100)
await runner.await_signal("panel_color_change", [box2, Color.BLUE], 100)
await runner.await_signal("panel_color_change", [box3, Color.GREEN], 100)
```

{% endtab %}
{% tab scene-runner-await_signal C# %}

It takes the following arguments:

```cs
/// <summary>
/// Waits for given signal is emited.
/// </summary>
/// <param name="signal">name of the signal to wait for</param>
/// <param name="args">expected signal arguments as an array</param>
/// <returns>Task to wait</returns>
Task AwaitSignal(string signal, params object[] args);
```

Here is an example of how to use AwaitSignal:

```cs
[TestCase]
public async Task ColorChangedSignals()
{
    var sceneRunner = ISceneRunner.Load("res://test_scene.tscn");

    // call function `start_color_cycle` to start the color cycle
    sceneRunner.Invoke("ColorCycle");

    await AwaitSignal(TestScene.SignalName.PanelColorChange, new Color(1, 0, 0)).WithTimeout(100);
    await AwaitSignal(TestScene.SignalName.PanelColorChange, new Color(0, 0, 1)).WithTimeout(100);
    await AwaitSignal(TestScene.SignalName.PanelColorChange, new Color(0, 1, 0)).WithTimeout(100);
}
```

{% endtab %}
{% endtabs %}

### await_signal_on

The **await_signal_on** function works similarly to await_signal, but it targets a specific node (source) within the scene.
This is useful when you want to wait for signals from a particular node rather than the entire scene.

{% tabs scene-runner-await_signal_on %}
{% tab scene-runner-await_signal_on GdScript %}

It takes the following arguments:

```gd
## Waits for the specified signal to be emitted by a particular source node. If the signal is not emitted within the given timeout, the operation fails.
## [member source] : the object from which the signal is emitted
## [member signal_name] : The name of the signal to wait for
## [member args] : The signal arguments as an array
## [member timeout] : tThe maximum duration (in milliseconds) to wait for the signal to be emitted before failing
func await_signal_on(source: Object, signal_name: String, args := [], timeout := 2000 ) -> void:
```

Here is an example of how to use await_signal_on:

```gd
var runner := scene_runner("res://test_scene.tscn")

# grab the colorRect instance from the scene
var box1: ColorRect = runner.get_property("_box1")
var box2: ColorRect = runner.get_property("_box2")
var box3: ColorRect = runner.get_property("_box3")

# call function `start_color_cycle` how is triggering the box1..box3 to emit the signal `color_change`
runner.start_color_cycle()

# Wait for the signals `color_change` emitted by the components `box1`, `box2` and `box3` by a maximum of 100ms or fails
await runner.await_signal_on(box1, "color_change", [Color.RED], 100)
await runner.await_signal_on(box2, "color_change", [Color.BLUE], 100)
await runner.await_signal_on(box3, "color_change", [Color.GREEN], 100)
```

{% endtab %}
{% tab scene-runner-await_signal_on C# %}

```cs
/// <summary>
///     Waits for the specified signal to be emitted by a particular source node.
///     If the signal is not emitted within the given timeout, the operation fails.
/// </summary>
/// <param name="source">The object from which the signal is emitted.</param>
/// <param name="signal">The name of the signal to wait.</param>
/// <param name="args">An optional set of signal arguments.</param>
/// <returns>Task to wait.</returns>
static async Task<ISignalAssert> AwaitSignalOn(GodotObject source, string signal, params Variant[] args)
```

```cs
[TestCase]
public async Task ColorChangedSignals()
{
    var sceneRunner = ISceneRunner.Load("res://test_scene.tscn");
    var box1 = sceneRunner.GetProperty<ColorRect>("Box1")!;
    var box2 = sceneRunner.GetProperty<ColorRect>("Box2")!;
    var box3 = sceneRunner.GetProperty<ColorRect>("Box3")!;

    // call function `start_color_cycle` to start the color cycle
    sceneRunner.Invoke("ColorCycle");

    await AwaitSignalOn(box1, TestScene.SignalName.PanelColorChange, new Color(1, 0, 0)).WithTimeout(100);
    await AwaitSignalOn(box2, TestScene.SignalName.PanelColorChange, new Color(0, 0, 1)).WithTimeout(100);
    await AwaitSignalOn(box3, TestScene.SignalName.PanelColorChange, new Color(0, 1, 0)).WithTimeout(100);
}
```

{% endtab %}
{% endtabs %}
