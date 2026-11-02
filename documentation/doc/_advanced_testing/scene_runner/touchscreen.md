---
layout: default
title: Touchscreen Inputs
parent: Scene Runner
grand_parent: Advanced Testing
nav_order: 4
---

# Simulate Touchscreen Inputs

This section provides an overview of how to simulate touchscreen interactions in your scene using the Scene Runner in GdUnit4.
These functions allow you to test different touch events, such as taps, drags, and drops, without requiring a physical touchscreen device.
For more detailed information on Godot touchscreen events, please refer to the [official Godot documentation](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html#touch-events){:target="_blank"}

## Function Overview

The functions listed below use the following classes to simulate touchscreen input events:

* [InputEventScreenTouch](https://docs.godotengine.org/en/stable/classes/class_inputeventscreentouch.html#class-inputeventscreentouch){:target="_blank"}
* [InputEventScreenDrag](https://docs.godotengine.org/en/stable/classes/class_inputeventscreendrag.html){:target="_blank"}

{% tabs scene-runner-overview %}
{% tab scene-runner-overview GdScript %}

| Function                                                                    | Description                                                              |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| [get_screen_touch_drag_position](#get_screen_touch_drag_position)           | Returns the actual position of the touch drag position by given index.   |
| [simulate_screen_touch_drag](#simulate_screen_touch_drag)                   | Simulates a touch screen drag event to given position.                   |
| [simulate_screen_touch_pressed](#simulate_screen_touch_pressed)             | Simulates a screen touch is pressed.                                     |
| [simulate_screen_touch_press](#simulate_screen_touch_press)                 | Simulates a screen touch is press (holding).                             |
| [simulate_screen_touch_release](#simulate_screen_touch_release)             | Simulates a screen touch is released.                                    |
| [simulate_screen_touch_drag_relative](#simulate_screen_touch_drag_relative) | Simulates a touch screen drag&drop to the relative coordinates (offset). |
| [simulate_screen_touch_drag_absolute](#simulate_screen_touch_drag_absolute) | Simulates a touch screen drop to the absolute coordinates.               |
| [simulate_screen_touch_drag_drop](#simulate_screen_touch_drag_drop)         | Simulates a touch screen drop&drop to the absolute coordinates.          |

{% endtab %}
{% tab scene-runner-overview C# %}

| Function | Description |
| -------- | ----------- |
|          |             |

### Not yet implemented

{% endtab %}
{% endtabs %}

## How to Simulate Touchscreen Interactions

To simulate touchscreen interactions in your scene, you can use the provided touchscreen simulation functions.
These functions allow you to mimic user touchscreen inputs for testing purposes. There are two main categories of functions:

* **Unfinished Functions**<br>
    Unfinished functions simulate ongoing touch actions without completing them immediately.
    They are ideal for scenarios where you need to simulate multi-touch interactions, such as holding down one finger while using another to perform gestures.
    The interaction is completed by calling a corresponding release function.

  * **[simulate_screen_touch_press](#simulate_screen_touch_press)**<br>
    Simulates a finger pressing down on the screen at a specified position.<br>
  * **[simulate_screen_touch_release](#simulate_screen_touch_release)**<br>
    Simulates a finger being lifted off the screen from a previously pressed position.

* **Finalized Functions**<br>
    Finalized functions simulate complete touchscreen actions, encompassing both the press and release events in a single function call.
    These are useful for simulating single-tap actions or gestures like swipes and drags.

  * **[get_screen_touch_drag_position](#get_screen_touch_drag_position)**<br>
    Retrieves the current drag position of a touchscreen input.<br>
  * **[simulate_screen_touch_drag](#simulate_screen_touch_drag)**<br>
    Simulates a drag gesture to a position.<br>
  * **[simulate_screen_touch_pressed](#simulate_screen_touch_pressed)**<br>
    Simulates a full press-and-release action at a specified position, mimicking a tap.<br>
  * **[simulate_screen_touch_drag_relative](#simulate_screen_touch_drag_relative)**<br>
    Simulates a drag gesture by moving the touch input relative to its current position.<br>
  * **[simulate_screen_touch_drag_absolute](#simulate_screen_touch_drag_absolute)**<br>
    Simulates a drag gesture by moving the touch input to an absolute position.<br>
  * **[simulate_screen_touch_drag_drop](#simulate_screen_touch_drag_drop)**<br>
    Simulates a drag-and-drop action, where a touch input is pressed, dragged to a target position, and then released.
  
{% include advice.html
content="To ensure input events are processed correctly, you must wait at least one frame cycle after simulating inputs.
Use the <b>await runner.await_input_processed()</b> function to accomplish this."
%}
See [Synchronize Inputs Events]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)

---

### get_screen_touch_drag_position

The **get_screen_touch_drag_position** function returns the current position of a drag event by its index.
This is useful for verifying the location of touch events during drag operations.

{% tabs scene-runner-func_name %}
{% tab scene-runner-func_name GdScript %}

It takes the following arguments:

```gd
## Returns the actual position of the touchscreen drag position by given index.
## [member index] : The touch index in the case of a multi-touch event.
func get_screen_touch_drag_position(index: int) -> Vector2:
```

Here is an example of how to use get_screen_touch_drag_position:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Example usage
var drag_position = runner.get_screen_touch_drag_position(0)
assert_that(drag_position).is_equal(Vector2(683, 339))

```

{% endtab %}
{% tab scene-runner-func_name C# %}

It takes the following arguments:

```cs
// Not yet implemented!
```

Here is an example of how to use GetScreenTouchDragPosition:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

```

{% endtab %}
{% endtabs %}

---

### simulate_screen_touch_drag

The **simulate_screen_touch_drag** function simulates a drag event from position. You can use this to start testing simple drag and drop interactions.

{% tabs scene-runner-func_name %}
{% tab scene-runner-func_name GdScript %}

It takes the following arguments:

```gd
## Simulates a touch screen drag event to given position.
## [member index] : The touch index in the case of a multi-touch event.
## [member position] : The drag start position, indicating the drag position.
func simulate_screen_touch_drag(index: int, position: Vector2) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_screen_touch_drag:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulate has touched the screen at position 50, 50
runner.simulate_screen_touch_pressed(0, Vector2(50, 50))
await runner.simulate_screen_touch_drag()

```

{% endtab %}
{% tab scene-runner-func_name C# %}

It takes the following arguments:

```cs
// Not yet implemented!
```

Here is an example of how to use SimulateScreenTouchDrag:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

```

{% endtab %}
{% endtabs %}

We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation
of the touchscreen input is complete before moving on to the next instruction.

---

### simulate_screen_touch_pressed

The **simulate_screen_touch_pressed** function simulates a touch pressed event at a specified position. You can use this to test simple tap interactions.

{% tabs scene-runner-func_name %}
{% tab scene-runner-func_name GdScript %}

It takes the following arguments:

```gd
## Simulates a screen touch is pressed.
## [member index] : The touch index in the case of a multi-touch event.
## [member position] : The position to touch the screen.
## [member double_tap] : If true, the touch's state is a double tab.
func simulate_screen_touch_pressed(index: int, position: Vector2, double_tap := false) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_screen_touch_pressed:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulate has touched the screen at position 683, 339
runner.simulate_screen_touch_pressed(0, Vector2(683, 339))
await runner.await_input_processed()

# Verify the position is set
assert_that(runner.get_screen_touch_drag_position(0)).is_equal(Vector2(683, 339))

```

{% endtab %}
{% tab scene-runner-func_name C# %}

It takes the following arguments:

```cs
// Not yet implemented!
```

Here is an example of how to use SimulateScreenTouchPressed:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

```

{% endtab %}
{% endtabs %}

We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation
of the touchscreen input is complete before moving on to the next instruction.

---

### simulate_screen_touch_press

The **simulate_screen_touch_press** function simulates a screen touch press without releasing it immediately, effectively simulating a "hold" action.

{% tabs scene-runner-func_name %}
{% tab scene-runner-func_name GdScript %}

It takes the following arguments:

```gd
## Simulates a screen touch press without releasing it immediately, effectively simulating a "hold" action.
## [member index] : The touch index in the case of a multi-touch event.
## [member position] : The position to touch the screen.
## [member double_tap] : If true, the touch's state is a double tab.
func simulate_screen_touch_press(index: int, position: Vector2, double_tap := false) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_screen_touch_press:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Setup touch is actual press and hold at position 683, 339
runner.simulate_screen_touch_press(0, Vector2(683, 339))
await _runner.await_input_processed()

# Verify the InputEventScreenTouch is emitted
assert_that(runner.get_screen_touch_drag_position(0)).is_equal(Vector2(683, 339))

```

{% endtab %}
{% tab scene-runner-func_name C# %}

It takes the following arguments:

```cs
// Not yet implemented!
```

Here is an example of how to use SimulateScreenTouchPress:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

```

{% endtab %}
{% endtabs %}

We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation
of the touchscreen input is complete before moving on to the next instruction.

---

### simulate_screen_touch_release

The **simulate_screen_touch_release** function simulates the release of a screen touch event.
This can be used in combination with simulate_screen_touch_press to complete a tap or hold interaction.

{% tabs scene-runner-func_name %}
{% tab scene-runner-func_name GdScript %}

It takes the following arguments:

```gd
## Simulates a screen touch is released.
## [member index] : The touch index in the case of a multi-touch event.
## [member double_tap] : If true, the touch's state is a double tab.
func simulate_screen_touch_release(index: int, double_tap := false) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_screen_touch_release:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Setup touch is actual press and hold at position 683, 339
runner.simulate_screen_touch_press(0, Vector2(683, 339))
# ...

# Simulate release the touche press
runner.simulate_screen_touch_release(0)
await _runner.await_input_processed()

# continue your checks here

```

{% endtab %}
{% tab scene-runner-func_name C# %}

It takes the following arguments:

```cs
// Not yet implemented!
```

Here is an example of how to use SimulateScreenTouchRelease:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

```

{% endtab %}
{% endtabs %}

We use **[await_input_processed()]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)** to ensure that the simulation of
the touchscreen input is complete before moving on to the next instruction.

---

### simulate_screen_touch_drag_relative

The **simulate_screen_touch_drag_relative** function simulates a touch drag and drop event to a relative position.
Use this function to test drag-and-drop mechanics that move objects by a specified offset.

{% tabs scene-runner-func_name %}
{% tab scene-runner-func_name GdScript %}

It takes the following arguments:

```gd
## Simulates a touch drag and drop event to a relative position.
## [member index] : The touch index in the case of a multi-touch event.
## [member relative] : The relative position, indicating the drag&drop position offset.
## [member time] : The time to move to the relative position in seconds (default is 1 second).
## [member trans_type] : Sets the type of transition used (default is TRANS_LINEAR).
func simulate_screen_touch_drag_relative(index: int, relative: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_screen_touch_drag_relative:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Set the initial touch pressing at position 50, 50
runner.simulate_screen_touch_press(0, Vector2(50, 50))
# And drop it at relative to begin position by offset (100, 0)
await runner.simulate_screen_touch_drag_relative(0, Vector2(100, 0))
```

{% endtab %}
{% tab scene-runner-func_name C# %}

It takes the following arguments:

```cs
// Not yet implemented!
```

Here is an example of how to use SimulateScreenTouchDragRelative:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

```

{% endtab %}
{% endtabs %}

---

### simulate_screen_touch_drag_absolute

The **simulate_screen_touch_drag_absolute** function simulates a touch drag and drop event to an absolute position.
Use this function to test scenarios where an object needs to be moved to a specific location.

{% tabs scene-runner-func_name %}
{% tab scene-runner-func_name GdScript %}

It takes the following arguments:

```gd
## Simulates a touch screen drop to the absolute coordinates (offset).
## [member index] : The touch index in the case of a multi-touch event.
## [member position] : The final position, indicating the drop position.
## [member time] : The time to move to the final position in seconds (default is 1 second).
## [member trans_type] : Sets the type of transition used (default is TRANS_LINEAR).
func simulate_screen_touch_drag_absolute(index: int, position: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_screen_touch_drag_absolute:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Set the initial touch pressing at position 50, 50
runner.simulate_screen_touch_press(0, Vector2(50, 50))
# Simulate a drag to absolute position 150, 50
await runner.simulate_screen_touch_drag_absolute(0, Vector2(150, 50))
```

{% endtab %}
{% tab scene-runner-func_name C# %}

It takes the following arguments:

```cs
// Not yet implemented!
```

Here is an example of how to use SimulateScreenTouchDragAbsolute:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

```

{% endtab %}
{% endtabs %}

---

### simulate_screen_touch_drag_drop

The **simulate_screen_touch_drag_drop** function simulates a complete drag and drop event from one position to another.
This is ideal for testing complex drag-and-drop scenarios that require a specific start and end position.

{% tabs scene-runner-func_name %}
{% tab scene-runner-func_name GdScript %}

It takes the following arguments:

```gd
## Simulates a complete drag and drop event from one position to another.
## [member index] : The touch index in the case of a multi-touch event.
## [member position] : The drag start position, indicating the drag position.
## [member drop_position] : The drop position, indicating the drop position.
## [member time] : The time to move to the final position in seconds (default is 1 second).
## [member trans_type] : Sets the type of transition used (default is TRANS_LINEAR).
func simulate_screen_touch_drag_drop(index: int, position: Vector2, drop_position: Vector2, time: float = 1.0, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_screen_touch_drag_drop:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulates a full drag and drop from position 50, 50 to 100, 50
await runner.simulate_screen_touch_drag_drop(0, Vector2(50, 50), Vector2(100,50))

```

{% endtab %}
{% tab scene-runner-func_name C# %}

It takes the following arguments:

```cs
// Not yet implemented!
```

Here is an example of how to use SimulateScreenTouchDragDrop:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

```

{% endtab %}
{% endtabs %}
