---
layout: default
title: Key Inputs
parent: Scene Runner
grand_parent: Advanced Testing
nav_order: 2
---


# Simulate Key Inputs

This page provides guidance on how to test key inputs in your scene using GdUnit4.
For more detailed information on Godot keyboard events, please refer to
the [official Godot documentation](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html#keyboard-events){:target="_blank"}

## Function Overview

All functions listed below utilize the
[InputEventKey](https://docs.godotengine.org/en/stable/classes/class_inputeventkey.html#class-inputeventkey){:target="_blank"} class to simulate key input events.

{% tabs scene-runner-overview %}
{% tab scene-runner-overview GdScript %}

|Function|Description|
|---|---|
|[simulate_key_pressed](#simulate_key_pressed) | Simulates that a key has been pressed. |
|[simulate_key_press](#simulate_key_press) | Simulates that a key is pressed. |
|[simulate_key_release](#simulate_key_release) | Simulates that a key has been released. |

{% endtab %}
{% tab scene-runner-overview C# %}

|Function|Description|
|---|---|
|[SimulateKeyPressed](#simulate_key_pressed) | Simulates that a key has been pressed. |
|[SimulateKeyPress](#simulate_key_press) | Simulates that a key is pressed. |
|[SimulateKeyRelease](#simulate_key_release) | Simulates that a key has been released. |

{% endtab %}
{% endtabs %}

## How to Simulate Key Interactions

To simulate key interactions in your scene, you can use the provided key simulation functions.
These functions allow you to mimic user key inputs for testing purposes. There are two main categories of functions:

* **Unfinished Functions**<br>
    Unfinished functions simulate the act of pressing a key without releasing it immediately.
    These are useful for simulating combinations, such as holding down a modifier key (e.g., Ctrl) while pressing another key (e.g., C for Ctrl+C).
    The interaction is completed when the key release function is called.

  * **[simulate_key_press](#simulate_key_press)**<br>
    Simulates pressing a key without releasing it.<br>
  * **[simulate_key_release](#simulate_key_release)**<br>
    Completes a key interaction by releasing the key.

* **Finalized Functions**<br>
    Finalized functions simulate a complete key press-and-release action in a single function call.

  * **[simulate_key_pressed](#simulate_key_pressed)**<br>
    Simulates a full key press-and-release interaction.
  
{% include advice.html
content="To ensure input events are processed correctly, you must wait at least one frame cycle after simulating inputs.
Use the <b>await runner.await_input_processed()</b> function to accomplish this."
%}
See [Synchronize Inputs Events]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)

---

### simulate_key_pressed

The **simulate_key_pressed** function is used to simulate that a key has been pressed.

{% tabs scene-runner-simulate_key_pressed %}
{% tab scene-runner-simulate_key_pressed GdScript %}

It takes the following arguments:

```gd
# key_code: an integer value representing the key code of the key being pressed, e.g. KEY_ENTER for the enter key.
# shift: a boolean value indicating whether the shift key should be simulated as being pressed along with the main key. It is false by default.
# control: a boolean value indicating whether the control key should be simulated as being pressed along with the main key. It is false by default.
# meta: a boolean value indicating whether the meta key should be simulated as being pressed along with the main key. It is false by default.
func simulate_key_pressed(key_code: int, shift := false, control := false, meta := false) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_key_pressed:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulate the enter key is pressed
runner.simulate_key_pressed(KEY_ENTER)
await runner.await_input_processed()

# Simulates key combination ctrl+C is pressed
runner.simulate_key_pressed(KEY_C, false, true)
await runner.await_input_processed()
```

{% endtab %}
{% tab scene-runner-simulate_key_pressed C# %}

It takes the following arguments:

```cs
/// <summary>
/// Simulates that a key has been pressed.
/// </summary>
/// <param name="keyCode">an integer value representing the key code of the key being pressed, e.g. KEY_ENTER for the enter key.</param>
/// <param name="shift">a boolean value indicating whether the shift key should be simulated as being pressed along with the main key. It is false by default.</param>
/// <param name="control">a boolean value indicating whether the control key should be simulated as being pressed along with the main key. It is false by default.</param>
/// <param name="meta">a boolean value indicating whether the meta key should be simulated as being pressed along with the main key. It is false by default.</param>
/// <returns>SceneRunner</returns>
ISceneRunner SimulateKeyPressed(KeyList keyCode, bool shift = false, bool control = false, bool meta = false);
```

Here is an example of how to use SimulateKeyPressed:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Simulate the enter key is pressed
runner.SimulateKeyPressed(KeyList.Enter);
await runner.AwaitInputProcessed();

// Simulates key combination ctrl+C is pressed
runner.SimulateKeyPressed(KeyList.C, false, true);
await runner.AwaitInputProcessed();
```

{% endtab %}
{% endtabs %}

In this example, we simulate that the enter key is pressed and then we simulate that the key combination ctrl+C is pressed.
We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation
of the key press is complete before moving on to the next instruction.

### simulate_key_press

The **simulate_key_press** function is used to simulate that a key holding down.

{% tabs scene-runner-simulate_key_press %}
{% tab scene-runner-simulate_key_press GdScript %}

It takes the following arguments:

```gd
# key_code : an integer value representing the key code of the key being press e.g. KEY_ENTER for the enter key.
# shift : a boolean value indicating whether the shift key should be simulated as being press along with the main key. It is false by default.
# control : a boolean value indicating whether the control key should be simulated as being press along with the main key. It is false by default.
# meta : a boolean value indicating whether the meta key should be simulated as being press along with the main key. It is false by default.
func simulate_key_press(key_code: int, shift := false, control := false, meta := false) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_key_press:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulate the enter key is press
runner.simulate_key_press(KEY_ENTER)
await runner.await_input_processed()

# Simulates key combination ctrl+C is press in one function call
runner.simulate_key_press(KEY_C, false, true)
await runner.await_input_processed()

# Simulates multi key combination ctrl+alt+C is press
runner.simulate_key_press(KEY_CTRL)
runner.simulate_key_press(KEY_ALT)
runner.simulate_key_press(KEY_C)
await runner.await_input_processed()
```

{% endtab %}
{% tab scene-runner-simulate_key_press C# %}

It takes the following arguments:

```cs
/// <summary>
/// Simulates that a key is press.
/// </summary>
/// <param name="keyCode">an integer value representing the key code of the key being press, e.g. KeyList.Enter for the enter key.</param>
/// <param name="shift">a boolean value indicating whether the shift key should be simulated as being press along with the main key. It is false by default.</param>
/// <param name="control">a boolean value indicating whether the control key should be simulated as being press along with the main key. It is false by default.</param>
/// <param name="meta">a boolean value indicating whether the meta key should be simulated as being press along with the main key. It is false by default.</param>
/// <returns>SceneRunner</returns>
ISceneRunner SimulateKeyPress(KeyList keyCode, bool shift = false, bool control = false, bool meta = false);
```

Here is an example of how to use SimulateKeyPress:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Simulate the enter key is press
runner.SimulateKeyPress(KeyList.Enter);
await runner.AwaitInputProcessed();

// Simulates key combination ctrl+C is press in one method call
runner.SimulateKeyPress(KeyList.C, false. true);
await runner.AwaitInputProcessed();

// Simulates multi key combination ctrl+alt+C is press
runner.SimulateKeyPress(KeyList.CTRL);
runner.SimulateKeyPress(KeyList.ALT);
runner.SimulateKeyPress(KeyList.C);
await runner.AwaitInputProcessed();
```

{% endtab %}
{% endtabs %}

In this example, we simulate that the enter key is press and then we simulate that the key combination ctrl+C is press.
We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation
of the key press is complete before moving on to the next instruction.

### simulate_key_release

The **simulate_key_release** function is used to simulate that a key has been released.

{% tabs scene-runner-simulate_key_release %}
{% tab scene-runner-simulate_key_release GdScript %}

It takes the following arguments:

```gd
# key_code : an integer value representing the key code of the key being released, e.g. KEY_ENTER for the enter key.
# shift : a boolean value indicating whether the shift key should be simulated as being released along with the main key. It is false by default.
# control : a boolean value indicating whether the control key should be simulated as being released along with the main key. It is false by default.
# meta : a boolean value indicating whether the meta key should be simulated as being released along with the main key. It is false by default.
func simulate_key_release(key_code: int, shift := false, control := false, meta := false) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_key_release:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulate a enter key is released
runner.simulate_key_release(KEY_ENTER)
await runner.await_input_processed()

# Simulates key combination ctrl+C is released in one function call
runner.simulate_key_release(KEY_C, false, true)
await runner.await_input_processed()

# Simulates multi key combination ctrl+alt+C is released
runner.simulate_key_release(KEY_CTRL)
runner.simulate_key_release(KEY_ALT)
runner.simulate_key_release(KEY_C)
await runner.await_input_processed()
```

{% endtab %}
{% tab scene-runner-simulate_key_release C# %}

It takes the following arguments:

```cs
/// <summary>
/// Simulates that a key has been released.
/// </summary>
/// <param name="keyCode">an integer value representing the key code of the key being released, e.g. KeyList.Enter for the enter key.</param>
/// <param name="shift">a boolean value indicating whether the shift key should be simulated as being released along with the main key. It is false by default.</param>
/// <param name="control">a boolean value indicating whether the control key should be simulated as being released along with the main key. It is false by default.</param>
/// <param name="meta">a boolean value indicating whether the meta key should be simulated as being released along with the main key. It is false by default.</param>
/// <returns>SceneRunner</returns>
ISceneRunner SimulateKeyRelease(KeyList keyCode, bool shift = false, bool control = false, bool meta = false);
```

Here is an example of how to use SimulateKeyRelease:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Simulate a enter key is released
runner.SimulateKeyRelease(KeyList.Enter);
await AwaitIdleFrame();

// Simulates key combination ctrl+C is released
runner.SimulateKeyRelease(KeyList.C, false, true);
await runner.AwaitInputProcessed();

// Simulates multi key combination ctrl+C is released
runner.SimulateKeyRelease(KeyList.CTRL);
runner.SimulateKeyRelease(KeyList.ALT);
runner.SimulateKeyRelease(KeyList.C);
await runner.AwaitInputProcessed();
```

{% endtab %}
{% endtabs %}

In this example, we simulate that the enter key is released and then we simulate that the key combination ctrl+C is released.
We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation
of the key press is complete before moving on to the next instruction.
