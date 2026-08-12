---
layout: default
title: Tools and Helpers
parent: Advanced Testing
nav_order: 1
---

# Tools and Helpers

GdUnit provides several tools to help you write tests, including managing objects to free and accessing a temporary
    filesystem to store your test data.

---

## auto_free()

A little helper for automatically releasing the objects you create after test execution.

*Note that objects do not manage memory. If a class inherits from Object, you will need to delete its instances manually.
References keep an internal reference counter so that they are automatically released when no longer in use,
and only then. Therefore, you do not need to free references manually with Object.free().*

Use **auto_free()** to automatically release objects when they are no longer in use.
Objects that are covered by **auto_free** only live in the scope where they are used.
These scopes include the test suite setup, test case setup, and the tests themselves.

{% tabs tools-auto_free %}
{% tab tools-auto_free GdScript %}

```gd
func auto_free(obj :Object) -> Object:
```

{% endtab %}
{% tab tools-auto_free C# %}

```cs
public static T AutoFree<T>(T obj);
```

{% endtab %}
{% endtabs %}

Here’s an small example:
{% tabs tools-auto_free-example %}
{% tab tools-auto_free-example GdScript %}

```gd
# using auto_free() on Path object to register for freeing after the test is finished
assert_object(auto_free(Path.new())).is_not_instanceof(Tree)
```

{% endtab %}
{% tab tools-auto_free-example C# %}

```cs
using static Assertions;

  ...
    // using AutoFree() on Path object to register for freeing after the test is finished
    AssertObject(AutoFree(new Godot.Path())).IsNotInstanceOf<Godot.Tree>();
```

{% endtab %}
{% endtabs %}

Here's an extended example of a test suite to demonstrate the usage of auto_free() and freeing memory:

```gd
extends GdUnitTestSuite

var _obj_a;
var _obj_b;
var _obj_c;

# Scope test suite setup
func before():
    _obj_a = auto_free(Node.new())
    print_obj_usage("before")

# Scope test case setup
func before_test():
    _obj_b = auto_free(Node.new())
    print_obj_usage("before_test")

# Scope test
func test():
    _obj_c = auto_free(Node.new())
    # _obj_a still lives here
    # _obj_b still lives here
    # _obj_b still lives here
    print_obj_usage("test")

# Scope test case setup
func after_test():
    # _obj_a still lives here
    # _obj_b still lives here
    # _obj_c is freed
    print_obj_usage("after_test")
    
# Scope test suite setup
func after():
    # _obj_a still lives here
    # _obj_b is auto freed
    # _obj_c is freed
    print_obj_usage("after")

func _notification(what):
    if what == NOTIFICATION_PATH_CHANGED:
        print_header()
    else:
        print_obj_usage(GdObjects.notification_as_string(what))

func print_header() :
    prints("|%16s | %16s | %16s | %16s |" % ["", "_obj_a", "_obj_b", "_obj_c"])
    prints("----------------------------------------------------------------------------")

func print_obj_usage(name :String) :
    prints("|%16s | %16s | %16s | %16s |" % [name, _obj_a, _obj_b, _obj_c])
```

|        State    |           _obj_a |           _obj_b |           _obj_c |
|--- | --- |
|        PARENTED |             Null |             Null |             Null |
|      ENTER_TREE |             Null |             Null |             Null |
| POST_ENTER_TREE |             Null |             Null |             Null |
|           READY |             Null |             Null |             Null |
|          before |      [Node:1515] |             Null |             Null |
|     before_test |      [Node:1515] |      [Node:1519] |             Null |
|            test |      [Node:1515] |      [Node:1519] |      [Node:1521] |
|      after_test |      [Node:1515] |      [Node:1519] | [Deleted Object] |
|           after |      [Node:1515] | [Deleted Object] | [Deleted Object] |
|       EXIT_TREE | [Deleted Object] | [Deleted Object] | [Deleted Object] |
|      UNPARENTED | [Deleted Object] | [Deleted Object] | [Deleted Object] |
|       PREDELETE | [Deleted Object] | [Deleted Object] | [Deleted Object] |

## save_project_settings() / restore_project_settings()

Helpers to snapshot and restore the in-memory [`ProjectSettings`](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)
around a test that changes them, so the change does not leak into later tests.

By default GdUnit automatically saves and restores your project settings around every test execution
(the **Auto Save Project Settings** setting). If you turn that off — for example to save time in a suite
where almost no test touches the settings — you can snapshot on demand in just the tests that need it:
call **save_project_settings()** in `before()`/`before_test()` and **restore_project_settings()** in
`after()`/`after_test()`.

```gd
func save_project_settings() -> void:
func restore_project_settings() -> void:
```

Here's a small example:

```gd
func before_test() -> void:
    save_project_settings()

func after_test() -> void:
    restore_project_settings()

func test_changes_a_setting() -> void:
    ProjectSettings.set_setting("application/config/custom", true)
    # the change is rolled back in after_test(), so later tests see the original value
```

---

## collect_orphan_node_details()

A helper to itemize the orphan nodes detected in the current test, reporting each one's class, instance ID, and the exact
source line where it was created.

By default, GdUnit only reports how many orphan nodes were detected, since capturing this detail has a runtime cost.
Call **collect_orphan_node_details()** at the end of a test, or in `before_test()`/`after_test()`, to itemize whatever
orphans that scope produced. See [Orphan Nodes]({{site.baseurl}}/advanced_testing/orphan/#detailed-orphan-reporting)
for what the itemized report looks like.

```gd
func collect_orphan_node_details() -> void:
```

Here's a small example:

```gd
func test_scene_management() -> void:
    var scene := preload("res://TestScene.tscn").instantiate()
    add_child(scene)

    scene.some_method()

    scene.queue_free()
    # itemize any orphan nodes left after this test
    collect_orphan_node_details()
```

## create_temp_dir()

This helper function creates a new directory under the temporary directory *user://tmp*,
which can be useful for storing data during test execution.<br>
The directory is automatically deleted after the test suite has finished executing.

{% tabs tools-create_temp_dir %}
{% tab tools-create_temp_dir GdScript %}

```gd
func create_temp_dir(relative_path :String) -> String:
```

{% endtab %}
{% tab tools-create_temp_dir C# %}

```cs
public static string CreateTempDir(string path);
```

{% endtab %}
{% endtabs %}

Here’s an example:

```gd
func test_save_game_data():
    # create a temporay directory to store test data
    var temp_dir := create_temp_dir("examples/game/save")
    var file_to_save := temp_dir + "/save_game.dat"
    
    var data = {
        'user': "Hoschi",
        'level': 42
    }
    var file := File.new()
    file.open(file_to_save, File.WRITE)
    file.store_line(JSON.print(data))
    file.close()
    
        # the data is saved at "user://tmp/examples/game/save/save_game.dat"
    assert_bool(file.file_exists(file_to_save)).is_true()
```

## clean_temp_dir()

Deletes the temporary directory created by **create_temp_dir()**.
This function is called automatically after each execution of the test suite to ensure that the temporary directory
is clean and ready for the next test suite.

{% tabs tools-clean_temp_dir %}
{% tab tools-clean_temp_dir GdScript %}

```gd
func clean_temp_dir():
```

{% endtab %}
{% tab tools-clean_temp_dir C# %}

```cs
public static void ClearTempDir();
```

{% endtab %}
{% endtabs %}

## create_temp_file()

The **create_temp_file()** function creates a new File under the temporary directory *user://tmp* + *\<relative_path\>*
with the given name *\<file_name\>* and file *\<mode\>* (default = File.WRITE).<br>
If successful, the returned File is automatically closed after the execution of the test suite.<br>
We can create a small test file at the beginning of a test suite in the **before()** function and read it later
in the test. It is not necessary to close the file, as the GdUnit test runner will close it automatically.

```gd
func create_temp_file(relative_path :String, file_name :String, mode :=File.WRITE) -> File:
```

Here’s an example:

```gd
# setup test data
func before():
    # opens a tmp file with WRITE mode under "user://tmp/examples/game/game.sav" (auto closed)
    var file := create_temp_file("examples/game", "game.sav")
    assert_object(file).is_not_null()
    # write some example data
    file.store_line("some data")
    # not needs to be manually close, will be auto closed before test execution
    
func test_create_temp_file():
    # opens the stored tmp file with READ mode under "user://tmp/examples/game/game.sav" (auto closed)
    var file_read := create_temp_file("examples/game", "game.sav", File.READ)
    assert_object(file_read).is_not_null()
    assert_str(file_read.get_as_text()).is_equal("some data\n")
    # not needs to be manually close, will be auto closed after test suite execution
```

## resource_as_array()

This function reads a resource file located at the given path *\<resource_path\>* and returns its contents as a PackedStringArray.

```gd
func resource_as_array(resource_path :String) -> PoolStringArray:
```

Here’s an example:

```gd
var rows = ["row a", "row b"]
var file_content := resource_as_array("res://myproject/test/resources/TestRows.txt")
assert_array(rows).contains_exactly(file_content)
```

## resource_as_string()

This function reads a resource file located at the given path \<resource_path\> and returned the content as String.

```gd
func resource_as_string(resource_path :String) -> String:
```

Here’s an example:

```gd
var rows = "row a\nrow b\n"
var file_content := resource_as_string("res://myproject/test/resources/TestRows.txt")
assert_string(rows).is_equal(file_content)
```
