---
layout: default
title: Actions
parent: Scene Runner
grand_parent: Advanced Testing
nav_order: 1
---


# Simulate Actions

This page provides guidance on how to test actions in your scene using GdUnit4.
For more detailed information on Godot actions, please refer to
the [official Godot documentation](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html#actions){:target="_blank"}

## Function Overview

All functions listed below utilize the
[InputEventAction](https://docs.godotengine.org/en/stable/classes/class_inputeventaction.html){:target="_blank"} class to simulate action events.

{% tabs scene-runner-overview %}
{% tab scene-runner-overview GdScript %}

| Function                                            | Description                                 |
| --------------------------------------------------- | ------------------------------------------- |
| [simulate_action_pressed](#simulate_action_pressed) | Simulates that an action has been pressed.  |
| [simulate_action_press](#simulate_action_press)     | Simulates that an action is press.          |
| [simulate_action_release](#simulate_action_release) | Simulates that an action has been released. |

{% endtab %}
{% tab scene-runner-overview C# %}

| Function                                          | Description                                 |
| ------------------------------------------------- | ------------------------------------------- |
| [SimulateActionPressed](#simulate_action_pressed) | Simulates that an action has been pressed.  |
| [SimulateActionPress](#simulate_action_press)     | Simulates that an action is press.          |
| [SimulateActionRelease](#simulate_action_release) | Simulates that an action has been released. |

{% endtab %}
{% endtabs %}

## How to Simulate Actions

To simulate actions interactions in your scene, you can use the provided action simulation functions.
These functions allow you to mimic user key inputs as actions for testing purposes. There are two main categories of functions:

* **Unfinished Functions**<br>
    Unfinished functions simulate the act of pressing a action without releasing it immediately.
    These are useful for simulating combinations, such as holding down a modifier key (e.g., Ctrl) while pressing another key (e.g., C for Ctrl+C).
    The interaction is completed when the action release function is called.

  * **[simulate_action_press](#simulate_action_press)**<br>
    Simulates pressing a key without releasing it.<br>
  * **[simulate_action_release](#simulate_action_release)**<br>
    Completes a key interaction by releasing the key.

* **Finalized Functions**<br>
    Finalized functions simulate a complete press-and-release action in a single function call.

  * **[simulate_action_pressed](#simulate_action_pressed)**<br>
    Simulates a full action press-and-release interaction.
  
{% include advice.html
content="To ensure input events are processed correctly, you must wait at least one frame cycle after simulating inputs.
Use the <b>await runner.await_input_processed()</b> function to accomplish this."
%}
See [Synchronize Inputs Events]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)

---

### simulate_action_pressed

The **simulate_action_pressed** function is used to simulate that a input action has been pressed.

{% tabs scene-runner-simulate_action_pressed %}
{% tab scene-runner-simulate_action_pressed GdScript %}
It takes the following arguments:

```gd
# action: the action e.g. "ui_up"
func simulate_action_pressed(action: String) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_action_pressed:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulate the UP key is pressed by using the input action "ui_up"
runner.simulate_action_pressed("ui_up")
await runner.await_input_processed()
```

{% endtab %}
{% tab scene-runner-simulate_action_pressed C# %}
It takes the following arguments:

```cs
/// <summary>
/// Simulates that an action has been pressed.
/// </summary>
/// <param name="action">The name of the action, e.g., "ui_up".</param>
/// <returns>The SceneRunner instance.</returns>
ISceneRunner SimulateActionPressed(string action);
```

Here is an example of how to use SimulateActionPressed:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Simulate the UP key is pressed by using the input action "ui_up"
runner.SimulateActionPressed("ui_up");
await runner.AwaitInputProcessed();
```

{% endtab %}
{% endtabs %}

In this example, we simulate that the action "ui-up" is pressed.
We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation
of the action is complete before moving on to the next instruction.

### simulate_action_press

The **simulate_action_press** function is used to simulate that an input action holding down.

{% tabs scene-runner-simulate_action_press %}
{% tab scene-runner-simulate_action_press GdScript %}
It takes the following arguments:

```gd
# action: the action e.g. "ui_up"
func simulate_action_press(action: String) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_action_press:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulate the UP key is press by using the action "ui_up"
runner.simulate_action_press("ui_up")
await runner.await_input_processed()
```

{% endtab %}
{% tab scene-runner-simulate_action_press C# %}
It takes the following arguments:

```cs
/// <summary>
/// Simulates that an action is press.
/// </summary>
/// <param name="action">The name of the action, e.g., "ui_up".</param>
/// <returns>The SceneRunner instance.</returns>
ISceneRunner SimulateActionPress(string action);
```

Here is an example of how to use SimulateActionPress:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Simulate the UP key is press by using the action "ui_up"
runner.SimulateActionPress("ui_up");
await runner.AwaitInputProcessed();
```

{% endtab %}
{% endtabs %}

In this example, we simulate that the action "ui_up" is press.
We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation
of the action is complete before moving on to the next instruction.

### simulate_action_release

The **simulate_action_release** function is used to simulate that a input action been released.

{% tabs scene-runner-simulate_action_release %}
{% tab scene-runner-simulate_action_release GdScript %}

It takes the following arguments:

```gd
# action : the action e.g. "ui_up"
func simulate_action_release(action: String) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_action_release:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulate the UP key is released by using the action "ui_up"
runner.simulate_action_release("ui-up")
await runner.await_input_processed()
```

{% endtab %}
{% tab scene-runner-simulate_action_release C# %}

It takes the following arguments:

```cs
/// <summary>
/// Simulates that an action has been released.
/// </summary>
/// <param name="action">The name of the action, e.g., "ui_up".</param>
/// <returns>The SceneRunner instance.</returns>
ISceneRunner SimulateActionRelease(string action);
```

Here is an example of how to use SimulateActionRelease:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Simulate the UP key is released by using the action "ui_up"
runner.SimulateActionRelease("ui-up");
await runner.AwaitInputProcessed();
```

{% endtab %}
{% endtabs %}
In this example, we simulate that the action "ui_up" is released.
We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation
of the action is complete before moving on to the next instruction.
