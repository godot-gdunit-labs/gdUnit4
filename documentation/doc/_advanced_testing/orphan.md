---
layout: default
title: Orphan Nodes
parent: Advanced Testing
nav_order: 12
---

# Orphan Nodes or Leaking Memory

When developing in Godot, it's important to ensure that objects are properly freed, otherwise they become orphan nodes that can lead to memory leaks.
This is especially important when writing tests, where you may not know if all objects created during the test have been properly freed.

One helpful tool for managing objects is to use the [**auto_free**]({{site.baseurl}}/advanced_testing/tools/#auto_free) function.

---

## Monitoring

GdUnit helps you monitor for orphan nodes by reporting any detected orphan nodes for each test run in the status bar.
If no orphan nodes are detected, a green icon is displayed, but if orphan nodes are detected, a red blinking icon warns you.

![orphan-nodes]({{site.baseurl}}/assets/images/monitoring/orphan-nodes.png){:.centered}

You can use the button to jump to the first orphan node to inspect it. Orphan nodes are reported and marked in yellow for each test step,
including **before()**, **before_test()**, and the test itself.

### Detailed Orphan Reporting

Orphan detection reports a full **stack trace** for each orphan node (requires Godot 4.5+),
including the variable name, script path, and line number where the node was created.
This makes it significantly easier to locate the source of a leak without manual investigation.

![orphan_nodes_example_step3]({{site.baseurl}}/assets/images/monitoring/orphan_nodes_example_step3.png){:.centered}

{% include advice.html
content="If any orphan nodes are detected, I recommend reviewing your implementation to find and fix the issue."
%}

---

## How to Fix Detected Orphan Nodes in Godot

With GdUnit, you can easily identify orphaned nodes that are marked as WARNING in the GdUnit inspector.
It is important to fix any orphaned nodes that are discovered to ensure that your project does not leak memory over time.

### How to Recognize Orphan Nodes in Your Code

Finding the code location where the orphaned nodes are located can be a little difficult and often time-consuming.
If you are not an expert and have no idea what the problem is, we recommend a step-by-step approach to find and fix orphan nodes.

Here is a small example of a class with an orphan node:

```gd
class_name TestOrpahnDetection
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


class MyClass extends Node:
    var orphan_node = null
    
    func _init():
        orphan_node = Node.new()
    
    
    func test_orphan_detected():
        var t := MyClass.new()
        assert_object(t).is_not_null()
```

When we execute the testcase `test_orphan_detected` we will see no failures but it ends with warnings by detect two orphan node.

![orphan_nodes_example]({{site.baseurl}}/assets/images/monitoring/orphan_nodes_example.png)

The orphan_node in the class `MyClass` is not being used or referenced elsewhere, so it will become an orphan node when the instance of MyClass is destroyed.
Also, the instance of `t` is referenced elsewhere and is not finally released.

### How to Fix Orphan Nodes Step by Step

**Step One: Fix your Testcase**<br>
To fix orphan nodes, it is important to ensure that all nodes used in a test case are covered by the
[**auto_free**]({{site.baseurl}}/advanced_testing/tools/#auto_free) function. When the test case is finished, **auto_free** will free the instance automatically.

**auto_free** is a GdUnit function that automatically adds the object to the GdUnit object registry and calls free on the object when the test case ends.
This ensures that any nodes created during the test case are cleaned up properly.

Here is an example of how to fix the test case from the previous section:

```gd
class_name TestOrpahnDetection
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


class MyClass extends Node:
var orphan_node = null

func _init():
    orphan_node = Node.new()


func test_orphan_detected():
    var t :MyClass = auto_free(MyClass.new())
    assert_object(t).is_not_null()
```

We added the **auto_free** around the instantiation of MyClass to register the automatic release after the test execution.

If we run the `test_orphan_detected` test case again, we will see that we have fixed an orphaned node, but there is still one present.
![orphan_nodes_example_step2]({{site.baseurl}}/assets/images/monitoring/orphan_nodes_example_step2.png)

The orphan_node in the class `MyClass` is not being used or referenced elsewhere, so it will become an orphan node when the instance of MyClass is destroyed.

**Step Two: Fix the orphan node inside of MyClass**<br>
We need to fix the class `MyClass` now to ensure the node `orphan_node` will be released.<br>
The best way to fix orphan nodes is to ensure that all nodes are added as children of a parent node. When a parent node is freed,
all of its child nodes are also freed.

Here is an example of how to fix the MyClass example above:

```gd
class_name TestOrpahnDetection
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


class MyClass extends Node:
var orphan_node = null

func _init():
  orphan_node = Node.new()
  add_child(orphan_node)


func test_orphan_detected():
var t :MyClass = auto_free(MyClass.new())
assert_object(t).is_not_null()
```

In this fixed version of MyClass, the orphan_node is added as a child of a parent_node. When the instance of MyClass is destroyed,
the parent_node and orphan_node will also be freed.

Rerun your test and you see the orpahn nodes is fixed.
![orphan_nodes_example_step2]({{site.baseurl}}/assets/images/monitoring/orphan_nodes_example_step2.png)
