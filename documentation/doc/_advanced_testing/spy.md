---
layout: default
title: Spying
parent: Advanced Testing
nav_order: 7
---

# Spy

{% include advice.html
content="This Spy implementation is only available for GDScripts, for C# you can use already existing mocking frameworks
like <a href='https://github.com/devlooped/moq' target='_blank'><b>Moq</b></a>"
%}

## Definition

A Spy is used to verify a certain behavior during a test and tracks all function calls and their parameters of an instance.

`var to_spy := spy(<instance>)`

## *What is the difference between a spy and an mock?*

In contrast to a mock, a spy calls the real implementation. It behaves in the same way as the normal instance.

---

## How to use a Spy

{% include advice.html
content="Spy on core functions are not possible since Godot has improved the GDScript performance.<br> According to the Godot core developers,
overwriting core functions is no longer supported, so there is no way to spy on core functions anymore."
%}

To spy on an object, simply use **spy(\<instance\>)**. The spy returned by **spy(\<instance\>)** is automatically registered for auto-freeing,
so you don't need to free the spy manually. The ownership of the original instance you pass in depends on whether you spy on an object or a scene.

### Spy on an object

The spy is created as a new instance, the original object you pass in is not touched and remains under your ownership.
Wrap it in **auto_free()** to have it released after the test.

```gd
# The returned spy is auto-freed, the original instance is released by auto_free()
var spy_node := spy(auto_free(Node.new()))
```

### Spy on a scene

The spy is not a new instance, the script is exchanged on the scene instance itself. The spied scene is auto-freed,
so no additional **auto_free()** is required. You can spy on a scene by its resource path or on an already instantiated scene.

```gd
# Spy on a scene by the resource path, the returned spy is the scene instance and is auto-freed
var spy_scene := spy("res://my_scene.tscn")

# Spy on an already instantiated scene, the instance itself becomes the spy and is auto-freed
var scene: Node = load("res://my_scene.tscn").instantiate()
var spy_on_instance := spy(scene)
```

Here a small example to use the spy on a instance of the class 'TestClass':

```gd
class_name TestClass
extends Node

    func message() -> String:
        return "a message"

func test_spy():
    var instance = auto_free(TestClass.new())

    # Build a spy on the instance
    var spy = spy(instance)

    # Call function `message` on the spy to track the interaction
    spy.message()

    # Verify the function 'message' is called one times
    verify(spy, 1).message()
```

## Verification of Function Calls

A spy keeps track of all function calls and their arguments. Use the **verify()** method on the spy to verify that certain behavior happened at least once
or an exact number of times. This way, you can check if a particular function was called and how many times it was called.

|Function |Description |
|---|---|
|[verify]({{site.baseurl}}/advanced_testing/spy/#verify) | Verifies that certain behavior happened at least once or an exact number of times.|
|[verify_no_interactions]({{site.baseurl}}/advanced_testing/spy/#verify_no_interactions) | Verifies that no interactions happened on the spy.|
|[verify_no_more_interactions]({{site.baseurl}}/advanced_testing/spy/#verify_no_more_interactions) | Verifies that the given spy has no unverified interactions.|
|[reset]({{site.baseurl}}/advanced_testing/spy/#reset) | Resets the saved function call counters on a spy.|

### verify

The **verify()** method is used to verify that a function was called a certain number of times. It takes two arguments: the spy instance and the
expected number of times the function should have been called. You can also use argument matchers to verify that specific
arguments were passed to the function.

```gd
verify(<spy>, <times>).function(<args>)
```

Here's an example:

```gd
var spyed_node: Node = spy(auto_free(Node.new()))

# Verify we have no interactions currently on this instance
verify_no_interactions(spyed_node)

# Call with different arguments
spyed_node.set_process(false) # 1 times
spyed_node.set_process(true) # 1 times
spyed_node.set_process(true) # 2 times

# Verify how often we called the function with different argument 
verify(spyed_node, 1).set_process(false)# in sum one time with false
verify(spyed_node, 2).set_process(true) # in sum two times with true

# Verify will fail because we expect the function `set_process(true)` to be called 3 times but it was only called 2 times
verify(spyed_node, 3).set_process(true)
```

### verify_no_interactions

The **verify_no_interactions()** method verifies that no function calls were made on the spy.

```gd
verify_no_interactions(<spy>)
```

Here's an example:

```gd
var spyed_node := spy(auto_free(Node.new())) as Node

# Test that we have no initial interactions on this spy
verify_no_interactions(spyed_node)

# Interact by calling `get_name()`
spyed_node.get_name()

# Now this verification will fail because we have interacted on this spy by calling `get_name`
verify_no_interactions(spyed_node)
```

### verify_no_more_interactions

The **verify_no_more_interactions()** method verifies that all interactions on the spy have been verified.
If the spy has recorded more interactions than you verified with **verify()**, an error is reported.

```gd
verify_no_more_interactions(<spy>)
```

Here's an example:

```gd
var spyed_node := spy(auto_free(Node.new())) as Node

# Interact on two functions 
spyed_node.is_a_parent_of(null)
spyed_node.set_process(false)

# Verify that the spy interacts as expected
verify(spyed_node).is_a_parent_of(null)
verify(spyed_node).set_process(false)

# Check that there are no further interactions with the spy
verify_no_more_interactions(spyed_node)

# Simulate an unexpected interaction with `set_process`
spyed_node.set_process(false)

# Verify that there are no further interactions with the spy
# and that the previous unexpected interaction is detected (the test will fail here)
verify_no_more_interactions(spyed_node)
```

### reset

Resets the recorded function interactions of the given spy.<br>
Sometimes we want to reuse an already created spy for different test scenarios and have to reset the recorded interactions.

```gd
reset(<spy>)
```

Here's an example:

```gd
var spyed_node: Node = spy(auto_free(Node.new()))

# First, we test by interacting with two functions 
spyed_node.is_a_parent_of(null)
spyed_node.set_process(false)

# Verify if the interactions were recorded; at this point, two interactions are recorded
verify(spyed_node).is_a_parent_of(null)
verify(spyed_node).set_process(false)

# Now, we want to test a different scenario and we need to reset the current recorded interactions
reset(spyed_node)
# Verify that the previously recorded interactions have been removed
verify_no_more_interactions(spyed_node)

# Continue testing
spyed_node.set_process(true)
verify(spyed_node).set_process(true)
verify_no_more_interactions(spyed_node)
```

---

## Argument Matchers and spys

Argument matchers allow you to simplify the verification of function calls by verifying function arguments based on their type or class.
This is particularly useful when working with spys because you can use argument matchers to verify function calls without specifying the exact argument values.

For example, instead of verifying that a function was called with a specific boolean argument value, you can use the **any_bool()** argument matcher
to verify that the function was called with any boolean value. Here's an example:

```gd
var spyed_node: Node = spy(auto_free(Node.new()))

# Call the function with different arguments
spyed_node.set_process(false) # Called 1 time
spyed_node.set_process(true) # Called 1 time
spyed_node.set_process(true) # Called 2 times

# Verify that the function was called with any boolean value 3 times
verify(spyed_node, 3).set_process(any_bool())
```

For more details on how to use argument matchers, please see the [Argument Matchers]({{site.baseurl}}/advanced_testing/argument_matchers) section.
