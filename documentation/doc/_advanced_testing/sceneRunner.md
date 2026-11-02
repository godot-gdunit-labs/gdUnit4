---
layout: default
title: Scene Runner
parent: Advanced Testing
nav_order: 9
has_children: true
has_toc: false
---

# Scene Runner

## Definition

The Scene Runner is a tool used for simulating interactions on a scene. With this tool, you can simulate input events such as keyboard or mouse input
and/or simulate scene processing over a certain number of frames.

This tool is typically used for integration testing a scene.
<figure class="video_container">
    <iframe width="560" height="315"
    src="https://www.youtube.com/embed/m6tYigD6Oe0?si=SgdLorwkoIGTJvNI"
    title="YouTube video player" frameborder="0"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen>
    </iframe>
</figure>
For more advanced example, see [Tutorial - Testing Scenes]({{site.baseurl}}/tutorials/scenerunner_examples/#testing-scene-interactions)

## How to Use It

The Scene Runner is managed by the GdUnit API and is automatically freed after use. One Scene Runner can only manage one scene.
If you need to test multiple scenes, you must create a separate runner for each scene in your test suite.

{% tabs scene-runner-definition %}
{% tab scene-runner-definition GdScript %}
To use the Scene Runner, load the scene to be tested with **scene_runner(\<scene\>)**.

```gd
var runner := scene_runner("res://my_scene.tscn")
```

{% endtab %}
{% tab scene-runner-definition C# %}
To use the Scene Runner, load the scene to be tested with **ISceneRunner.Load(\<scene\>)**.

```cs
ISceneRunner runner = ISceneRunner.Load("res://my_scene.tscn");
```

{% endtab %}
{% endtabs %}

Here is a short example:
{% tabs scene-runner-example %}
{% tab scene-runner-example GdScript %}

```gd
func test_simulate_frames(timeout = 5000) -> void:
    # Create the scene runner for scene `test_scene.tscn`
    var runner := scene_runner("res://test_scene.tscn")
    
    # Get access to the loaded scene node
    var my_scene := runner.scene()

    # Get access to scene property '_box1'
    var box1: ColorRect = runner.get_property("_box1")
    # Verify it is initially set to white
    assert_object(box1.color).is_equal(Color.WHITE)
    
    # Start the color cycle by invoking the function 'start_color_cycle' and await 10 frames being processed
    runner.invoke("start_color_cycle")        
    await runner.simulate_frames(10)

    # After 10 frames, the color should have changed to black
    assert_object(box1.color).is_equal(Color.BLACK)
```

{% endtab %}
{% tab scene-runner-example C# %}

```cs
[TestCase]
public async Task simulate_frame() {
    // Create the scene runner for scene `test_scene.tscn`
    ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn"); 
    
    // Get access to the loaded scene node
    var my_scene = runner.Scene();

    // Get access to scene property '_box1'
    ColorRect box1 = runner.GetProperty("_box1");
    // Verify it is initially set to white
    AssertObject(box1.color).IsEqual(Color.WHITE);
    
    // Start the color cycle by invoking the function 'start_color_cycle' and await 10 frames being processed
    runner.Invoke("start_color_cycle")        
    await runner.SimulateFrames(10);

    // After 10 frames, the color should have changed to black
    AssertObject(box1.color).IsEqual(Color.BLACK);
}
```

{% endtab %}
{% endtabs %}

## Function Overview

* [Processing your Scene](#processing-and-rendering-your-scene)
* [Simulate Action Inputs]({{site.baseurl}}/advanced_testing/scene_runner/actions/#simulate-actions)
* [Simulate Key Inputs]({{site.baseurl}}/advanced_testing/scene_runner/keys/#simulate-key-inputs)
* [Simulate Mouse Inputs]({{site.baseurl}}/advanced_testing/scene_runner/mouse/#simulate-mouse-inputs)
* [Simulate Touchscreen Inputs]({{site.baseurl}}/advanced_testing/scene_runner/touchscreen/#simulate-touchscreen-inputs)
* [Synchronize Inputs Events]({{site.baseurl}}/advanced_testing/scene_runner/sync_inputs/#synchronize-inputs-events)
* [Wait for Function Results]({{site.baseurl}}/advanced_testing/scene_runner/functions/#functions)
* [Wait for Signals]({{site.baseurl}}/advanced_testing/scene_runner/signals/#signals)
* [Scene Accessors]({{site.baseurl}}/advanced_testing/scene_runner/accessors/#accessors)

---

## Processing and Rendering Your Scene

This section provides guidance on how to process and render your scene during tests using GdUnit4.

{% tabs scene-runner-processing %}
{% tab scene-runner-processing GdScript %}

| Function                                                | Description                                                                            |
| ------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| [simulate_frames](#simulate_frames)                     | Simulates scene processing for a certain number of frames (respecting time factor).    |
| [set_time_factor](#set_time_factor)                     | Sets how fast or slow the scene simulation is processed (clock ticks versus the real). |
| [move_window_to_foreground](#move_window_to_foreground) | Restores the scene window to a windowed mode and brings it to the foreground.          |

{% endtab %}
{% tab scene-runner-processing C# %}

| Function                                             | Description                                                                            |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------- |
| [SimulateFrames](#simulate_frames)                   | Simulates scene processing for a certain number of frames (respecting time factor).    |
| [SetTimeFactor](#set_time_factor)                    | Sets how fast or slow the scene simulation is processed (clock ticks versus the real). |
| [MoveWindowToForeground](#move_window_to_foreground) | Restores the scene window to a windowed mode and brings it to the foreground.          |

{% endtab %}
{% endtabs %}

### simulate_frames

The **simulate_frames** function allows you to simulate the processing and rendering of a specified number of frames in your scene.
This is particularly useful for testing and debugging, as it provides a way to advance the scene's state over time without user input or external triggers.

This function is useful when you need to validate behaviors that depend on frame updates, such as animations, physics, and scripted events.<br>
Simulate frame progression in your scene to test animations, interactions, and time-based logic under controlled conditions.<br>

{% tabs scene-runner-simulate_frames %}
{% tab scene-runner-simulate_frames GdScript %}
It takes the following arguments:

```gd
# frames: the number of frames to process
# delta_ms: the time delta between each frame in milliseconds, by default no delay is set.
func simulate_frames(frames: int, delta_ms := -1) -> GdUnitSceneRunner:
```

Here is an example of how to use simulate_frames:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulate scene processing over 60 frames at normal speed
await runner.simulate_frames(60)

# Simulate 60 frames with a delay of 100ms between each frame
await runner.simulate_frames(60, 100)
```

{% endtab %}
{% tab scene-runner-simulate_frames C# %}
It takes the following arguments:

```cs
/// <summary>
/// Simulates scene processing for a certain number of frames by given delta peer frame by ignoring the current time factor
/// </summary>
/// <param name="frames">the number of frames to process</param>
/// <param name="deltaPeerFrame">the time delta between each frame in milliseconds, by default no delay is set.</param>
/// <returns>Task to wait</returns>
Task SimulateFrames(uint frames, uint deltaPeerFrame);
```

Here is an example of how to use SimulateFrames:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Simulate scene processing over 60 frames at normal speed
await runner.SimulateFrames(60);

// Simulate scene processing over 60 frames with a delay of 100ms between each frame
await runner.SimulateFrames(60, 100);
```

{% endtab %}
{% endtabs %}

### set_time_factor

The **set_time_factor** function adjusts the speed at which the scene simulation is processed relative to real time.<br>
This is useful for testing in different gameplay speeds, debugging time-dependent interactions.

{% tabs scene-runner-set_time_factor %}
{% tab scene-runner-set_time_factor GdScript %}
It takes the following arguments:

```gd
## Sets the time factor for the scene simulation.
## [member time_factor] : A float representing the simulation speed.
## - Default is 1.0, meaning the simulation runs at normal speed.
## - A value of 2.0 means the simulation runs twice as fast as real time.
## - A value of 0.5 means the simulation runs at half the regular speed.
func set_time_factor(time_factor: float = 1.0) -> GdUnitSceneRunner:
```

Here is an example of how to use set_time_factor:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Set the simulation speed to five times faster as the normal speed.
runner.set_time_factor(5)

# Simulated 60 frames ~5 times faster now  
await runner.simulate_frames(60)
```

{% endtab %}
{% tab scene-runner-set_time_factor C# %}
It takes the following arguments:

```cs
/// <summary>
/// Sets how fast or slow the scene simulation is processed (clock ticks versus the real).
/// </summary>
/// <param name="timeFactor"></param>
/// <returns>SceneRunner</returns>
ISceneRunner SetTimeFactor(double timeFactor = 1.0);
```

Here is an example of how to use SetTimeFactor:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");
// Set the simulation speed to five times faster as the normal speed.
runner.SetTimeFactor(5);
// Simulated 60 frames ~5 times faster now  
await runner.SimulateFrames(60);
```

{% endtab %}
{% endtabs %}

### move_window_to_foreground

The **move_window_to_foreground** function restores the scene window to a windowed mode and brings it to the foreground.<br>
This ensures that the scene is visible and active during testing, making it easier to observe and interact with,
as the window are minimized or moved to the background after each test.<br>
<br>
This function is essential for scenarios where the scene needs to be actively monitored or interacted with during automated tests.
Without it, the scene may not be visible or accessible, which can hinder the debugging process.

{% tabs scene-runner-move_window_to_foreground %}
{% tab scene-runner-move_window_to_foreground GdScript %}

```gd
## Restores the scene window to a windowed mode and brings it to the foreground.
## This ensures that the scene is visible and active during testing, making it easier to observe and interact with.
func move_window_to_foreground() -> GdUnitSceneRunner:
```

Here is an example of how to use move_window_to_foreground:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Shows the running scene and moves the window to the foreground
runner.move_window_to_foreground()
```

{% endtab %}
{% tab scene-runner-move_window_to_foreground C# %}

```cs
/// <summary>
/// Shows the running scene and moves the window to the foreground. 
/// </summary>
void MoveWindowToForeground();
```

Here is an example of how to use MoveWindowToForeground:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");
// Shows the running scene and moves the window to the foreground
runner.MoveWindowToForeground();
```

{% endtab %}
{% endtabs %}
