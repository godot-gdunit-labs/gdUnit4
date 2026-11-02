---
layout: default
title: Accessors
parent: Scene Runner
grand_parent: Advanced Testing
nav_order: 8
---

# Scene Accessors

In addition to simulating the scene, the SceneRunner provides functions to access the scene's nodes.
These functions are useful for debugging and testing purposes.

For example, you can use **find_child()** to retrieve a specific node in the scene, and then call its methods or change its properties to test its behavior.

By using these functions, you can gain greater control over the scene and test various scenarios,
making it easier to find and fix bugs and improve the overall quality of your game or application.

## Function Overview

{% tabs scene-runner-accessors %}
{% tab scene-runner-accessors GdScript %}

| Function                                                                                | Description                                                                  |
|-----------------------------------------------------------------------------------------|------------------------------------------------------------------------------|
| [get_property]({{site.baseurl}}/advanced_testing//scene_runner/accessors/#get_property) | Return the current value of a property.                                      |
| [set_property]({{site.baseurl}}/advanced_testing//scene_runner/accessors/#set_property) | Sets the value of the property with the specified name.                      |
| [find_child]({{site.baseurl}}/advanced_testing//scene_runner/accessors/#find_child)     | Searches for the specified node with the name in the current scene.          |
| [invoke]({{site.baseurl}}/advanced_testing//scene_runner/accessors/#invoke)             | Executes the function specified by name in the scene and returns the result. |
| [scene]({{site.baseurl}}/advanced_testing/scene_runner/accessors/#scene)                | Gets access to the current running scene.                                    |

{% endtab %}
{% tab scene-runner-accessors C# %}

| Function                                                                              | Description                                                                  |
|---------------------------------------------------------------------------------------|------------------------------------------------------------------------------|
| [GetProperty]({{site.baseurl}}/advanced_testing/scene_runner/accessors/#get_property) | Return the current value of a property.                                      |
| [SetProperty]({{site.baseurl}}/advanced_testing/scene_runner/accessors/#set_property) | Sets the value of the property with the specified name.                      |
| [FindChild]({{site.baseurl}}/advanced_testing/scene_runner/accessors/#find_child)     | Searches for the specified node with the name in the current scene.          |
| [Invoke]({{site.baseurl}}/advanced_testing/scene_runner/accessors/#invoke)            | Executes the function specified by name in the scene and returns the result. |
| [Scene]({{site.baseurl}}/advanced_testing/scene_runner/accessors/#scene)              | Gets access to the current running scene.                                    |

{% endtab %}
{% endtabs %}

### get_property

The **get_property** function returns the current value of the property from the current scene.

{% tabs scene-runner-get_property %}
{% tab scene-runner-get_property GdScript %}

It takes the following arguments:

```gd
# name: the name of the property
# returns the actual value of the property
func get_property(name: String) -> Variant:
```

Here is an example of how to use get_property:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Returns the current property `_door_color` from the scene
var color: ColorRect = runner.get_property("_door_color")
```

{% endtab %}
{% tab scene-runner-get_property C# %}

It takes the following arguments:

```cs
/// <summary>
/// Returns the property by given name.
/// </summary>
/// <typeparam name="T">The type of the property</typeparam>
/// <param name="name">The parameter name</param>
/// <returns>The value of the property or throws a MissingFieldException</returns>
/// <exception cref="MissingFieldException"/>
public T GetProperty<T>(string name);
```

Here is an example of how to use GetProperty:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Returns the current property `_door_color` from the scene
ColorRect color = runner.GetProperty("_door_color");
```

{% endtab %}
{% endtabs %}

### set_property

The **set_property** function sets the value of a property with the specified name.

{% tabs scene-runner-set_property %}
{% tab scene-runner-set_property GdScript %}

It takes the following arguments:

```gd
# name: the name of the property.
# value: the value to be assigned to the property.
# returns true|false depending on valid property name.
func set_property(name: String, value: Variant) -> bool:
```

Here is an example of how to use set_property:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Sets the property `_door_color` to Red
runner.set_property("_door_color", Color.RED)
```

{% endtab %}
{% tab scene-runner-set_property C# %}

It takes the following arguments:

```cs
/// <summary>
/// Sets the value of the property with the specified name.
/// </summary>
/// <param name="name">The name of the property.</param>
/// <param name="value">The value to set for the property.</param>
/// <exception cref="MissingFieldException"/>
public T SetProperty<T>(string name, Variant value);
```

Here is an example of how to use SetProperty:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Sets the property `_door_color` to Red
runner.SetProperty("_door_color", Colors.Red);
```

{% endtab %}
{% endtabs %}

### find_child

The **find_child** function searches for a node with the specified name in the current scene and returns it. If the node is not found, it returns null.

{% tabs scene-runner-find_child %}
{% tab scene-runner-find_child GdScript %}

```gd
## [member name] : the name of the node to find
## [member recursive] : enables/disables seraching recursive
## [member owned] : is set to true it only finds nodes who have an assigned owner
## [member return] : the node if find otherwise null
func find_child(name: String, recursive := true, owned := false) -> Node:
```

Here is an example of how to use find_child:

```gd
 var runner := scene_runner("res://test_scene.tscn")
 
 # Searchs for node `Spell` inside the scene tree
 var spell: Node = runner.find_child("Spell")
```

{% endtab %}
{% tab scene-runner-find_child C# %}

```cs
/// <summary>
/// Find a child located in the current scene.
/// </summary>
/// <param name="name">The name of the node to find.</param>
/// <param name="recursive">Enables/disables searching recursively.</param>
/// <param name="owned">If set to true, it only finds nodes who have an assigned owner.</param>
/// <returns>The node if found, otherwise null.</returns>
Node FindChild(string name, bool recursive = true, bool owned = false) -> Node:
```

```cs
var runner = ISceneRunner.Load("res://test_scene.tscn");

// Searches for the node `Health` inside the scene tree
var output = runner.FindChild("Health", true, true) as HealthComponent;
```

{% endtab %}
{% endtabs %}

### invoke

The **invoke** function runs the function specified by given name in the scene and returns the result.

{% tabs scene-runner-invoke %}
{% tab scene-runner-invoke GdScript %}

It takes the following arguments:

```gd
# name: the name of the function to execute
# optional function args 0..9
# return: the function result
func invoke(name: String, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9):
```

Here is an example of how to use invoke:

```gd
var runner := scene_runner("res://test_scene.tscn")

# Invokes the function `start_color_cycle`
runner.invoke("start_color_cycle")
```

{% endtab %}
{% tab scene-runner-invoke C# %}

It takes the following arguments:

```cs
/// <summary>
/// Invokes the method by given name and arguments.
/// </summary>
/// <param name="name">The name of method to invoke</param>
/// <param name="args">The function arguments</param>
/// <returns>The return value of invoked method</returns>
/// <exception cref="MissingMethodException"/>
public object Invoke(string name, params object[] args);
```

Here is an example of how to use Invoke:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Invokes the function `start_color_cycle`
runner.Invoke("start_color_cycle");
```

{% endtab %}
{% endtabs %}

### scene

The **scene** function gets access to current loaded and managed scene by the SceneRunner.

{% tabs scene-runner-scene %}
{% tab scene-runner-scene GdScript %}

```gd
## Returns the scene instance that is currently loaded and managed by this SceneRunner.
## [member return] : The node representing the current running scene
func scene() -> Node:
```

Here is an example of how to use scene():

```gd
var runner := scene_runner("res://test_scene.tscn")

# Gets access to the scene instance
var my_scene := runner.scene()
```

{% endtab %}
{% tab scene-runner-scene C# %}

```cs
    /// <summary>
    ///     Access to the current running scene.
    ///     Returns the scene instance that is currently loaded and managed by this SceneRunner.
    ///     The scene remains available for testing and interaction until the runner is disposed
    ///     or the scene is explicitly freed.<br />
    ///     <br />
    ///     Lifecycle behavior:<br />
    ///     - Returns valid Node instance when scene is loaded and active<br />
    ///     - Returns null when the SceneRunner has been disposed<br />
    ///     - Returns null when autoFree has cleaned up the scene<br />
    ///     <br />
    ///     Usage patterns:<br />
    ///     - Check for null before accessing scene properties or methods<br />
    ///     - Use in assertions to verify scene state and availability<br />
    ///     - Access child nodes through the returned scene instance.<br />
    /// </summary>
    /// <returns>
    ///     The current scene Node instance, or null when the SceneRunner is disposed
    ///     or the scene has been freed.
    /// </returns>
    Node? Scene();
```

Here is an example of how to use Invoke:

```cs
ISceneRunner runner = ISceneRunner.Load("res://test_scene.tscn");

// Invokes the function `start_color_cycle`
var currentScene = runner.Scene();
```

{% endtab %}
{% endtabs %}
