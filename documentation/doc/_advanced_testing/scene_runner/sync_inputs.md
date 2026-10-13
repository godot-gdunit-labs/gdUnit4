---
layout: default
title: Synchronize Inputs
parent: Scene Runner
grand_parent: Advanced Testing
nav_order: 5
---

## Synchronize Inputs Events

Waits for all input events to be processed by flushing any buffered input events and then awaiting a full cycle of both the process and physics frames.<br>

This is typically used to ensure that any simulated or queued inputs are fully processed before proceeding with the next steps in the scene.<br>
**It's essential for reliable input simulation or when synchronizing logic based on inputs.**<br>

### await_input_processed

The **await_input_processed** function do wait until all input events are processed.<br>

{% tabs scene-runner-await_input_processed %}
{% tab scene-runner-await_input_processed GdScript %}

```gd
### Waits for all input events are processed
func await_input_processed() -> void:
```

Here is an example of how to use simulate_frames:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Simulates key combination ctrl+C is pressed
runner.simulate_key_press(KEY_CTRL)
runner.simulate_key_pressed(KEY_C)

# finalize the input event processing
await runner.await_input_processed()
```

{% endtab %}
{% tab scene-runner-await_input_processed C# %}

```cs
/// <summary>
///     Waits for all input events to be processed by flushing any buffered input events and then awaiting a full cycle of
///     both the process and physics frames.
///     This is typically used to ensure that any simulated or queued inputs are fully processed before proceeding with the
///     next steps in the scene.
///     It's essential for reliable input simulation or when synchronizing logic based on inputs.
/// </summary>
public static Task AwaitInputProcessed()
```

Here is an example of how to use AwaitInputProcessed:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Simulates key combination ctrl+C is pressed
runner
    .SimulateKeyPress(Key.Ctrl)
    .SimulateKeyPress(Key.C);

// finalize the input event processing
await runner.AwaitInputProcessed();
```

{% endtab %}
{% endtabs %}
