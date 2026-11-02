---
layout: default
title: File Assert
parent: Asserts
---

# File Assertions

An assertion tool to verify file resources and their properties.

{% tabs assert-file-overview %}
{% tab assert-file-overview GdScript %}
**GdUnitFileAssert**<br>

| Function                                                                   | Description                                      |
| -------------------------------------------------------------------------- | ------------------------------------------------ |
| [is_file]({{site.baseurl}}/testing/assert-file/#is_file)                   | Verifies the given resource is a file            |
| [exists]({{site.baseurl}}/testing/assert-file/#exists)                     | Verifies the given resource exists               |
| [is_script]({{site.baseurl}}/testing/assert-file/#is_script)               | Verifies the given resource is a gd script       |
| [contains_exactly]({{site.baseurl}}/testing/assert-file/#contains_exactly) | Verifies the given resource contains the content |

{% endtab %}
{% tab assert-file-overview C# %}
Not yet implemented!
{% endtab %}
{% endtabs %}

---

## File Assert Examples

### is_file

Verifies the given resource is a file that can be opened for reading.
{% tabs assert-file-is_file %}
{% tab assert-file-is_file GdScript %}
```gd
func assert_file(<current>).is_file() -> GdUnitFileAssert
```
```gd
# this assertion succeeds if the file exists and can be opened
assert_file("res://test.gd").is_file()

# this assertion fails if the file doesn't exist or can't be opened
assert_file("res://nonexistent.gd").is_file()
assert_file("res://some_directory/").is_file()
```
{% endtab %}
{% tab assert-file-is_file C# %}
Not yet implemented!
{% endtab %}
{% endtabs %}

### exists

Verifies the given resource exists in the file system.
{% tabs assert-file-exists %}
{% tab assert-file-exists GdScript %}
```gd
func assert_file(<current>).exists() -> GdUnitFileAssert
```
```gd
# this assertion succeeds if the file exists
assert_file("res://test.gd").exists()

# this assertion fails if the file doesn't exist
assert_file("res://nonexistent.gd").exists()
```
{% endtab %}
{% tab assert-file-exists C# %}
Not yet implemented!
{% endtab %}
{% endtabs %}

### is_script

Verifies the given resource is a valid GDScript file.
{% tabs assert-file-is_script %}
{% tab assert-file-is_script GdScript %}
```gd
func assert_file(<current>).is_script() -> GdUnitFileAssert
```
```gd
# this assertion succeeds if the file is a valid GDScript
assert_file("res://test.gd").is_script()

# this assertion fails if the file is not a GDScript
assert_file("res://image.png").is_script()
assert_file("res://data.json").is_script()

# this assertion also fails if the file doesn't exist
assert_file("res://nonexistent.gd").is_script()
```
{% endtab %}
{% tab assert-file-is_script C# %}
Not yet implemented!
{% endtab %}
{% endtabs %}

### contains_exactly

Verifies the given GDScript resource contains exactly the specified content as an array of lines.
{% tabs assert-file-contains_exactly %}
{% tab assert-file-contains_exactly GdScript %}
```gd
func assert_file(<current>).contains_exactly(<expected_rows> :Array) -> GdUnitFileAssert
```
```gd
# this assertion succeeds if the script contains exactly these lines
assert_file("res://test.gd").contains_exactly([
    "extends Node",
    "",
    "func _ready():",
    "\tprint(\"Hello World\")"
])

# this assertion fails if the content doesn't match exactly
assert_file("res://test.gd").contains_exactly([
    "extends Node",
    "func _ready():",
    "\tprint(\"Hello World\")"
])  # missing empty line

# this assertion also fails if the file is not a GDScript
assert_file("res://data.json").contains_exactly(["some content"])
```
{% endtab %}
{% tab assert-file-contains_exactly C# %}
Not yet implemented!
{% endtab %}
{% endtabs %}
